#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and commits to other branches shouldn't try to deploy
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "docs" ]; then
    echo "Skipping documentation deploy."
    exit 0
fi

cd Documentation
virtualenv ./virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt

make clean
make html

cd build
rm -rf gh-pages
git clone -b gh-pages git@github.com:gini/gini-vision-lib-ios.git gh-pages

rm -rf gh-pages/*
mkdir gh-pages/docs
cp -a html/. gh-pages/docs/

mkdir gh-pages/api
cp -a ../../Api/. gh-pages/api/

cd gh-pages
touch .nojekyll

git config user.name "Travis CI"
git config user.email "hello@gini.net" # Use Schorschis Account
git add -u
git add .
git diff --quiet --exit-code --cached || git commit -a -m 'Deploy Gini Vision Library for iOS documentation to Github Pages'
git push