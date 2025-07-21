ifeq ($(OS),Windows_NT)
    ifneq ($(shell where podman 2>nul),)
        CONTAINER_CMD = podman
        COMPOSE_CMD = podman compose
    else ifneq ($(shell where docker 2>nul),)
        CONTAINER_CMD = docker
        COMPOSE_CMD = docker compose
    else
        $(error "Neither podman nor docker are installed. Please install one of them.")
    endif
else
    ifneq ($(shell command -v podman 2>/dev/null),)
        CONTAINER_CMD = podman
        COMPOSE_CMD = podman compose
    else ifneq ($(shell command -v docker 2>/dev/null),)
        CONTAINER_CMD = docker
        COMPOSE_CMD = docker compose
    else
        $(error "Neither podman nor docker are installed. Please install one of them.")
    endif
endif

.PHONY: start-vm deploy undeploy backup backup-redis backup-postgres backup-n8n list-volumes

# Var
PODMAN_MACHINE_NAME ?= podman-machine-default
PROJECT_NAME := $(notdir $(CURDIR))

# Default goal
all: start-vm deploy

start-vm:
ifeq ($(CONTAINER_CMD),podman)
	@echo "Verificando status da VM Podman..."
	@if [ "$(podman machine list --format '{{.Name}} {{.Running}}' | grep '^$(PODMAN_MACHINE_NAME) ' | awk '{print $$2}')" = "true" ]; then \
		echo "A VM '$(PODMAN_MACHINE_NAME)' já está em execução."; \
	else \
		echo "Iniciando a VM '$(PODMAN_MACHINE_NAME)'..."; \
		podman machine start $(PODMAN_MACHINE_NAME); \
	fi
else
	@echo "O Docker não requer uma VM separada nesta configuração. Pulando."
endif

deploy:
	$(COMPOSE_CMD) up -d

undeploy:
	$(COMPOSE_CMD) down

backup: backup-redis backup-postgres backup-n8n

backup-redis:
	@echo "Fazendo backup dos volumes do Redis e Redis Insight..."
ifeq ($(CONTAINER_CMD),podman)
	@$(CONTAINER_CMD) machine ssh $(PODMAN_MACHINE_NAME) -- $(CONTAINER_CMD) volume export $(PROJECT_NAME)_redis-data | gzip > "$(CURDIR)/volume-bkp/$(PROJECT_NAME)_redis-data.tar.gz"
	@$(CONTAINER_CMD) machine ssh $(PODMAN_MACHINE_NAME) -- $(CONTAINER_CMD) volume export $(PROJECT_NAME)_redisinsight-data | gzip > "$(CURDIR)/volume-bkp/$(PROJECT_NAME)_redisinsight-data.tar.gz"
else
	@$(CONTAINER_CMD) run --rm -v $(PROJECT_NAME)_redis-data:/data -v "$(CURDIR)/volume-bkp":/backup busybox tar czf /backup/$(PROJECT_NAME)_redis-data.tar.gz -C /data .
	@$(CONTAINER_CMD) run --rm -v $(PROJECT_NAME)_redisinsight-data:/data -v "$(CURDIR)/volume-bkp":/backup busybox tar czf /backup/$(PROJECT_NAME)_redisinsight-data.tar.gz -C /data .
endif
	@echo "Backup do Redis e Redis Insight concluído."

backup-postgres:
	@echo "Fazendo backup do volume do PostgreSQL e pgadmin4..."
ifeq ($(CONTAINER_CMD),podman)
	@$(CONTAINER_CMD) machine ssh $(PODMAN_MACHINE_NAME) -- $(CONTAINER_CMD) volume export $(PROJECT_NAME)_postgres-data | gzip > "$(CURDIR)/volume-bkp/$(PROJECT_NAME)_postgres-data.tar.gz"
	@$(CONTAINER_CMD) machine ssh $(PODMAN_MACHINE_NAME) -- $(CONTAINER_CMD) volume export $(PROJECT_NAME)_pgadmin4-data | gzip > "$(CURDIR)/volume-bkp/$(PROJECT_NAME)_pgadmin4-data.tar.gz"
else
	@$(CONTAINER_CMD) run --rm -v $(PROJECT_NAME)_postgres-data:/data -v "$(CURDIR)/volume-bkp":/backup busybox tar czf /backup/$(PROJECT_NAME)_postgres-data.tar.gz -C /data .
	@$(CONTAINER_CMD) run --rm -v $(PROJECT_NAME)_pgadmin4-data:/data -v "$(CURDIR)/volume-bkp":/backup busybox tar czf /backup/$(PROJECT_NAME)_pgadmin4-data.tar.gz -C /data .
endif
	@echo "Backup do PostgreSQL e pgadmin4 concluído."

backup-n8n:
	@echo "Fazendo backup do volume do n8n..."
ifeq ($(CONTAINER_CMD),podman)
	@$(CONTAINER_CMD) machine ssh $(PODMAN_MACHINE_NAME) -- $(CONTAINER_CMD) volume export $(PROJECT_NAME)_n8n-data | gzip > "$(CURDIR)/volume-bkp/$(PROJECT_NAME)_n8n-data.tar.gz"
else
	@$(CONTAINER_CMD) run --rm -v $(PROJECT_NAME)_n8n-data:/data -v "$(CURDIR)/volume-bkp":/backup busybox tar czf /backup/$(PROJECT_NAME)_n8n-data.tar.gz -C /data .
endif
	@echo "Backup do n8n concluído."

list-volumes:
	@echo "Listando volumes..."
	@$(CONTAINER_CMD) volume ls
