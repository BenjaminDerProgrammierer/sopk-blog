#!/bin/bash
set -euo pipefail

# Change to the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set variables for Obsidian to Hugo copy
sourcePath="/home/benjamin/Documents/School/SOPK/"
destinationPath="/home/benjamin/Documents/blogs/sopk/content/posts/"

# Set GitHub Repo
myrepo="reponame" # not needed

# Check for required commands
for cmd in git rsync python3 hugo; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd is not installed or not in PATH."
        exit 1
    fi
done

# Step 1: Check if Git is initialized, and initialize if necessary
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git remote add origin $myrepo
else
    echo "Git repository already initialized."
    if ! git remote | grep -q 'origin'; then
        echo "Adding remote origin..."
        git remote add origin $myrepo
    fi
fi

# Step 2: Sync posts from Obsidian to Hugo content folder using rsync
echo "Syncing posts from Obsidian..."

if [ ! -d "$sourcePath" ]; then
    echo "Source path does not exist: $sourcePath"
    exit 1
fi

if [ ! -d "$destinationPath" ]; then
    echo "Destination path does not exist: $destinationPath"
    exit 1
fi

rsync -av --delete "$sourcePath" "$destinationPath"

# # Step 3: Process Markdown files with Python script to handle image links
# echo "Processing image links in Markdown files..."
# if [ ! -f "images.py" ]; then
#     echo "Python script images.py not found."
#     exit 1
# fi
#
# if ! python3 images.py; then
#     echo "Failed to process image links."
#     exit 1
# fi %% %%

# Step 5: Add changes to Git
echo "Staging changes for Git..."
git add .

# Step 6: Commit changes with a dynamic message
commit_message="New Blog Post on $(date +'%Y-%m-%d %H:%M:%S')"
echo "Committing changes..."
git commit -m "$commit_message"

# Step 7: Push all changes to the main branch
echo "Deploying to GitHub Main..."
if ! git push origin main; then
    echo "Failed to push to main branch."
    exit 1
fi

echo "All done! Site synced, processed, committed, built, and deployed."
