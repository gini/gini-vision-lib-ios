pipeline {
  agent any
  stages {
    stage('Prerequisites') {
      steps {
        pod install
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Example" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
  }
}
