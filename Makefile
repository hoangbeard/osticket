SHELL := /bin/bash

.PHONY: install uninstall

install:
	@echo "Installing..."
	@chmod +x install.sh
	@./install.sh

stop:
	@echo "Stopping..."
	@docker compose stop
	@docker compose ps

start:
	@echo "Starting..."
	@docker compose up -d
	@docker compose ps

clean-setup:
	@echo "Cleaning setup..."
	@docker compose exec web rm -rf setup/
	@docker compose exec web chmod 0644 include/ost-config.php
	@echo "Cleaning setup done."

uninstall:
	@echo "Uninstalling..."
	@docker compose down --volumes
	@docker compose ps

show:
	@echo "Showing..."
	@docker compose ps

logs:
	@echo "Showing logs..."
	@docker compose logs -f

clean:
	@echo "Cleaning..."
	@rm -rf osTicket*.zip
	@rm -rf app/
	@echo "Cleaning done."