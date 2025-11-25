# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::   #
#    Makefile                                           :+:      :+:    :+:   #
#                                                     +:+ +:+         +:+     #
#    By: mjeannin <mjeannin@student.42.fr>          +#+  +:+       +#+        #
#                                                 +#+#+#+#+#+   +#+           #
#    Created: 2025/09/20 14:00:00 by mjeannin          #+#    #+#             #
#    Updated: 2025/09/20 14:00:00 by mjeannin         ###   ########.fr       #
#                                                                              #
# **************************************************************************** #

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
DATA_DIR = /home/mjeannin/data
# secrets are not used; configuration is stored in srcs/.env (MYSQL_*)

# Colors for better output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m

# Target definitions
.PHONY: all build up down restart clean fclean re logs ps help
.PHONY: volumes-create volumes-clean
.PHONY: nginx wordpress mariadb
.PHONY: check env-init secrets-init doctor

# Default target
all: check volumes-create build up

# Create necessary directories for volumes
volumes-create:
	@echo "$(BLUE)Creating volume directories...$(NC)"
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb
	@echo "$(GREEN)✓ Volume directories created$(NC)"

# Build all Docker images
build: check
	@echo "$(YELLOW)Building all Docker images...$(NC)"
	@cd srcs && docker compose build
	@echo "$(GREEN)✓ All images built successfully$(NC)"

# Start all services
up: check
	@echo "$(GREEN)Starting Inception services...$(NC)"
	@cd srcs && docker compose up -d
	@echo "$(GREEN)✓ All services started$(NC)"
	@echo "$(BLUE)Site available at: https://localhost:443$(NC)"

# Verify prerequisites (Docker Engine + Compose v2)
check:
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker not found. Please install Docker Engine and the Compose v2 plugin.$(NC)"; exit 127; }
	@docker compose version >/dev/null 2>&1 || { echo "$(RED)Docker Compose v2 plugin not found. Please install the docker-compose-plugin.$(NC)"; exit 127; }
	@docker ps >/dev/null 2>&1 || { echo "$(RED)Cannot access Docker daemon. Ensure the service is running and your user is in the 'docker' group (then open a new shell or run 'newgrp docker').$(NC)"; exit 127; }
	@[ -f $(ENV_FILE) ] || { echo "$(RED)Missing environment file: $(ENV_FILE). Run 'make env-init' to create it.$(NC)"; exit 2; }
	@grep -qE '^MYSQL_DATABASE=' $(ENV_FILE) || { echo "$(RED)Missing MYSQL_DATABASE in $(ENV_FILE).$(NC)"; exit 2; }
	@grep -qE '^MYSQL_USER=' $(ENV_FILE) || { echo "$(RED)Missing MYSQL_USER in $(ENV_FILE).$(NC)"; exit 2; }
	@grep -qE '^MYSQL_PASSWORD=' $(ENV_FILE) || { echo "$(RED)Missing MYSQL_PASSWORD in $(ENV_FILE).$(NC)"; exit 2; }
	@grep -qE '^MYSQL_ROOT_PASSWORD=' $(ENV_FILE) || { echo "$(RED)Missing MYSQL_ROOT_PASSWORD in $(ENV_FILE).$(NC)"; exit 2; }
	@echo "$(GREEN)✓ Prerequisites OK$(NC)"

# Create a default .env from example if missing
env-init:
	@echo "$(BLUE)Initializing environment file...$(NC)"
	@[ -f $(ENV_FILE) ] && { echo "$(YELLOW)$(ENV_FILE) already exists. Skipping.$(NC)"; exit 0; } || true
	@[ -f srcs/.env.example ] || { echo "$(RED)srcs/.env.example not found.$(NC)"; exit 2; }
	@cp srcs/.env.example $(ENV_FILE)
	@echo "$(GREEN)✓ Created $(ENV_FILE). Please edit values as needed.$(NC)"

# Note: secrets-init removed — this project uses srcs/.env (MYSQL_*) for DB credentials

