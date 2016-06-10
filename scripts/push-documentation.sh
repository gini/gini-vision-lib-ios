#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and commits to other branches shouldn't try to deploy
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
    echo "Skipping documentation deploy."
    exit 0
fi

rm -rf docs
git clone -b docs git@github.com:gini/gini-vision-lib-ios.git docs

rm -rf docs/*
cp -a Documentation/. docs/Documentation/
cd docs

git add -u
git add .
git diff --quiet --exit-code --cached || git commit -a -m 'Deploy Gini Vision Library for iOS documentation to docs branch'
git push origin docs