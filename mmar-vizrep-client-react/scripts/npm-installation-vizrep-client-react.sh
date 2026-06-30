#!/bin/bash

npm_installation() {
    local target_dir=$1
    if [ -f "$target_dir/package.json" ]; then
        if [ "$DELETE_NODE_MODULES" = true ]; then
            echo "Removing node_modules in $target_dir..."
            rm -rf $target_dir/node_modules
        fi
        echo "Running npm install in $target_dir..."
        cd $target_dir
        npm install
    else
        echo "No package.json found in $target_dir. Skipping."
    fi
}

while [ ! -f /usr/src/app/shared/mmar/mmar-vizrep-client-react/package.json ]; do
    echo "Waiting for package.json in mmar-vizrep-client-react..."
    sleep 5
done

npm_installation "/usr/src/app/shared/mmar/mmar-vizrep-client-react"

echo "Copying .env files..."
cp /usr/src/app/mmar-config-files/.env-mmar-vizrep-client-react-development \
   /usr/src/app/shared/mmar/mmar-vizrep-client-react/.env.development
cp /usr/src/app/mmar-config-files/.env-mmar-vizrep-client-react-prod \
   /usr/src/app/shared/mmar/mmar-vizrep-client-react/.env
