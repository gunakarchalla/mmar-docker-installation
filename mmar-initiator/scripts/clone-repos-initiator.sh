#!/bin/bash

set_up_repo() {
    local repo_url=$1
    local dest_dir=$2
    
    # Check if the directory doesn't exist or is empty (ignoring hidden files)
    if [ ! -d "$dest_dir" ] || [ -z "$(find "$dest_dir" -mindepth 1 ! -name ".*" -print -quit)" ]; then
        git clone $repo_url $dest_dir
    else
        echo "----------------------------------------"
        echo "Directory $dest_dir already exists and is not empty. Skipping clone."
    fi

    # Checkout branch according to the environment variable, if provided
    if [ ! -z "$GIT_BRANCH" ]; then
        pushd $dest_dir  # Save current directory and change to repo dir
        
        # Fetch all branches to make sure remote branches are available locally
        echo "----------------------------------------"
        echo "Fetching all branches for repository $dest_dir..."
        git fetch origin
        
        # Get the current checked-out branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        
        # If the current branch is not 'main' or 'develop', skip checkout
        if [[ "$current_branch" != "main" && "$current_branch" != "develop" ]]; then
            echo "----------------------------------------"
            echo "Current branch is '$current_branch'. Skipping checkout."
            popd  # Return to the original directory
            return 0  # Exit the function early
        fi
        
        # If the branch to checkout is different from the current one, proceed
        if [ -z "$(git branch --list $GIT_BRANCH)" ]; then
            git checkout -b $GIT_BRANCH origin/$GIT_BRANCH
            echo "----------------------------------------"
            echo "Checked out branch $GIT_BRANCH for repository $dest_dir."
        else
            git checkout $GIT_BRANCH
            echo "----------------------------------------"
            echo "Branch $GIT_BRANCH already checked out. Skipping checkout."
        fi
        
        # Check for uncommitted changes before pulling
        changes=$(git status --porcelain)

        if [ -n "$changes" ]; then
            # Filter for changes that are only to package-lock.json
            only_package_lock_changed=$(echo "$changes" | grep -v 'package-lock.json')

            if [ -z "$only_package_lock_changed" ]; then
                echo "----------------------------------------"
                echo "Only package-lock.json has changes. Proceeding with pull."
            else
                echo "----------------------------------------"
                echo "Uncommitted changes detected (not just package-lock.json). Skipping pull."
                popd  # Return to the original directory
                return 0
            fi
        fi
        
        # Optionally pull latest changes after checkout
        echo "----------------------------------------"
        echo "Pulling latest changes for branch $GIT_BRANCH"
        git pull origin $GIT_BRANCH
        
        popd  # Return to the original directory
        
        # If DELETE_NODE_MODULES is set to true, remove node_modules and reinstall
        if [ "$DELETE_NODE_MODULES" = true ]; then
            echo "----------------------------------------"
            echo "Removing and reinstalling node_modules for branch $GIT_BRANCH..."
            rm -rf "$dest_dir/node_modules" && cd $dest_dir && npm install
        fi
    fi
}
set_up_repo "https://github.com/gunakarchalla/mmar-database.git" "/usr/src/app/shared/mmar/mmar-database"

set_up_repo "https://github.com/gunakarchalla/mmar-global-data-structure.git" "/usr/src/app/shared/mmar/mmar-global-data-structure"

set_up_repo "https://github.com/gunakarchalla/mmar-server.git" "/usr/src/app/shared/mmar/mmar-server"

set_up_repo "https://github.com/gunakarchalla/mmar-modeling-client.git" "/usr/src/app/shared/mmar/mmar-modeling-client"

set_up_repo "https://github.com/gunakarchalla/mmar-metamodeling-client.git" "/usr/src/app/shared/mmar/mmar-metamodeling-client"

set_up_repo "https://github.com/gunakarchalla/mmar-vizrep-client.git" "/usr/src/app/shared/mmar/mmar-vizrep-client"

set_up_repo "https://github.com/gunakarchalla/mmar-sync-server.git" "/usr/src/app/shared/mmar/mmar-sync-server"
