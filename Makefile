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
	@echo "Setting PUID, PGID and IP in .env file..."
	@PUID=$$(id -u); \
	PGID=$$(id -g); \
	UNAME=$$(uname); \
	if [ "$$UNAME" = "Darwin" ]; then \
		IP=$$(ipconfig getifaddr en0 2>/dev/null || \
			ipconfig getifaddr en1 2>/dev/null || \
			ifconfig | awk '/inet / && $$2 != "127.0.0.1" {print $$2; exit}'); \
	else \
		IP=$$(hostname -I 2>/dev/null | awk '{print $$1}'); \
		[ -n "$$IP" ] || IP=$$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($$i == "src") {print $$(i+1); exit}}'); \
		[ -n "$$IP" ] || IP=$$(ifconfig 2>/dev/null | awk '/inet / && $$2 != "127.0.0.1" {print $$2; exit}'); \
	fi; \
	test -n "$$IP" || { echo "Could not determine local IP"; exit 1; }; \
	grep -q '^PUID=' .env && sed -i.bak "s/^PUID=.*/PUID=$$PUID/" .env || echo "PUID=$$PUID" >> .env; \
	grep -q '^PGID=' .env && sed -i.bak "s/^PGID=.*/PGID=$$PGID/" .env || echo "PGID=$$PGID" >> .env; \
	grep -q '^IP='   .env && sed -i.bak "s/^IP=.*/IP=$$IP/"       .env || echo "IP=$$IP"     >> .env; \
	rm -f .env.bak; \
	echo ".env file updated with PUID=$$PUID PGID=$$PGID IP=$$IP."

restart: down up

down:
	sudo docker compose down

up:
	sudo docker compose up -d
