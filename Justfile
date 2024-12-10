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
	sleep 30
	docker compose up -d --build

# show the logs
logs:
	docker compose logs -f | ccze -A

ps:
	docker compose ps

# start the docker compose stack with SQLite backend
up-sqlite:
	docker compose -f docker-compose.sqlite.yaml up -d --build
	docker compose -f docker-compose.sqlite.yaml logs -f | ccze -A

# stop the docker compose stack with SQLite backend
down-sqlite:
	docker compose -f docker-compose.sqlite.yaml down

# reset the docker compose stack with SQLite backend
reset-sqlite:
	docker compose -f docker-compose.sqlite.yaml down --volumes --remove-orphans
	docker compose -f docker-compose.sqlite.yaml rm -f
	sleep 30
	docker compose -f docker-compose.sqlite.yaml up -d --build

# show the logs for SQLite stack
logs-sqlite:
	docker compose -f docker-compose.sqlite.yaml logs -f | ccze -A

# show running containers for SQLite stack
ps-sqlite:
	docker compose -f docker-compose.sqlite.yaml ps

# restart the docker compose stack
restart:
	docker compose restart -d
	docker compose logs -f | ccze -A

# restart the docker compose stack with SQLite backend
restart-sqlite:
	docker compose -f docker-compose.sqlite.yaml restart -d
	docker compose -f docker-compose.sqlite.yaml logs -f | ccze -A

# restart only syslog-ng service
restart-syslog:
	docker compose restart syslog-ng -d
	docker compose logs -f syslog-ng | ccze -A

# restart only syslog-ng service for SQLite stack
restart-syslog-sqlite:
	docker compose -f docker-compose.sqlite.yaml restart syslog-ng -d
	docker compose -f docker-compose.sqlite.yaml logs -f syslog-ng | ccze -A

# Open all services in Firefox browser
open-services:
	@echo "🌐 Opening OpenObserve UI (http://localhost:5081)..."
	{{PYTHON}} scripts/open-browser.py "http://localhost:5081"
	@echo "🌐 Opening MinIO Console (http://localhost:9093)..."
	{{PYTHON}} scripts/open-browser.py "http://localhost:9093"
	@echo "🌐 Opening Prometheus UI (http://localhost:9999)..."
	{{PYTHON}} scripts/open-browser.py "http://localhost:9999"
	@echo "🌐 Opening Grafana UI (http://localhost:3333)..."
	{{PYTHON}} scripts/open-browser.py "http://localhost:3333"
	@echo "🌐 Opening OpenObserve Data Sources UI (http://localhost:5081/web/ingestion/custom/logs/syslog?org_identifier=default)..."
	{{PYTHON}} scripts/open-browser.py "http://localhost:5081/web/ingestion/custom/logs/syslog?org_identifier=default"
	@echo "✨ All services opened in Firefox"

# show logs for axosyslog-metrics-exporter
logs-metrics:
	docker compose logs -f axosyslog-metrics-exporter | ccze -A

# show logs for openobserve
logs-zo:
	docker compose logs -f openobserve | ccze -A

# show logs for axosyslog-metrics-exporter (SQLite stack)
logs-metrics-sqlite:
	docker compose -f docker-compose.sqlite.yaml logs -f axosyslog-metrics-exporter | ccze -A

# show logs for openobserve (SQLite stack)
logs-zo-sqlite:
	docker compose -f docker-compose.sqlite.yaml logs -f openobserve | ccze -A

# show logs for syslog-ng
logs-syslog:
	docker compose logs -f syslog-ng | ccze -A

# show logs for syslog-ng (SQLite stack)
logs-syslog-sqlite:
	docker compose -f docker-compose.sqlite.yaml logs -f syslog-ng | ccze -A
