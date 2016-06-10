#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and commits to other branches shouldn't try to deploy
# if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
#     echo "Skipping documentation deploy."
#     exit 0
# fi

git add Documentation
git commit -m "Push Gini Vision Library for iOS Documentation to docs branch"
git push origin docs