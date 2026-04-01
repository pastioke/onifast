#!/bin/bash

# Ensure we are in the directory where this script is located (bin folder)
cd "$(dirname "$0")"

# 1. Initialize the repo (if not already done)
if [ ! -d ".git" ]; then
    git init
fi

# 2. Add or update the remote
# We try to add first, and if it already exists, we set the URL just in case.
git remote add origin https://github.com/pastioke/onifast.git 2>/dev/null || \
git remote set-url origin https://github.com/pastioke/onifast.git

# 3. Stage all files in the bin directory
git add .

# 4. Commit using the version text
if [ -f "VERSION" ]; then
    VERSION_STR=$(cat VERSION)
else
    VERSION_STR="unknown"
fi

git commit -m "Release version: $VERSION_STR"

# 5. Ensure we are on the main branch
git branch -M main

# 6. Force push to overwrite the remote with these binaries
git push -u origin main --force