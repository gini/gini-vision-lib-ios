#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Start with a "cleaner" sheet
gem uninstall bundler -v '>1.12.5' --force || echo "bundler >1.12.5 is not installed"
gem install bundler -v 1.12.5 --no-rdoc --no-ri --no-document --quiet

gem install jazzy
jazzy -v

jazzy \
  --clean \
  --author Gini \
  --author_url https://gini.net \
  --github_url https://github.com/gini/gini-vision-lib-ios \
  --xcodebuild-arguments -workspace,Example/GiniVision.xcworkspace,-scheme,GiniVision \
  --module GiniVision \
  --root-url http://developer.gini.net/gini-vision-lib-ios/api/ \
  --output docs/Api \
  --theme fullwidth \

