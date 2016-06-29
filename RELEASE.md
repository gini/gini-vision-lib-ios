# Release Process

This document describes the release process for a new version of the Gini Vision Library for iOS.

1. Add new features only in separate `feature` branches and merge them into `develop`
2. Create a `release` branch from `develop`
  * Update `s.version` in `GiniVision.podspec`
  * Update version in `build-documentation-api.sh`
  * If necessary, update version in Example App in Xcode project
  * Add entry to changelog
3. Merge `release` branch into `master` and `develop`
4. Tag `master` branch with the same version used in 2.
5. Push update to [Gini Podspec repo](https://github.com/gini/gini-podspecs) with `pod repo push gini-specs ./GiniVision.podspec`
