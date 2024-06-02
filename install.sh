#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting osTicket installation..."

# Create a temporary directory to hold the unzipped files
echo "Creating temporary directory..."
mkdir -p ./temp

# Unzip the main osTicket zip file
echo "Unzipping osTicket.zip..."
unzip ./osTicket.zip -d ./temp

# Unzip the osTicket version specific zip file
echo "Unzipping osTicket version specific file..."
unzip ./temp/osTicket-*.zip -d ./temp/

# Copy the 'upload' directory to the 'app' directory
echo "Copying 'upload' directory to 'app' directory..."
rm -rf ./app
cp -r ./temp/upload ./app

# Copy language files to the 'app/include/i18n/' directory
echo "Copying language files..."
cp -r ./temp/vi.phar ./app/include/i18n/

# Copy all .phar plugin files to the 'app/include/plugins/' directory
echo "Copying plugin files..."
cp -r ./temp/*.phar ./app/include/plugins/

# Copy the sample configuration file to create a new configuration file
echo "Creating new configuration file from sample..."
cp ./app/include/ost-sampleconfig.php ./app/include/ost-config.php

# Remove the temporary directory and all its contents
echo "Cleaning up temporary files..."
rm -rf ./temp

# Build the osTicket docker image
echo "Building osTicket docker image..."
docker build -t osticket-docker:v1.18.1 .

# Run the osTicket docker-compose file
docker compose up -d
docker compose ps

echo "osTicket installed successfully!"