.DEFAULT_GOAL := usage

# user and repo
USER        = $$(whoami)
CURRENT_DIR = $(notdir $(shell pwd))

# terminal colours
RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
NC      = \033[0m

.PHONY: install
install:
	@brew bundle || echo "${RED}homebrew not isntalled ❌${NC}"
	MAKELEVEL=0 asdf install || echo "${RED}asdf not installed ❌${NC}"

.session.key:
	ruby -e 'require "securerandom"; \
		File.open(".session.key", "w") {|f| \
			f.write(SecureRandom.hex(32)) }'

log/output.log:
	mkdir log
	touch log/output.log

.PHONY: setup
setup: .session.key pg-init pg-start
	redis-cli ping || redis-server --daemonize yes
	rake db:create db:migrate

.PHONY: present
present:
	slides PRESENTATION.md

.PHONY: sidekiq
sidekiq:
	bundle exec sidekiq --concurrency 1 --queue default --require ./config/environment.rb

.PHONY: sidekiq-web
sidekiq-web:
	bundle exec rackup bin/sidekiq_web_config.ru

.PHONY: view-sidekiq-web
view-sidekiq-web:
	open http://localhost:9292

.PHONY: que
que:
	bundle exec que

.PHONY: que-web
que-web:
	bundle exec rackup bin/que_web_config.ru

.PHONY: view-que-web
view-que-web:
	open http://localhost:9292

.PHONY: pg-init
pg-init:
	PGPORT=5452 asdf exec initdb tmp/postgres -E utf8 || echo "postgres already initialised"

.PHONY: pg-start
pg-start:
	PGPORT=5452 asdf exec pg_ctl -D tmp/postgres -l tmp/postgres/logfile start || echo "pg was probably running"

.PHONY: pg-stop
pg-stop:
	PGPORT=5452 asdf exec pg_ctl -D tmp/postgres stop -s -m fast || echo "postgres already stopped"

.PHONY: db-reset
db-reset: pg-stop
	rm -rf tmp
	make setup
	rake db:create db:migrate

.PHONY: db-show
db-show:
	bundle exec ruby -I . -e 'require "config/environment"; \
		pp ActiveRecord::Base.descendants.map(&:all).map{|m| \
			[m.class.to_s.split("::")[0], m.map(&:attributes)] }'

.PHONY: db-show-que
db-show-que:
	@bundle exec ruby -I . -e 'require "config/environment"; \
		pp ActiveRecord::Base.descendants.map(&:all).map{|m| \
			[m.class.to_s.split("::")[0], m.map(&:attributes)] }; \
		pp ["que_jobs", ActiveRecord::Base.connection.exec_query( \
			"SELECT job_class, finished_at, args FROM que_jobs;").rows]'

.PHONY: create-user
create-user:
	bundle exec ruby -I . -e 'require "config/environment"; \
		Sidekiq::CreateUser.perform_async(ARGV.join(" "))' \
		$(or $(name),$(error Must specify a name))

.PHONY: create-user-outbox
create-user-outbox:
	bundle exec ruby -I . -e 'require "config/environment"; \
		SidekiqOutbox::CreateUser.perform_async(ARGV.join(" "))' \
		$(or $(name),$(error Must specify a name))

.PHONY: clear-outbox
clear-outbox:
	bundle exec ruby -I . -e 'require "config/environment"; Outbox.all.each{|o| \
		SidekiqOutbox::Worker.perform_async(o.id) }'

.PHONY: demo
demo: demo-sidekiq
	@echo "${GREEN}Demo goes here ✅${NC}"

# make demo-long-job duration=15
.PHONY: demo-long-job
demo-long-job:
	bundle exec ruby -I . -e 'require "config/environment"; \
		pp Sidekiq::LongRunningJob.perform_async(ARGV[0].to_i)' \
		$(or $(duration),$(error Must specify a duration))

.PHONY: demo-basic
demo-basic:
	tmux -L "demo" new-session -d "make sidekiq-web"
	tmux -L "demo" rename-window -t "0:0" "sidekiq-web"
	# tmux -L "demo" split-window -t "0:0" -h "make sidekiq"
	tmux -L "demo" new-window -d -n 1 -t "0:1"
	tmux -L "demo" send-keys -t "0:1" "make sidekiq" Enter
	tmux -L "demo" -CC attach-session

.PHONY: demo-sidekiq
demo-sidekiq:
	tmux -L "demo" new-session -d "make sidekiq-web"
	sleep 1
	tmux -L "demo" rename-window -t "0:0" "sidekiq-web"
	tmux -L "demo" new-window -d -n 1 -t "0:1"
	tmux -L "demo" rename-window -t "0:1" "demo"
	tmux -L "demo" send-keys -t "0:1" "make" Enter
	tmux -L "demo" split-window -t "0:1" -h "bundle exec sidekiq --require ./config/environment.rb"
	tmux -L "demo" split-window -t "0:1" -h "watch --interval 1 make db-show"
	tmux -L "demo" select-layout -t "0:1" even-horizontal
	tmux -L "demo" -CC attach-session

.PHONY: create-user-que
create-user-que:
	bundle exec ruby -I . -e 'require "config/environment"; \
		QueJob::CreateUser.enqueue(ARGV.join(" "))' \
		$(or $(name),$(error Must specify a name))

.PHONY: demo-que
demo-que:
	tmux -L "demo" new-session -d "make que"
	sleep 1
	tmux -L "demo" rename-window -t "0:0" "que-web"
	tmux -L "demo" new-window -d -n 1 -t "0:1"
	tmux -L "demo" rename-window -t "0:1" "demo"
	tmux -L "demo" send-keys -t "0:1" "make" Enter
	tmux -L "demo" split-window -t "0:1" -h "make que"
	tmux -L "demo" split-window -t "0:1" -h "watch --interval 1 make db-show-que"
	tmux -L "demo" select-layout -t "0:1" even-horizontal
	tmux -L "demo" -CC attach-session

.PHONY: demo-attach
demo-attach:
	tmux -L "demo" -CC attach-session

.PHONY: build
build:
	bundle exec rubocop

.PHONY: kill-port-9292
kill-port-9292:
	lsof -i :9292 | grep IPv4 | sed 's/  */:/g' | cut -d ":" -f 2 | xargs kill -9

.PHONY: demo-down
demo-down: kill-port-9292
	tmux -L "demo" kill-session || echo "${YELLOW}tmux probably not running${NC}"

.PHONY: clean
clean: demo-down pg-stop
	rm .session.key
	killall redis-server
	rm -rf tmp

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "${YELLOW}make${NC}            show this usage menu"
	@echo "${YELLOW}make install${NC}    install prerequisites"
	@echo
	@echo "${YELLOW}make setup${NC}      setup all the things"
	@echo "${YELLOW}make present${NC}    run presentation slides"
	@echo "${YELLOW}make demo${NC}       run the demo"
	@echo
	@echo "${YELLOW}make build${NC}      build"
	@echo
	@echo "${YELLOW}make clean${NC}      clean up"
	@echo
