#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Start with a "cleaner" sheet
# gem uninstall json -a --version '>2.0.0'
# gem uninstall bundler -v '>1.12.5' --force || echo "bundler >1.12.5 is not installed"
# gem install bundler -v 1.12.5 --no-rdoc --no-ri --no-document --quiet

gem install jazzy
jazzy -v

jazzy --config .jazzy.json
