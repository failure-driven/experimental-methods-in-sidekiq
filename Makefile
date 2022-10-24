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

.PHONY: present
present:
	slides PRESENTATION.md

.PHONY: demo
demo:
	@echo "${GREEN}Demo goes here ✅${NC}"

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "${YELLOW}make${NC}            show this usage menu"
	@echo "${YELLOW}make install${NC}    install prerequisites"
	@echo "${YELLOW}make present${NC}    run presentation slides"
	@echo "${YELLOW}make demo${NC}       run the demo"
	@echo
