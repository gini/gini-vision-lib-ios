pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      steps {
        sh '/usr/local/bin/pod install --project-directory=Example/'
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Example" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Example" -destination \'platform=iOS Simulator,name=iPhone 6\' -skip-testing:GiniVision_UITests'
      }
    }
    stage('Documentation') {
      when {
        branch 'master'
      }
      steps {
        sh 'Documentation/deploy-documentation.sh $GIT_USR $GIT_PSW'
      }
    }
  }
}
