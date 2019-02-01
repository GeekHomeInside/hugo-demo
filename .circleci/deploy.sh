#!/bin/sh

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`
TARGET_BRANCH="gh-pages"

# Set Directory
DIR=$(dirname "$0")

cd $DIR/..

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

# Delete Old publication
echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

# Checking out gh-pages branch into public
echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public upstream/gh-pages

# Removing existing files
echo "Removing existing files"
rm -rf public/*

# Generating site
echo "Generating site"
hugo -t meghna-hugo

# Updating gh-pages branch
echo "Updating gh-pages branch"
cd public && git config --global user.name "aetreon" && git config --global user.email "aetreon.makeo@gmail.com" && git add --all && git commit -m "Publishing to gh-pages (publish.sh)"

git push $SSH_REPO $TARGET_BRANCH
