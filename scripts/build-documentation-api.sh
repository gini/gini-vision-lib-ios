#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

gem install jazzy
jazzy -v

jazzy \
  --clean \
  --author Gini \
  --author_url https://gini.net \
  --github_url https://github.com/gini/gini-vision-lib-ios \
  --module-version 2.0.0-stub.1 \
  --xcodebuild-arguments -workspace,Example/GiniVision.xcworkspace,-scheme,GiniVision \
  --module GiniVision \
  --root-url http://developer.gini.net/gini-vision-lib-ios/api/ \
  --output docs/Api \
  --theme fullwidth \

