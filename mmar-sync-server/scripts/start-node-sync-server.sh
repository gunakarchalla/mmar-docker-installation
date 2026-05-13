#!/bin/bash
PRODUCTION=${PRODUCTION}
echo "PRODUCTION = $PRODUCTION"

    for i in {1..1}
    do
        echo "........................................................................................................................................."
        echo "Starting $PRODUCTION server. This may take some time..."
        echo "The branch checked out is $GIT_BRANCH."
        echo "mmar-sync-server will be exposed on http://localhost:8060"
        echo "!!!!!! If you change the port in conf/.env-mmar-sync-server, you have to change the port in docker-compose.yml as well !!!!!"
        echo "........................................................................................................................................."

        sleep 10
    done &

    echo "----------------------------------------------"
    echo "Starting mmar-sync-server..."
    cd /usr/src/app/shared/mmar/mmar-sync-server

    if [ "$PRODUCTION" = true ]; then
    npm run build
    npm run start &
    SERVER_PID=$!
    echo "Server started in production with PID $SERVER_PID"
    else
    npm run debug &
    SERVER_PID=$!
    echo "Server started in develop(debug) with PID $SERVER_PID"
    fi

echo "----------------------------------------------"
echo "Container is running. Press Ctrl+C to stop."
tail -f /dev/null
