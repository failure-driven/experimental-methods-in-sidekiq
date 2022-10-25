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
	@asdf install || echo "${RED}asdf not installed ❌${NC}"

.session.key:
	ruby -e 'require "securerandom"; \
		File.open(".session.key", "w") {|f| \
			f.write(SecureRandom.hex(32)) }'

.PHONY: setup
setup: .session.key
	redis-cli ping || redis-server --daemonize yes

.PHONY: present
present:
	slides PRESENTATION.md

.PHONY: sidekiq
sidekiq:
	bundle exec sidekiq --concurrency 1 --queue default --require ./config/environment.rb

.PHONY: sidekiq-web
sidekiq-web:
	bundle exec rackup bin/sidekiq_web_config.ru

.PHONY: web
web:
	open http://localhost:9292

.PHONY: demo
demo: demo-sidekiq
	@echo "${GREEN}Demo goes here ✅${NC}"

# make demo-long-job duration=15
.PHONY: demo-long-job
demo-long-job:
	bundle exec ruby -I . -e 'require "config/environment"; \
		pp Sidekiq::LongRunningJob.perform_async(ARGV[0].to_i)' \
		$(or $(duration),$(error Must specify a duration))

.PHONY: demo-sidekiq
demo-sidekiq:
	tmux -L "demo" new-session -d "make sidekiq-web"
	tmux -L "demo" rename-window -t "0:0" "sidekiq-web"
	# tmux -L "demo" split-window -t "0:0" -h "make sidekiq"
	tmux -L "demo" new-window -d -n 1 -t "0:1"
	tmux -L "demo" send-keys -t "0:1" "make sidekiq" Enter
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
	tmux -L "demo" kill-session

.PHONY: clean
clean: demo-down
	rm .session.key
	killall redis-server

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
