SHELL := /bin/bash

.PHONY: install uninstall


install:
	@echo "Preparing..."
	@chmod +x prepare.sh
	@./prepare.sh
	@echo "Building osTicket docker image..."
	@docker build -f apache.Dockerfile -t osticket-docker:apache .
	@echo "Starting..."
	@docker compose up -d
	@docker compose ps

uninstall:
	@echo "Uninstalling..."
	@docker compose down --volumes
	@docker compose ps

clean-setup:
	@echo "Cleaning setup..."
	@docker compose exec osticket rm -rf setup/
	@docker compose exec osticket chmod 0644 include/ost-config.php
	@echo "Cleaning setup done."

prepare:
	@echo "Preparing..."
	@chmod +x prepare.sh
	@./prepare.sh

build:
	@echo "Building osTicket docker image..."
	@docker build -f apache.Dockerfile -t osticket-docker:apache .

start:
	@echo "Starting..."
	@docker compose up -d
	@docker compose ps

stop:
	@echo "Stopping..."
	@docker compose stop
	@docker compose ps

show:
	@echo "Showing..."
	@docker compose ps

clean:
	@echo "Cleaning..."
	@docker compose down --volumes
	@docker compose ps
	@sudo rm -rf osTicket*.zip
	@sudo rm -rf app/
	@echo "Cleaning done."