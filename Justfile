set shell := ["zsh", "-cu"]

# just manual: https://github.com/casey/just/#readme

# Ignore the .env file that is only used by the web service
set dotenv-load := false

CURRENT_DIR := "$(pwd)"

base64_cmd := if "{{os()}}" == "macos" { "base64 -w 0 -i cert.pem -o ca.pem" } else { "base64 -w 0 -i cert.pem > ca.pem" }
grep_cmd := if "{{os()}}" =~ "macos" { "ggrep" } else { "grep" }

# Variables
PYTHON := "uv run python"
UV_RUN := "uv run"

# Recipes
# Install the virtual environment and install the pre-commit hooks
install:
	@echo "🚀 Installing openobserve"
	./install.sh

# Generate AI commit messages
ai-commit:
	aicommits --generate 3 --type conventional

# start the docker compose stack
up:
	docker compose up -d --build
	docker compose logs -f | ccze -A

# stop the docker compose stack
down:
	docker compose down

# reset the docker compose stack
reset:
	docker compose down --volumes --remove-orphans
	docker compose rm -f
	docker compose up -d

# show the logs
logs:
	docker compose logs -f | ccze -A

ps:
	docker compose ps
