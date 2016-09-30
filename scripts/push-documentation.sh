#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and non-tagged commits shouldn't try to deploy
if [ "$TRAVIS_PULL_REQUEST" != "false" -o -z "$TRAVIS_TAG" ]; then
	echo "branch:$TRAVIS_BRANCH;tag:$TRAVIS_TAG;pullRequest:$TRAVIS_PULL_REQUEST"
    echo "Skipping documentation deploy."
    exit 0
fi

# Clean up
rm -rf docs
git clone -b docs git@github.com:gini/gini-vision-lib-ios.git docs
rm -rf docs/*

# Copy integration guide source files
cp -a Documentation/. docs/Documentation/

# Create api documentation
sh scripts/build-documentation-api.sh

# Push to docs
cd docs
git add -u
git add .
git diff --quiet --exit-code --cached || git commit -a -m 'Deploy Gini Vision Library for iOS documentation to docs branch'
git push origin docs