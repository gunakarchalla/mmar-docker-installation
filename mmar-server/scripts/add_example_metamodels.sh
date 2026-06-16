#!/bin/bash


# take port from .env file
port=${API_SERVER_PORT}
echo "PORT for api to add example metamodels = $port"
echo "----------------------------------------"

base_url="http://localhost:$port/"
access_token="null"

# Directory that holds the example metamodels. It lives in the shared volume and
# is (re-)populated by the initiator when it clones the mmar-database repository.
metamodels_dir="/usr/src/app/shared/mmar/mmar-database/example_metamodels/up_to_date"

# When a glob matches nothing, expand it to an empty list instead of the literal
# pattern string. Without this, "for file in dir/*.json" loops once with the
# unexpanded pattern as $file, and "curl -d @<pattern>" then POSTs an empty body,
# which the API stores as a scene type with a NULL name. That is exactly what
# happened on restart, when the metamodels had not (yet) been re-cloned into the
# shared volume.
shopt -s nullglob

signin() {
    # get access token
    response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' $base_url"login/signin")
    echo "Response: $response"
    # Remove quotes from the response
    token=$(echo $response | sed 's/^"//;s/"$//')
    echo "Access token for api to add example metamodels = $token"
    # check if access token is null
    if [ "$token" = "null" ] || [ -z "$token" ]; then
        echo "Failed to get access token."
        return 1
    fi
    # set access token
    access_token=$token
    return 0
}

postMetamodel() {
    local file=$1

    # Never POST a missing or empty file: "curl -d @<file>" would send an empty
    # body and the API would create a scene type with a NULL name.
    if [ ! -s "$file" ]; then
        echo "Skipping '$file': file does not exist or is empty."
        echo "----------------------------------------"
        return 1
    fi

    echo "----------------------------------------"
    echo "Adding example metamodel: $file"

    # Use curl to get both the response body and the HTTP status code
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $access_token" \
        -d @"$file" $base_url"metamodel/sceneTypes")

    # Check if the HTTP status code is 200 (Success)
    if [ "$response" -ne 200 ]; then
        echo "Failed to add example metamodel: $file (HTTP code: $response)"
        echo "----------------------------------------"
        return 1
    else
        echo "Added example metamodel: $file"
        echo "----------------------------------------"
        return 0
    fi
}

# Retry sign-in every 15 seconds if it fails
while true; do
    if signin; then
        echo "Sign-in successful."
        echo "----------------------------------------"
        break
    else
        echo "Retrying sign-in in 15 seconds..."
        echo "----------------------------------------"
        sleep 15
    fi
done

# Wait (bounded) for the example metamodels to be present in the shared volume
# before posting anything. On a restart the server can become reachable and sign
# in before the initiator has finished (re-)cloning the mmar-database repository.
# Posting before the JSON files exist is what created the NULL scene type.
max_wait_iterations=60   # 60 x 5s = up to 5 minutes
iteration=0
while [ -z "$(find "$metamodels_dir" -maxdepth 1 -name '*.json' -print -quit 2>/dev/null)" ]; do
    if [ "$iteration" -ge "$max_wait_iterations" ]; then
        echo "No example metamodels found in $metamodels_dir after waiting. Skipping."
        echo "----------------------------------------"
        exit 0
    fi
    echo "Waiting for example metamodels to be available in $metamodels_dir..."
    sleep 5
    iteration=$((iteration + 1))
done

# add example metamodels
for file in "$metamodels_dir"/*.json; do
    postMetamodel "$file"
done

echo "----------------------------------------"
echo "Finished adding example metamodels."
echo "----------------------------------------"
