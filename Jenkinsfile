pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      environment {
        GEONOSIS_USER_PASSWORD = credentials('GeonosisUserPassword')
        CLIENT_ID = credentials('VisionClientID')
        CLIENT_PASSWORD = credentials('VisionClientPassword')
      }
      steps {
        sh 'security unlock-keychain -p ${GEONOSIS_USER_PASSWORD} login.keychain'
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        lock('refs/remotes/origin/master') {
          sh '/usr/local/bin/pod install --repo-update --project-directory=Example/'
        }
      }
    }
    stage('Build ObjC') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "Example ObjC" -destination \'platform=iOS Simulator,name=iPhone 8\''
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "Example Swift" -destination \'platform=iOS Simulator,name=iPhone 8\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Unit-Tests" -destination \'platform=iOS Simulator,name=iPhone 8\''
      }
    }
    stage('Release Pod') {
      when {
        anyOf { branch 'hotfix' }
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh '/usr/local/bin/pod repo push gini-specs GiniVision.podspec --sources=https://github.com/gini/gini-podspecs.git,https://github.com/CocoaPods/Specs.git --allow-warnings'
      }
    }
  }
}
