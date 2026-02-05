.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

BIN := bin
TOOLS := tools

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

install: ## Install dotfiles using chezmoi
	chezmoi apply

install-stow: ## Install dotfiles using GNU stow
	stow home config bin vim

lint: ## Run linters (shellcheck + shfmt)
	shellcheck $(BIN)/* $(TOOLS)/* || true
	shfmt -d $(BIN) $(TOOLS) || true

fmt: ## Auto-format shell scripts
	shfmt -w $(BIN) $(TOOLS)

check: lint ## Alias for lint

doctor: ## Verify environment
	command -v chezmoi >/dev/null || echo "❌ chezmoi not installed"
	command -v shellcheck >/dev/null || echo "❌ shellcheck not installed"
	command -v shfmt >/dev/null || echo "❌ shfmt not installed"

clean: ## Remove generated files
	rm -f bin/.help-index
