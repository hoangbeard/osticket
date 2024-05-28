SHELL := /bin/bash

.PHONY: install uninstall

install:
	@echo "Installing..."
	@chmod +x install.sh
	@./install.sh

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