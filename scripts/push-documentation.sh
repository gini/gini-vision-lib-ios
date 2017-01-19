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
git clone -b docs https://${DOC_PUSH_TOKEN}@github.com/gini/gini-vision-lib-ios.git docs
rm -rf docs/*

# Copy integration guide source files
cp -a Documentation/. docs/Documentation/

# Create api documentation
sh scripts/build-documentation-api.sh
sh Documentation/deploy-documentation.sh
