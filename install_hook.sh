#!/bin/bash

# --- Configuration ---
# Define the content of your post-commit script here.
# Make sure to escape any backticks or double quotes if they conflict with the shell.
POST_COMMIT_SCRIPT_CONTENT='#!/bin/bash

# Automatically send commit data to blockchain backend

# CONFIGURATION
BACKEND_URL="http://127.0.0.1:5000/commits"
PROJECT_ID="alpha" # <- replace with actual project_id for this repo

# GATHER COMMIT DATA
COMMIT_MSG=$(git log -1 --pretty=%B)
AUTHOR=$(git config user.name)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# SEND TO BACKEND
curl -X POST "$BACKEND_URL" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"$COMMIT_MSG\", \"author\":\"$AUTHOR\", \"timestamp\":\"$TIMESTAMP\", \"project\":\"$PROJECT_ID\"}"
'

HOOKS_DIR=".git/hooks"
POST_COMMIT_FILE="$HOOKS_DIR/post-commit"

# --- Main Logic ---

echo "Attempting to install post-commit hook..."

# 1. Check if we are in a Git repository
if [ ! -d .git ]; then
    echo "Error: Not in a Git repository. Please run this script from the root of your Git repo."
    exit 1
fi

# 2. Create the hooks directory if it doesn't exist
if [ ! -d "$HOOKS_DIR" ]; then
    echo "Creating hooks directory: $HOOKS_DIR"
    mkdir -p "$HOOKS_DIR"
fi

# 3. Write the post-commit script to the file
echo "Writing post-commit script to $POST_COMMIT_FILE..."
echo "$POST_COMMIT_SCRIPT_CONTENT" > "$POST_COMMIT_FILE"

# 4. Make the script executable
echo "Making $POST_COMMIT_FILE executable..."
chmod +x "$POST_COMMIT_FILE"

echo "Post-commit hook installed successfully!"
echo "It will run automatically after every commit."
