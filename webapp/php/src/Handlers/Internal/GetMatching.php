<?php

declare(strict_types=1);

namespace IsuRide\Handlers\Internal;

use IsuRide\Handlers\AbstractHttpHandler;
use IsuRide\Database\Model\ChairModel;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use PDO;
use PDOException;

// このAPIをインスタンス内から一定間隔で叩かせることで、椅子とライドをマッチングさせる
class GetMatching extends AbstractHttpHandler
{
    public function __construct(
        private readonly PDO $db,
    ) {
    }

    public function __invoke(
        ServerRequestInterface $request,
        ResponseInterface $response,
    ): ResponseInterface {
        $stmt = $this->db->prepare('SELECT * FROM rides WHERE chair_id IS NULL ORDER BY created_at');
        $stmt->execute();
        $waitingRides = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($waitingRides) === 0) {
            return $this->writeNoContent($response);
        }

        $stmt = $this->db->prepare(<<<SQL
SELECT *
FROM chairs c
WHERE c.is_active = TRUE
AND NOT EXISTS (
    SELECT 1
    FROM (
        SELECT COUNT(rs.chair_sent_at) = 6 AS completed
        FROM rides r
        JOIN ride_statuses rs ON r.id = rs.ride_id
        WHERE r.chair_id = c.id
        GROUP BY rs.ride_id
    ) is_completed
    WHERE completed = FALSE
);
SQL
        );
        $stmt->execute();
        $availableChairs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($availableChairs) === 0) {
            return $this->writeNoContent($response);
        }

        foreach ($waitingRides as $ride) {
            if (count($availableChairs) === 0) {
                break;
            }
            $matched = $this->findMatchedChair($ride, $availableChairs);
            // region内に椅子がない場合はスキップ
            if ($matched === null) {
                continue;
            }
            $stmt = $this->db->prepare('UPDATE rides SET chair_id = ? WHERE id = ? AND chair_id IS NULL');
            try {
                $stmt->execute([$matched['id'], $ride['id']]);
            } catch (PDOException) {
                continue;
            }
        }
        return $this->writeNoContent($response);
    }

    private function findMatchedChair(array $ride, array &$availableChairs): ?array
    {
        $maxScore = 0;
        $matched = [];
        $key = null;
        foreach ($availableChairs as $index => $chair) {
            $score = $this->calculateScore($ride, $chair);
            if ($score > $maxScore) {
                $maxScore = $score;
                $matched = $chair;
                $key = $index;
            }
        }
        if ($key === null) {
            return null;
        }
        unset($availableChairs[$key]);
        return $matched;
    }

    private function calculateScore(array $ride, array $chair): float
    {
        $pickupDistance = $this->calculateDistance(
            $ride['pickup_latitude'],
            $ride['pickup_longitude'],
            $chair['latitude'],
            $chair['longitude']
        );
        $destinationDistance = $this->calculateDistance(
            $chair['latitude'],
            $chair['longitude'],
            $ride['destination_latitude'],
            $ride['destination_longitude']
        );

        // region間の移動は優先度を最低にする
        if ($destinationDistance > 400) {
            return -PHP_INT_MAX;
        }
        $score = $pickupDistance * 0.1 + $destinationDistance + 5;
        $speed = ChairModel::getAll()[$chair['name']] ?? 1;
        $time = $pickupDistance / $speed + $destinationDistance / $speed;
        return $score / $time;
    }
}
