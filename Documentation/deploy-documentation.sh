#!/bin/bash
/usr/local/bin/jazzy --config .jazzy.json

github_user=$1
github_password=$2

cd Documentation/
rm -rf gh-pages
git clone -b gh-pages https://"$github_user":"$github_password"@github.com/gini/gini-vision-lib-ios.git gh-pages

mkdir gh-pages/docs
cp -R Api/. gh-pages/docs/

cd gh-pages
touch .nojekyll

git add .
git commit -a -m 'Updated Gini Vision Library documentation'
git push

cd ..
rm -rf gh-pages/
