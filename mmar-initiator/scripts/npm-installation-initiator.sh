# Marker file that tells the other containers that mmar-global-data-structure
# (gds) is cloned AND has its node_modules installed. gds is a TypeScript
# project reference of mmar-server and is consumed from source by the clients,
# so nothing may be compiled before its dependencies (class-transformer,
# jsonwebtoken, ...) are on disk. It is removed at the start of every initiator
# run and only re-created after a successful install.
GDS_DIR="/usr/src/app/shared/mmar/mmar-global-data-structure"
GDS_READY_MARKER="/usr/src/app/shared/mmar/.gds-install-complete"

rm -f "$GDS_READY_MARKER"

# Function to clone a repository and run npm install if package.json exists
npm_installation() {
    local target_dir=$1

    if [ -f "$target_dir/package.json" ]; then
        # if $DELETE_NODE_MODULES is true, remove node_modules directory
        if [ "$DELETE_NODE_MODULES" = true ]; then
            echo "--------------------------------------------------------"
            echo "Removing node_modules directory in $target_dir..."
            rm -rf $target_dir/node_modules
        fi        


        echo "----------------------------------------"
        echo "Running npm install in $target_dir..."
        echo "------------be patient ...--------------"
        cd $target_dir
        # rm -rf node_modules
        npm install
    else
        echo "No package.json found in $target_dir. Skipping npm install."
    fi
}

# wait for package.json to be created in the mmar-server directory
while [ ! -f "$GDS_DIR/package.json" ]; do
    echo "Waiting for package.json to be created in $GDS_DIR..."
    sleep 5
done

npm_installation "$GDS_DIR"

# Only signal readiness if the install actually produced node_modules; the other
# containers block on this marker.
if [ -d "$GDS_DIR/node_modules" ]; then
    touch "$GDS_READY_MARKER"
    echo "--------------------------------------------------------"
    echo "mmar-global-data-structure is installed. Dependent containers can start."
    echo "--------------------------------------------------------"
else
    echo "--------------------------------------------------------"
    echo "npm install did not create $GDS_DIR/node_modules."
    echo "Dependent containers will keep waiting."
    echo "--------------------------------------------------------"
    exit 1
fi
