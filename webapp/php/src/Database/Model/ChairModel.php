<?php

declare(strict_types=1);

namespace IsuRide\Database\Model;

readonly class ChairModel
{
    public function __construct(
        public string $name,
        public int $speed,
    ) {
    }

    public static function getAll(): array
    {
        return [
            'リラックスシート NEO' => 2,
            'エアシェル ライト' => 2,
            'チェアエース S' => 2,
            'スピンフレーム 01' => 2,
            'ベーシックスツール プラス' => 2,
            'SitEase' => 2,
            'ComfortBasic' => 2,
            'EasySit' => 2,
            'LiteLine' => 2,
            'リラックス座' => 2,
            'エルゴクレスト II' => 3,
            'フォームライン RX' => 3,
            'シェルシート ハイブリッド' => 3,
            'リカーブチェア スマート' => 3,
            'フレックスコンフォート PRO' => 3,
            'ErgoFlex' => 3,
            'BalancePro' => 3,
            'StyleSit' => 3,
            '風雅（ふうが）チェア' => 3,
            'AeroSeat' => 3,
            'ゲーミングシート NEXUS' => 3,
            'プレイスタイル Z' => 3,
            'ストリームギア S1' => 3,
            'クエストチェア Lite' => 3,
            'エアフロー EZ' => 3,
            'アルティマシート X' => 5,
            'ゼンバランス EX' => 5,
            'プレミアムエアチェア ZETA' => 5,
            'モーションチェア RISE' => 5,
            'インペリアルクラフト LUXE' => 5,
            'LuxeThrone' => 5,
            'ZenComfort' => 5,
            'Infinity Seat' => 5,
            '雅楽座' => 5,
            'Titanium Line' => 5,
            'プロゲーマーエッジ X1' => 5,
            'スリムライン GX' => 5,
            'フューチャーチェア CORE' => 5,
            'シャドウバースト M' => 5,
            'ステルスシート ROGUE' => 5,
            'ナイトシート ブラックエディション' => 7,
            'フューチャーステップ VISION' => 7,
            '匠座 PRO LIMITED' => 7,
            'ルミナスエアクラウン' => 7,
            'エコシート リジェネレイト' => 7,
            'ShadowEdition' => 7,
            'Phoenix Ultra' => 7,
            '匠座（たくみざ）プレミアム' => 7,
            'Aurora Glow' => 7,
            'Legacy Chair' => 7,
            'インフィニティ GEAR V' => 7,
            'ゼノバース ALPHA' => 7,
            'タイタンフレーム ULTRA' => 7,
            'ヴァーチェア SUPREME' => 7,
            'オブシディアン PRIME' => 7,
        ];
    }
}
