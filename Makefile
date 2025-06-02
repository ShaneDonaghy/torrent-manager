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