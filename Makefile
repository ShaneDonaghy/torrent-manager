all: stop-containers remove-containers remove-images prune-networks clean-docker-all setup-env populate-user-info

# Stop all running and stopped containers
stop-containers:
	@echo "Stopping all Docker containers..."
	@docker stop $$(docker ps -a -q) || true

# Remove all containers (after stopping them)
remove-containers: stop-containers
	@echo "Removing all Docker containers..."
	@docker rm $$(docker ps -a -q) || true

# Remove all Docker images
remove-images:
	@echo "Removing all Docker images..."
	@docker rmi -f $$(docker images -qa) || true

# Remove all unused Docker networks
prune-networks:
	@echo "Pruning unused Docker networks..."
	@docker network prune -f || true

clean-docker-all: stop-containers remove-containers remove-images prune-networks
	@echo "All specified Docker cleanup tasks completed."

setup-env:
	if [ ! -f .env ]; then \
		echo "Creating .env file..."; \
		touch .env; \
		echo "Created .env file Successfully"; \
	fi

populate-user-info:
	echo "Setting PUID and PGID in .env file..."
	sed -i "s/^PUID=.*/PUID=$(id -u)/" .env
	sed -i "s/^PGID=.*/PGID=$(id -g)/" .env
	echo ".env file updated with PUID and PGID."

restart: down up

down:
	sudo docker compose down

up:
	sudo docker compose up -d