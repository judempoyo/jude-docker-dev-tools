COMPOSE = docker compose
ALL_PROFILES = COMPOSE_PROFILES="*"

.PHONY: help up all down restart ps logs clean

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check-tools:
	@command -v docker >/dev/null 2>&1 || { echo "\033[31mError: docker is not installed.\033[0m"; exit 1; }
	@command -v docker compose >/dev/null 2>&1 || { echo "\033[31mError: docker-compose is not installed.\033[0m"; exit 1; }
	@echo "\033[32mAll tools are installed! \033[0m"

up: check-tools ## Start core services (without profiles)
	$(COMPOSE) up -d

all: ## Start all services including all profiles (kafka, redis, psql, mail, tools, etc.)
	$(ALL_PROFILES) $(COMPOSE) up -d

mysql: ## Focus: Start postgres and pgadmin services 
	$(COMPOSE) --profile mysql up -d

db-cache: ## Focus: Start MySQL and Redis services
	$(COMPOSE) --profile mysql --profile redis up -d

infra: ## Focus: Start infrastructure services (psql, redis, mail)
	$(COMPOSE) --profile psql --profile redis --profile mail up -d

psql: ## Focus: Start postgres and pgadmin services 
	$(COMPOSE) --profile psql up -d

redis: ## Focus: Start redis and redis insight services 
	$(COMPOSE) --profile redis  up -d

mail: ## Focus: Start mail service
	$(COMPOSE)  --profile mail up -d

stream: ## Focus: Start streaming stack (kafka, redis)
	$(COMPOSE) --profile kafka --profile redis up -d

kafka: ## Focus: Start kafka, kafka-ui and zookeeper services 
	$(COMPOSE) --profile kafka up -d

docker: ## Focus: Start portainer and dozzle services
	$(COMPOSE) --profile docker  up -d

tools: ## Focus: Start minio service
	$(COMPOSE) --profile tools  up -d

obs: ## Focus: Start Prometheus and Grafana
	$(COMPOSE) --profile obs up -d

security: ## Focus: Start HashiCorp Vault
	$(COMPOSE) --profile security up -d

proxy: ## Focus: Start  Cloudflared
	$(COMPOSE) --profile proxy up -d

full-stack: ## Focus: Standard dev environment (MySQL, Redis, Mail, Proxy)
	$(COMPOSE) --profile mysql --profile redis --profile mail --profile proxy up -d


stats: ## Display resource usage for all services
	docker stats --no-stream

version: ## Show versions of images used
	$(ALL_PROFILES) $(COMPOSE) images

down: ## Stop and remove all containers, networks, and images (all profiles)
	$(ALL_PROFILES) $(COMPOSE) down

restart: ## Restart all running containers
	$(ALL_PROFILES) $(COMPOSE) restart

ps: ## List all containers status
	$(ALL_PROFILES) $(COMPOSE) ps

logs: ## Follow logs of all containers
	$(ALL_PROFILES) $(COMPOSE) logs -f --tail=100

clean: ## Deep clean: remove stopped containers and unused networks
	$(ALL_PROFILES) $(COMPOSE) down --remove-orphans
	docker system prune -f