# Quick health report
doctor: info
	@echo "$(BLUE)=== Doctor checks ===$(NC)"
	@docker ps >/dev/null 2>&1 && echo "$(GREEN)Docker daemon access: OK$(NC)" || echo "$(RED)Docker daemon access: FAIL$(NC)"
	@[ -f $(ENV_FILE) ] && echo "$(GREEN)Env file ($(ENV_FILE)): OK$(NC)" || echo "$(RED)Env file: MISSING$(NC)"
	@grep -qE '^MYSQL_DATABASE=' $(ENV_FILE) && echo "$(GREEN)MYSQL_DATABASE: OK$(NC)" || echo "$(RED)MYSQL_DATABASE: MISSING$(NC)"
	@grep -qE '^MYSQL_USER=' $(ENV_FILE) && echo "$(GREEN)MYSQL_USER: OK$(NC)" || echo "$(RED)MYSQL_USER: MISSING$(NC)"
	@grep -qE '^MYSQL_PASSWORD=' $(ENV_FILE) && echo "$(GREEN)MYSQL_PASSWORD: OK$(NC)" || echo "$(RED)MYSQL_PASSWORD: MISSING$(NC)"
	@grep -qE '^MYSQL_ROOT_PASSWORD=' $(ENV_FILE) && echo "$(GREEN)MYSQL_ROOT_PASSWORD: OK$(NC)" || echo "$(RED)MYSQL_ROOT_PASSWORD: MISSING$(NC)"

# Stop all services
down:
	@echo "$(RED)Stopping all services...$(NC)"
	@cd srcs && docker compose down
	@echo "$(GREEN)✓ All services stopped$(NC)"

# Restart services
restart: down up

# Show container status
ps:
	@echo "$(BLUE)Container status:$(NC)"
	@cd srcs && docker compose ps

# Show logs for all services
logs:
	@echo "$(BLUE)Showing logs (press Ctrl+C to exit):$(NC)"
	@cd srcs && docker compose logs -f

# Clean containers and networks (keep images and volumes)
clean: down
	@echo "$(YELLOW)Cleaning containers and networks...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✓ Containers and networks cleaned$(NC)"

# Full clean: remove everything (containers, networks, images, volumes, data)
fclean: down
	@echo "$(RED)⚠️  FULL CLEANUP - This will remove ALL Docker data$(NC)"
	@echo "$(RED)Removing all containers, networks, and images...$(NC)"
	@docker system prune -af
	@echo "$(YELLOW)Note: persistent host data in '$(DATA_DIR)' is preserved. To remove it manually, run: sudo rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/*$(NC)"
	@echo "$(GREEN)✓ Full cleanup completed$(NC)"

# Remove only volume data
volumes-clean:
	@echo "$(RED)Removing volume data...$(NC)"
	@echo "$(YELLOW)Skipping automatic deletion of host volume data for safety.$(NC)"
	@echo "If you really want to delete persistent data, run:"
	@echo "  sudo rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/*"

