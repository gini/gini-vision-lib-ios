pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Example" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
  }
}