# This Makefile contains targets for installing, uninstalling, building, starting, stopping, and cleaning an osTicket docker image.
# It also includes a target for cleaning the setup and preparing the environment.

SHELL := /bin/bash

.PHONY: install uninstall clean-setup prepare build start stop show clean

# Target: install
# Description: Prepares the environment, builds the osTicket docker image, and starts the containers.
install:
	@echo "Preparing..."
	@chmod +x prepare.sh
	@./prepare.sh
	@echo "Building osTicket docker image..."
	@docker build -f Dockerfile -t osticket-docker:apache .
	@echo "Starting..."
	@cp .env.example .env
	@docker compose up -d
	@docker compose ps

# Target: uninstall
# Description: Stops and removes the osTicket containers and volumes.
uninstall:
	@echo "Uninstalling..."
	@docker compose down --volumes
	@docker compose ps

# Target: clean-setup
# Description: Cleans the osTicket setup by removing the setup directory and adjusting file permissions.
clean-setup:
	@echo "Cleaning setup..."
	@docker compose exec osticket rm -rf setup/
	@docker compose exec osticket chmod 0644 include/ost-config.php
	@echo "Cleaning setup done."

# Target: prepare
# Description: Prepares the environment by executing the prepare.sh script.
prepare:
	@echo "Preparing..."
	@chmod +x prepare.sh
	@./prepare.sh

# Target: build
# Description: Builds the osTicket docker image.
build:
	@echo "Building osTicket docker image..."
	@docker build -f Dockerfile -t osticket-docker:apache .

# Target: start
# Description: Starts the osTicket containers.
start:
	@echo "Starting..."
	@cp .env.example .env
	@docker compose up -d
	@docker compose ps

# Target: stop
# Description: Stops the osTicket containers.
stop:
	@echo "Stopping..."
	@docker compose stop
	@docker compose ps

# Target: show
# Description: Shows the status of the osTicket containers.
show:
	@echo "Showing..."
	@docker compose ps

# Target: clean
# Description: Stops and removes the osTicket containers and volumes, and cleans up additional files.
clean:
	@echo "Cleaning..."
	@docker compose down --volumes
	@docker compose ps
	@sudo rm -rf osTicket*.zip
	@sudo rm -rf app/
	@sudo rm .env
	@echo "Cleaning done."