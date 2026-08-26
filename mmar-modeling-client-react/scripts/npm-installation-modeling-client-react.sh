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

# mmar-global-data-structure (gds) is consumed from source through the @gds
# alias, so gds must have its own node_modules on disk before Vite starts.
# The initiator installs gds and only then creates this marker. Without the
# wait, Vite can fail to resolve the imports gds makes (class-transformer, ...).
GDS_READY_MARKER="/usr/src/app/shared/mmar/.gds-install-complete"
while [ ! -f "$GDS_READY_MARKER" ]; do
    echo "Waiting for mmar-global-data-structure to be installed by the initiator..."
    sleep 5
done

while [ ! -f /usr/src/app/shared/mmar/mmar-modeling-client-react/package.json ]; do
    echo "Waiting for package.json in mmar-modeling-client-react..."
    sleep 5
done

npm_installation "/usr/src/app/shared/mmar/mmar-modeling-client-react"

echo "Copying .env files..."
cp /usr/src/app/mmar-config-files/.env-mmar-modeling-client-react-development \
   /usr/src/app/shared/mmar/mmar-modeling-client-react/.env.development
cp /usr/src/app/mmar-config-files/.env-mmar-modeling-client-react-prod \
   /usr/src/app/shared/mmar/mmar-modeling-client-react/.env
