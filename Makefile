default: help
.PHONY: help
help:
	@echo "TODO: Write help message"

##########
# ISUCON #
##########
.PHONY: init
init:
	@ansible-playbook -l all ansible/init.yml

SSH := ssh -F $(CURDIR)/.ssh/config
RSYNC := rsync -e "$(SSH)" --rsync-path "sudo rsync"
WEBAPP := isucon1
DB := isucon1

.PHONY: deploy
deploy:
	@ansible-playbook -l webapp,db ansible/deploy.yml

.PHONY: bench
bench:
	@open https://portal.isucon.net/

.PHONY: post-bench
post-bench:
	@$(MAKE) logs profile

##################
# Logs: Download #
##################
NOW := $(shell gdate --iso-8601=seconds)
NGINX_LOG_FILE := /var/log/nginx/access.jsonl.gz
MYSQL_LOG_FILE := /var/log/mysql/slow.log

.PHONY: nginx-log
nginx-log:
	@$(RSYNC) $(WEBAPP):$(NGINX_LOG_FILE) logs/nginx/$(NOW).jsonl.gz
	@$(SSH) $(WEBAPP) "sudo truncate --size 0 $(NGINX_LOG_FILE)"

.PHONY: mysql-log
mysql-log:
	@$(SSH) $(DB) "sudo gzip -f -k --best $(MYSQL_LOG_FILE)"
	@$(RSYNC) $(DB):$(MYSQL_LOG_FILE).gz ./logs/mysql/$(shell gdate --iso-8601=seconds).log.gz
	@$(MAKE) slow.jsonl.gz
	@cp slow.jsonl.gz logs/mysql/$(NOW).jsonl.gz
	@$(SSH) $(DB) "sudo truncate --size 0 $(MYSQL_LOG_FILE)"

.PHONY: logs
logs: nginx-log mysql-log

#################
# Logs: Profile #
#################
LAST_NGINX_LOG_FILE = $(shell ls logs/nginx/*.jsonl.gz | tail -n 1)
LAST_MYSQL_LOG_FILE = $(shell ls logs/mysql/*.log.gz | tail -n 1)
LAST_SLOW_LOG_FILE = $(shell ls logs/mysql/*.jsonl.gz | tail -n 1)
DUCKDB_FILE := profiler/sources/local/local.duckdb

access.jsonl.gz: logs/nginx/*.jsonl.gz
	@cp $(LAST_NGINX_LOG_FILE) ${@}

slow.log: logs/mysql/*.log.gz
	@cp $(LAST_MYSQL_LOG_FILE) ${@}.gz
	@gzip -d -f ${@}.gz

slow.jsonl.gz: slow.log
	@pt-query-digest slow.log \
		--group-by fingerprint \
		--filter 'length($$event->{arg}) <= 1000' \
		--output json | \
	jq -c '.classes[]' | \
	gzip -c > ${@}

.PHONY: alp
alp: $(DUCKDB_FILE)
	@duckdb $(DUCKDB_FILE) \
		--readonly \
		-s "$(shell cat profiler/sources/local/alp.sql)"

.PHONY: pt
pt: slow.log
	@pt-query-digest slow.log

$(DUCKDB_FILE): access.jsonl.gz slow.jsonl.gz duckdb/macros.sql duckdb/last_access_logs.sql duckdb/last_slow_logs.sql
	@duckdb $(DUCKDB_FILE) \
		-s "$(shell cat duckdb/macros.sql)" \
		-s "$(shell cat duckdb/last_access_logs.sql)" \
		-s "$(shell cat duckdb/last_slow_logs.sql)"

.PHONY: profile
.ONESHELL: profile
profile: $(DUCKDB_FILE)
	@duckdb $(DUCKDB_FILE) \
		-s "$(shell cat duckdb/all_access_logs.sql)" \
		-s "$(shell cat duckdb/all_slow_logs.sql)"
	@cd profiler
	@npm run sources
	@npm run dev
