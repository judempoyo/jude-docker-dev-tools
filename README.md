# Docker Development Infrastructure

This repository is a collection of Docker-based tools and services pre-configured for local development. Whether you're working with streaming data, relational databases, or need a robust observability stack, this setup provides a modular and easy-to-manage infrastructure using Docker Compose and a simple Makefile.

## Quick Start

### 1. Create the Docker Network
First, you need to manually create the Docker network that all services will share. We'll call it `devtools`:

```bash
docker network create devtools
```

### 2. Configure Your Environment
Copy the example environment file and make sure the `DOCKER_NETWORK` variable matches the name you chose in the previous step:

```bash
cp .env.example .env
```
Open `.env` and set `DOCKER_NETWORK=devtools`. This is also where you'll define your database passwords, Cloudflare tokens, and other secrets.

### 3. Usage & Essential Commands
We use `make` to keep things simple. The core commands can be applied to all services or dynamically to specific profiles!

**Command Syntax:** 
`make <command> [profile1] [profile2] ...`

#### Dynamic Core Commands
These commands adapt based on the profiles you provide. If no profile is provided, they fall back to their default scope:
- `up`:               Start services (core by default. Use e.g. `make up psql redis` for specific profiles)
- `down`:             Stop and remove services (all by default, or specific profiles e.g. `make down psql`)
- `stop`:             Stop services without removing them (all by default, or specific profiles e.g. `make stop psql`)
- `restart`:          Restart services (all by default, or specific profiles e.g. `make restart psql`)
- `logs`:             Follow logs (all by default, or specific profiles e.g. `make logs psql`)

#### Environment Stacks
These are helpful shortcuts to automatically start (`make <stack>`) combined groups of profiles:
- `all`:              Start **all** services across every profile
- `full-stack`:       Standard dev environment (MySQL, Redis, Mail, Proxy)
- `infra`:            Infrastructure services (PostgreSQL, Redis, Mail)
- `db-cache`:         Database & Caching (MySQL, Redis)
- `stream`:           Streaming infrastructure (Kafka, Redis)

#### Utilities
- `ps`:               List status of all containers
- `stats`:            Display resource usage metrics
- `clean`:            Deep clean: remove stopped containers and unused networks
- `version`:          Show versions of images used
- `help`:             Show the Makefile help message

#### Single Stacks
Quickly start specific individual tools (`make up/down/stop/restart/log <stack>`):
- `docker`:           Portainer and Dozzle
- `goma`:             Goma-gateway and Goma-provider
- `kafka`:            Kafka, Kafka-UI, and Zookeeper
- `mail`:             Mailpit
- `mysql`:            MySQL and phpMyAdmin
- `obs`:              Prometheus and Grafana
- `proxy`:            Cloudflared
- `psql`:             PostgreSQL and pgAdmin
- `redis`:            Redis and Redis Insight
- `security`:         HashiCorp Vault
- `tools`:            MinIO

## Stacks & Profiles

Instead of running everything at once, you can pick the specific "stack" you need for your current task. Each one corresponds to a Docker Compose profile:

- **Streaming (`kafka`)**: Includes Zookeeper, Kafka, and the Kafka-UI for management.
- **Caching (`redis`)**: Redis server paired with Redis Insight for visual data exploration.
- **SQL Databases**:
    - `mysql`: Standard MySQL server plus phpMyAdmin for web-based access.
    - `psql`: PostgreSQL server along with pgAdmin4.
- **Observability (`obs`)**: Prometheus for metrics and Grafana for dashboards.
- **Infrastructure Management (`docker`)**: Portainer (UI) and Dozzle (real-time log viewer).
- **Security (`security`)**: A local HashiCorp Vault instance.
- **Storage & Documentation (`tools`)**: MinIO (S3-compatible storage) and Swagger UI.
- **Email Testing (`mail`)**: Mailpit, which catches all outgoing SMTP mail for local debugging.
- **Tunneling (`proxy`)**: Cloudflared for exposing your local services securely.
- **Goma (`goma`)**: Goma-gateway reverse proxy and goma provider 

## Service Access Directory

| Service | Access Type | Host Port | URL / Connection String |
| :--- | :--- | :--- | :--- |
| **Grafana** | **Browser** | 8081 | [http://localhost:8081](http://localhost:8081) (`admin` / `admin`) |
| **Goma-Gateway** | **Browser** | 9090 | [http://localhost](http://localhost) |
| **Prometheus** | **Browser** | 9090 | [http://localhost:9090](http://localhost:9090) |
| **Portainer** | **Browser** | 8079 | [http://localhost:8079](http://localhost:8079) |
| **Dozzle** | **Browser** | 8078 | [http://localhost:8078](http://localhost:8078) |
| **phpMyAdmin** | **Browser** | 8075 | [http://localhost:8075](http://localhost:8075) |
| **pgAdmin4** | **Browser** | 8076 | [http://localhost:8076](http://localhost:8076) |
| **Kafka UI** | **Browser** | 8074 | [http://localhost:8074](http://localhost:8074) |
| **Redis Insight** | **Browser** | 8077 | [http://localhost:8077](http://localhost:8077) |
| **MinIO Console**| **Browser** | 9001 | [http://localhost:9001](http://localhost:9001) |
| **Mailpit UI** | **Browser** | 8025 | [http://localhost:8025](http://localhost:8025) |
| **Swagger UI** | **Browser** | 8083 | [http://localhost:8083](http://localhost:8083) |
| **Vault** | **Browser** | 8200 | [http://localhost:8200](http://localhost:8200) |
| **MySQL** | Direct/CLI | 3306 | `localhost:3306` |
| **PostgreSQL** | Direct/CLI | 5432 | `localhost:5432` |
| **Kafka** | Direct/CLI | 9092 | `localhost:9092` |
| **Redis** | Direct/CLI | 6379 | `localhost:6379` |
| **MinIO API** | Direct/CLI | 9000 | `localhost:9000` |
| **Mailpit SMTP** | Direct/CLI | 1025 | `localhost:1025` |

## External Access Details

### Cloudflare Tunnels
Used for exposing local services to the internet without opening ports on your router.
- Get your token from the [Cloudflare Dashboard](https://dash.cloudflare.com/).
- Paste it into `CLOUDFLARE_TOKEN` in your `.env`.

### HashiCorp Vault
- **Default Root Token**: `root`
- Initialized in dev mode for immediate use.

## Technical Resources

- [Official Docker Docs](https://docs.docker.com/)
- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)
- [Cloudflare Tunnels Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Goma Gateway Documentation](https://jkaninda.github.io/goma-gateway)
- [Goma Gateway on GitHub](https://github.com/jkaninda/goma-gateway)
- [Goma Docker Provider](https://github.com/jkaninda/goma-docker-provider)