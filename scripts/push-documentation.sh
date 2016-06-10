#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and commits to other branches shouldn't try to deploy
# if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
#     echo "Skipping documentation deploy."
#     exit 0
# fi

git checkout docs
git merge master -X theirs --no-ff --no-commit
git reset 
git add .
git commit -m "Update docs branch" 
git push origin docs