.PHONY: volumes-clean-persistent
volumes-clean-persistent:
	@if [ "$(FORCE)" != "true" ]; then \
		echo "$(YELLOW)This target deletes persistent host data. To run it, use: make volumes-clean-persistent FORCE=true$(NC)"; \
		exit 1; \
	fi
	@echo "$(RED)Deleting persistent data under $(DATA_DIR)...$(NC)"
	@sudo rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/* || true
	@echo "$(GREEN)✓ Persistent data removed$(NC)"

# Rebuild everything from scratch
re: fclean all

# Individual service management
nginx:
	@echo "$(YELLOW)Building and starting Nginx only...$(NC)"
	@cd srcs && docker compose build nginx
	@cd srcs && docker compose up -d nginx
	@echo "$(GREEN)✓ Nginx started$(NC)"

wordpress:
	@echo "$(YELLOW)Building and starting WordPress only...$(NC)"
	@cd srcs && docker compose build wordpress
	@cd srcs && docker compose up -d wordpress
	@echo "$(GREEN)✓ WordPress started$(NC)"

mariadb:
	@echo "$(YELLOW)Building and starting MariaDB only...$(NC)"
	@cd srcs && docker compose build mariadb
	@cd srcs && docker compose up -d mariadb
	@echo "$(GREEN)✓ MariaDB started$(NC)"

# Debug and information commands
info:
	@echo "$(BLUE)=== Inception Project Information ===$(NC)"
	@echo "$(GREEN)Site URL:$(NC) https://localhost:443"
	@echo "$(GREEN)Data Directory:$(NC) $(DATA_DIR)"
	@echo "$(GREEN)Docker Compose File:$(NC) $(COMPOSE_FILE)"
	@echo "$(GREEN)Environment File:$(NC) $(ENV_FILE)"
	@echo ""
	@echo "$(BLUE)=== Docker Information ===$(NC)"
	@docker --version 2>/dev/null || echo "$(RED)Docker not found$(NC)"
	@docker compose version 2>/dev/null || echo "$(RED)Docker Compose not found$(NC)"
	@echo ""
	@echo "$(BLUE)=== Volume Directory Status ===$(NC)"
	@ls -la $(DATA_DIR)/ 2>/dev/null || echo "$(RED)Data directory not found$(NC)"

# Show docker compose configuration
config:
	@echo "$(BLUE)Docker Compose Configuration:$(NC)"
	@cd srcs && docker compose config

# Show environment variables
env:
	@echo "$(BLUE)Environment Variables:$(NC)"
	@cat $(ENV_FILE) 2>/dev/null || echo "$(RED).env file not found$(NC)"

# Help message
help:
	@echo "$(BLUE)=== Inception Project Makefile ===$(NC)"
	@echo ""
	@echo "$(GREEN)Main Commands:$(NC)"
	@echo "  $(YELLOW)make$(NC) or $(YELLOW)make all$(NC)    - Create volumes, build images, and start services"
	@echo "  $(YELLOW)make build$(NC)           - Build all Docker images"
	@echo "  $(YELLOW)make up$(NC)              - Start all services"
	@echo "  $(YELLOW)make down$(NC)            - Stop all services"
	@echo "  $(YELLOW)make restart$(NC)         - Restart all services (down + up)"
	@echo "  $(YELLOW)make ps$(NC)              - Show container status"
	@echo "  $(YELLOW)make logs$(NC)            - Show logs for all services"
	@echo ""
	@echo "$(GREEN)Cleanup Commands:$(NC)"
	@echo "  $(YELLOW)make clean$(NC)           - Remove containers and networks (keep images/volumes)"
	@echo "  $(YELLOW)make volumes-clean$(NC)   - Remove only volume data"
	@echo "  $(YELLOW)make volumes-clean-persistent$(NC) - Remove persistent host data (requires FORCE=true)"
	@echo "  $(YELLOW)make fclean$(NC)          - Full cleanup (remove everything)"
	@echo "  $(YELLOW)make re$(NC)              - Rebuild everything from scratch (fclean + all)"
	@echo ""
	@echo "$(GREEN)Setup Helpers:$(NC)"
	@echo "  $(YELLOW)make env-init$(NC)        - Create srcs/.env from example if missing"
	@echo "  $(YELLOW)make doctor$(NC)          - Run quick environment and files checks"
	@echo ""
	@echo "$(GREEN)Individual Services:$(NC)"
	@echo "  $(YELLOW)make nginx$(NC)           - Build and start Nginx only"
	@echo "  $(YELLOW)make wordpress$(NC)       - Build and start WordPress only"
	@echo "  $(YELLOW)make mariadb$(NC)         - Build and start MariaDB only"
	@echo ""
	@echo "$(GREEN)Information Commands:$(NC)"
	@echo "  $(YELLOW)make info$(NC)            - Show project and system information"
	@echo "  $(YELLOW)make config$(NC)          - Show Docker Compose configuration"
	@echo "  $(YELLOW)make env$(NC)             - Show environment variables"
	@echo "  $(YELLOW)make help$(NC)            - Show this help message"
	@echo ""
	@echo "$(BLUE)Note:$(NC) Site will be available at $(GREEN)https://localhost:443$(NC) after $(YELLOW)make up$(NC)"