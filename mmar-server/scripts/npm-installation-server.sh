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
while [ ! -f /usr/src/app/shared/mmar/mmar-server/package.json ]; do
    echo "Waiting for package.json to be created in /usr/src/app/shared/mmar/mmar-server..."
    sleep 5
done

npm_installation "/usr/src/app/shared/mmar/mmar-server"


#copy the env files for the node servers
echo "----------------------------------------"
echo "Copying .env files for the node servers..."
echo "----------------------------------------"
cp /usr/src/app/mmar-config-files/.env-mmar-api /usr/src/app/shared/mmar/mmar-server/.env