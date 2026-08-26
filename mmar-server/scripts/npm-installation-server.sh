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


#copy the env file matching the mode this container was started in.
#the server reads a single .env, so the right one has to be selected here.
echo "----------------------------------------"
echo "Copying .env file for the node server..."
echo "----------------------------------------"
if [ "$PRODUCTION" = true ]; then
    echo "Using the production configuration (.env-mmar-api-prod)."
    cp /usr/src/app/mmar-config-files/.env-mmar-api-prod /usr/src/app/shared/mmar/mmar-server/.env
else
    echo "Using the development configuration (.env-mmar-api-development)."
    cp /usr/src/app/mmar-config-files/.env-mmar-api-development /usr/src/app/shared/mmar/mmar-server/.env
fi
