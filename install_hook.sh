#!/bin/bash

# --- Configuration ---
# Define the content of your post-commit script here.
# This version reads PROJECT_ID from git config --local project.id
POST_COMMIT_SCRIPT_CONTENT='#!/bin/bash

# Automatically send commit data to blockchain backend

# CONFIGURATION
BACKEND_URL="http://127.0.0.1:5000/commits"

# Retrieve PROJECT_ID from Git config for this repository.
# If not set, it will default to "unknown-project" and print a warning.
PROJECT_ID=$(git config --local project.id || echo "unknown-project")

if [ "$PROJECT_ID" = "unknown-project" ]; then
    echo "Warning: project.id is not set in this repository''s Git configuration."
    echo "Using ''unknown-project'' as the project ID."
    echo "To set it: git config --local project.id <YOUR_ACTUAL_PROJECT_ID>"
fi

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
# Use printf to handle the content with escaped quotes properly
printf "%s" "$POST_COMMIT_SCRIPT_CONTENT" > "$POST_COMMIT_FILE"

# 4. Make the script executable
echo "Making $POST_COMMIT_FILE executable..."
chmod +x "$POST_COMMIT_FILE"

echo "Post-commit hook installed successfully!"
echo "Remember to set your project ID for this repository: git config --local project.id <YOUR_PROJECT_ID>"
echo "It will run automatically after every commit."
