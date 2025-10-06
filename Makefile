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

COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
DATA_DIR = /home/mjeannin/data

GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m

.PHONY: all build up down restart clean fclean re logs ps help
.PHONY: volumes-create volumes-clean
.PHONY: nginx wordpress mariadb
.PHONY: bonus bonus-build bonus-up bonus-down bonus-clean bonus-fclean

all: volumes-create build up

volumes-create:
	@echo "$(BLUE)Creating volume directories...$(NC)"
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb
	@echo "$(GREEN)✓ Volume directories created$(NC)"

build:
	@echo "$(YELLOW)Building all Docker images...$(NC)"
	@cd srcs && docker compose build
	@echo "$(GREEN)✓ All images built successfully$(NC)"

up:
	@echo "$(GREEN)Starting Inception services...$(NC)"
	@cd srcs && docker compose up -d
	@echo "$(GREEN)✓ All services started$(NC)"
	@echo "$(BLUE)Site available at: https://localhost:443$(NC)"

down:
	@echo "$(RED)Stopping all services...$(NC)"
	@cd srcs && docker compose down
	@echo "$(GREEN)✓ All services stopped$(NC)"

restart: down up

ps:
	@echo "$(BLUE)Container status:$(NC)"
	@cd srcs && docker compose ps

logs:
	@echo "$(BLUE)Showing logs (press Ctrl+C to exit):$(NC)"
	@cd srcs && docker compose logs -f

clean: down
	@echo "$(YELLOW)Cleaning containers and networks...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✓ Containers and networks cleaned$(NC)"

# Full clean: remove everything (containers, networks, images, volumes, data)
fclean: down
	@echo "$(RED)⚠️  FULL CLEANUP - This will remove ALL Docker data$(NC)"
	@echo "$(RED)Removing all containers, networks, and images...$(NC)"
	@docker system prune -af --volumes
	@echo "$(RED)Removing volume directories...$(NC)"
	@sudo rm -rf $(DATA_DIR)/wordpress/* 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR)/mariadb/* 2>/dev/null || true
	@echo "$(GREEN)✓ Full cleanup completed$(NC)"

# Remove only volume data
volumes-clean:
	@echo "$(RED)Removing volume data...$(NC)"
	@sudo rm -rf $(DATA_DIR)/wordpress/* 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR)/mariadb/* 2>/dev/null || true
	@echo "$(GREEN)✓ Volume data cleaned$(NC)"

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
	@echo "$(GREEN)Bonus Commands:$(NC)"
	@echo "  $(YELLOW)make bonus$(NC)           - Create volumes, build and start ALL services (including bonus)"
	@echo "  $(YELLOW)make bonus-build$(NC)     - Build all images including bonus services"
	@echo "  $(YELLOW)make bonus-up$(NC)        - Start all services including bonus"
	@echo "  $(YELLOW)make bonus-down$(NC)      - Stop all services including bonus"
	@echo "  $(YELLOW)make bonus-clean$(NC)     - Clean all including bonus"
	@echo "  $(YELLOW)make bonus-fclean$(NC)    - Full cleanup including bonus"
	@echo ""
	@echo "$(GREEN)Cleanup Commands:$(NC)"
	@echo "  $(YELLOW)make clean$(NC)           - Remove containers and networks (keep images/volumes)"
	@echo "  $(YELLOW)make volumes-clean$(NC)   - Remove only volume data"
	@echo "  $(YELLOW)make fclean$(NC)          - Full cleanup (remove everything)"
	@echo "  $(YELLOW)make re$(NC)              - Rebuild everything from scratch (fclean + all)"
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
	@echo "$(BLUE)Mandatory:$(NC) Site available at $(GREEN)https://localhost:443$(NC) after $(YELLOW)make up$(NC)"
	@echo "$(BLUE)Bonus:$(NC) Additional services available after $(YELLOW)make bonus$(NC):"
	@echo "$(GREEN)  • Redis Cache: redis://localhost:6379$(NC)"
	@echo "$(GREEN)  • FTP Server: ftp://localhost:21$(NC)"
	@echo "$(GREEN)  • Portfolio: http://localhost:3000$(NC)"
	@echo "$(GREEN)  • Adminer: http://localhost:8080$(NC)"
	@echo "$(GREEN)  • Monitoring: http://localhost:19999$(NC)"

# BONUS COMMANDS
bonus: volumes-create bonus-build bonus-up

bonus-build:
	@echo "$(YELLOW)Building all Docker images (including bonus)...$(NC)"
	@cd srcs && docker compose -f docker-compose-bonus.yml build
	@echo "$(GREEN)✓ All images built successfully (with bonus)$(NC)"

bonus-up:
	@echo "$(GREEN)Starting Inception services (including bonus)...$(NC)"
	@cd srcs && docker compose -f docker-compose-bonus.yml up -d
	@echo "$(GREEN)✓ All services started (with bonus)$(NC)"
	@echo "$(BLUE)=== Services Available ===$(NC)"
	@echo "$(GREEN)Main Site:$(NC) https://localhost:443"
	@echo "$(GREEN)Portfolio:$(NC) http://localhost:3000"
	@echo "$(GREEN)Adminer:$(NC) http://localhost:8080"
	@echo "$(GREEN)Monitoring:$(NC) http://localhost:19999"
	@echo "$(GREEN)Redis:$(NC) localhost:6379"
	@echo "$(GREEN)FTP:$(NC) ftp://localhost:21"

bonus-down:
	@echo "$(RED)Stopping all services (including bonus)...$(NC)"
	@cd srcs && docker compose -f docker-compose-bonus.yml down
	@echo "$(GREEN)✓ All services stopped$(NC)"

bonus-clean: bonus-down
	@echo "$(YELLOW)Cleaning containers and networks (including bonus)...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✓ Containers and networks cleaned$(NC)"

bonus-fclean: bonus-down
	@echo "$(RED)⚠️  FULL CLEANUP - This will remove ALL Docker data (including bonus)$(NC)"
	@echo "$(RED)Removing all containers, networks, and images...$(NC)"
	@docker system prune -af --volumes
	@echo "$(RED)Removing volume directories...$(NC)"
	@sudo rm -rf $(DATA_DIR)/wordpress/* 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR)/mariadb/* 2>/dev/null || true
	@echo "$(GREEN)✓ Full cleanup completed$(NC)"