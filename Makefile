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

.PHONY: web
web:
	open http://localhost:9292

.PHONY: demo
demo: demo-sidekiq
	@echo "${GREEN}Demo goes here ✅${NC}"

.PHONY: demo-sidekiq
demo-sidekiq:
	tmux -L "demo" new-session -d "bundle exec rackup bin/sidekiq_web_config.ru"
	sleep 1
	tmux -L "demo" rename-window -t "0:0" "sidekiq-web"
	tmux -L "demo" new-window -d -n 1 -t "0:1"
	tmux -L "demo" rename-window -t "0:1" "demo"
	tmux -L "demo" send-keys -t "0:1" "make" Enter
	tmux -L "demo" send-keys -t "0:1" "open http://localhost:9292" Enter
	tmux -L "demo" -CC attach-session

.PHONY: demo-attach
demo-attach:
	tmux -L "demo" -CC attach-session

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
	@echo "${YELLOW}make clean${NC}      clean up"
	@echo
