#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and untagged commits to other branches shouldn't try to deploy
if ([ "$TRAVIS_BRANCH" != "master" ] || [ -z "$TRAVIS_TAG" ]) || [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Skipping pod deploy."
    exit 0
fi

pod repo add gini-specs git@github.com:gini/gini-podspecs.git
pod repo push gini-specs ./GiniVision.podspec

