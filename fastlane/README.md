fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios profilesObjC
```
fastlane ios profilesObjC
```

### ios inhouseObjC
```
fastlane ios inhouseObjC
```

### ios profiles
```
fastlane ios profiles
```

### ios inhouse
```
fastlane ios inhouse
```

### ios prepare_framework_release
```
fastlane ios prepare_framework_release
```
Prepares the framework for release.

This lane must be run from a local machine and on a release branch.

 * Verifies the git branch is clean

 * Ensures the lane is running on a release branch

 * Updates the the version of the podspec

 * Commits the changes

 * Pushes the commited branch

####Example:

```
fastlane prepare_framework_release version:2.0.0
```

####Options

Following options are available.

 * **`version`** (required): The new version of the framework

 * **`allow_branch`**: The name of the branch to build from. Defaults to `master`. (`DEPLOY_BRANCH`)



----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
