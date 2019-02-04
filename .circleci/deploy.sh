#!/bin/sh

set -xe

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ ! -z "$CIRCLE_PULL_REQUEST" -o "$CIRCLE_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`
TARGET_BRANCH="gh-pages"
SOURCE_BRANCH="master"

# Clone the existing gh-pages for this repo into doc/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
git reset --hard
cd ..

# Clean out existing contents
rm -rf public/* || exit 0
rm -rf out/**/* || exit 0

# Generating site
echo "Generating site"
hugo -t meghna-hugo


# Now let's go have some fun with the cloned repo
cd out
git config user.name "Circle CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"


# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if git diff --quiet; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"
git push $SSH_REPO $TARGET_BRANCH
