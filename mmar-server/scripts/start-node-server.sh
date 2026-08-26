#!/bin/bash
# If environment variable $PRODUCTION is set to true, start production server
PRODUCTION=${PRODUCTION}
echo "PRODUCTION = $PRODUCTION"

    # Create a log loop to warn the user 10 times that this takes some time
    # The script should go on even if the loop is running
    for i in {1..1}
    do
        echo "........................................................................................................................................."
        echo "Starting $PRODUCTION server. This may take some time..."
        echo "The branch checked out is $GIT_BRANCH."
        echo "Applications will be exposed on http://localhost:8000, http://localhost:8075, and http://localhost:8085"        
        echo "!!!!!! If you change the ports in the conf/.env files, you have to change the ports in the docker-compose.yml file as well !!!!!"
        echo "........................................................................................................................................."

        sleep 10
    done &

    echo "----------------------------------------------"
    echo "Starting npm run start in mmar/mmar-server..."
    cd /usr/src/app/shared/mmar/mmar-server

    if [ "$PRODUCTION" = true ]; then
    npm run start &
    SERVER_PID=$!
    echo "Server started in production with PID $SERVER_PID"
    else
    npm run docker:debug &
    SERVER_PID=$!
    echo "Server started in develop(debug) with PID $SERVER_PID"
    fi

    # Uncomment if you want to add example metamodels
    echo "----------------------------------------------"
    echo "Adding example metamodels..."
    bash /usr/src/app/add_example_metamodels.sh &


# Stay alive as long as the node server lives. Do NOT "tail -f /dev/null" here:
# that made a server that had died during start-up (e.g. a failing "npm run
# tjs") look like a healthy container that simply never answered on port 8000.
# Exiting with the server's status lets the "restart: always" policy in
# docker-compose.yml bring it back up.
echo "----------------------------------------------"
echo "Container is running. Press Ctrl+C to stop."
wait $SERVER_PID
SERVER_EXIT_CODE=$?

echo "----------------------------------------------"
echo "!!!!!! The mmar-server process exited with code $SERVER_EXIT_CODE !!!!!!"
echo "Check the log above for the actual error. The container will be restarted."
echo "----------------------------------------------"
exit $SERVER_EXIT_CODE
