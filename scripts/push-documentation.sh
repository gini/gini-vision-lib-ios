#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests, non-master branches and non-tagged commits shouldn't try to deploy
if [ "$TRAVIS_PULL_REQUEST" != "false" -o -z "$TRAVIS_TAG" -o "$TRAVIS_BRANCH" != "master" ]; then
	echo "branch:$TRAVIS_BRANCH;tag:$TRAVIS_TAG;pullRequest:$TRAVIS_PULL_REQUEST"
    echo "Skipping documentation deploy."
    exit 0
fi

echo "Starting documentation deploy... "

## Create api documentation
#sh scripts/build-documentation-api.sh
#sh Documentation/deploy-documentation.sh

