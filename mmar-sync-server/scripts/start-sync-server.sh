#!/bin/bash
set -e

echo "--------------------------------------------------------"
echo "npm installation..."
/usr/src/app/npm-installation-sync-server.sh

echo "----------------------------------------"
echo "Running start-node-sync-server.sh script..."
echo "----------------------------------------"
bash /usr/src/app/start-node-sync-server.sh
