#!/bin/bash
PRODUCTION=${PRODUCTION}
echo "PRODUCTION = $PRODUCTION"
echo "Starting mmar-modeling-client-react..."

cd /usr/src/app/shared/mmar/mmar-modeling-client-react

if [ "$PRODUCTION" = true ]; then
    npm run start:prod &
    SERVER_PID=$!
    echo "Server started in production with PID $SERVER_PID"
else
    npm run start &
    SERVER_PID=$!
    echo "Server started in develop with PID $SERVER_PID"
fi

echo "Container is running. Press Ctrl+C to stop."
tail -f /dev/null
