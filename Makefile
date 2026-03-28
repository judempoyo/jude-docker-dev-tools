COMPOSE = docker compose
ALL_PROFILES = COMPOSE_PROFILES="*"
D ?= -d
P ?= 

SUPPORTED_COMMANDS := up stop down logs restart
ifneq ($(filter $(SUPPORTED_COMMANDS),$(firstword $(MAKECMDGOALS))),)
  PROFILES_LIST := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  PROFILE_FLAGS := $(foreach p,$(PROFILES_LIST),--profile $(p))
  $(eval $(PROFILES_LIST):;@:)
endif

.PHONY: help up stop all down restart ps logs clean check-tools \
         db-cache infra stream full-stack

help: ## Show this help message
	@echo "\033[36mUsage:\033[0m make <command> <profile1> <profile2> [D=\"\"]"
	@echo ""
	@echo "\033[36mCommands:\033[0m"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[36mAvailable Profiles (detected from docker-compose):\033[0m"
	@grep 'profiles:' compose.yml | sed 's/.*\[\(.*\)\].*/  - \1/' | sed 's/,/\n  -/g' | sort -u

check-tools:
	@command -v docker >/dev/null 2>&1 || { echo "\033[31mError: docker is not installed.\033[0m"; exit 1; }
	@command -v docker compose >/dev/null 2>&1 || { echo "\033[31mError: docker-compose is not installed.\033[0m"; exit 1; }
	@echo "\033[32mAll tools are installed! \033[0m"


up: check-tools ## Start services (core by default, or specific profiles e.g. 'make up psql redis', D="")
	@if [ -z "$(PROFILES_LIST)" ]; then $(COMPOSE) up $(D); \
	else $(COMPOSE) $(PROFILE_FLAGS) up $(D); fi

stop: ## Stop services (all by default, or specific profiles e.g. 'make stop psql redis')
	@if [ -z "$(PROFILES_LIST)" ]; then $(ALL_PROFILES) $(COMPOSE) stop; \
	else $(COMPOSE) $(PROFILE_FLAGS) stop; fi

down: ## Remove services (all by default, or specific profiles e.g. 'make down psql redis')
	@if [ -z "$(PROFILES_LIST)" ]; then $(ALL_PROFILES) $(COMPOSE) down; \
	else $(COMPOSE) $(PROFILE_FLAGS) down; fi

logs: ## Follow logs (all by default, or specific profiles e.g. 'make logs psql redis')
	@if [ -z "$(PROFILES_LIST)" ]; then $(ALL_PROFILES) $(COMPOSE) logs -f --tail=100; \
	else $(COMPOSE) $(PROFILE_FLAGS) logs -f --tail=100; fi

restart: ## Restart services (all by default, or specific profiles e.g. 'make restart psql')
	@if [ -z "$(PROFILES_LIST)" ]; then $(ALL_PROFILES) $(COMPOSE) restart; \
	else $(COMPOSE) $(PROFILE_FLAGS) restart; fi


all: ## Start all services including all profiles
	$(ALL_PROFILES) $(COMPOSE) up $(D)

db-cache: ## Focus: MySQL and Redis
	$(COMPOSE) --profile mysql --profile redis up $(D)

infra: ## Focus: psql, redis, mail
	$(COMPOSE) --profile psql --profile redis --profile mail up $(D)

stream: ## Focus: kafka, redis
	$(COMPOSE) --profile kafka --profile redis up $(D)

full-stack: ## Focus: Standard dev environment
	$(COMPOSE) --profile mysql --profile redis --profile mail --profile proxy up $(D)

stats: ## Display resource usage
	docker stats --no-stream

version: ## Show versions of images
	$(ALL_PROFILES) $(COMPOSE) images

down-all: ## Stop and remove everything (all profiles)
	$(ALL_PROFILES) $(COMPOSE) down

restart-all: ## Restart all running containers
	$(ALL_PROFILES) $(COMPOSE) restart

ps: ## List all containers status
	$(ALL_PROFILES) $(COMPOSE) ps

logs-all: ## Follow logs of all containers
	$(ALL_PROFILES) $(COMPOSE) logs -f --tail=100

clean: ## Deep clean
	$(ALL_PROFILES) $(COMPOSE) down --remove-orphans
	docker system prune -f