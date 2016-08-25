# Release Process

This document describes the release process for a new version of the Gini Vision Library for iOS.
Parts of this process can be done via fastlane with `fastlane release version:VERSION_NUMBER`.

1. Add new features only in separate `feature` branches and merge them into `develop`
2. Create a `release` branch from `develop`
  * Update `s.version` in `GiniVision.podspec`
  * Update version in `GINIVisionVersion.swift` 
  * Add entry to changelog with version and date
  * If necessary, update version in Example App in Xcode project
3. Merge `release` branch into `master` and `develop`
4. Tag `master` branch with the same version used in 2
5. Push all branches to remote inlcuding tags
6. Push update to [Gini Podspec repo](https://github.com/gini/gini-podspecs) with `pod repo push gini-specs ./GiniVision.podspec`
