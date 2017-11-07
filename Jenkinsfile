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
    stage('HockeyApp upload') {
      when {
        branch 'develop'
      }
      environment {
        HOCKEYAPP_ID = credentials('VisionIOSHockeyAppID')
        HOCKEYAPP_API_KEY = credentials('VisionIOSHockeyAPIKey')
      }
      steps {
        sh 'rm -rf build'
        sh 'mkdir build'
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme GiniVision-Example -configuration Release archive -archivePath build/GiniVision.xcarchive'
        sh 'xcodebuild -exportArchive -archivePath build/GiniVision.xcarchive -exportOptionsPlist scripts/exportOptions.plist -exportPath build -allowProvisioningUpdates'
        step([$class: 'HockeyappRecorder', applications: [[apiToken: env.HOCKEYAPP_API_KEY, downloadAllowed: true, filePath: 'build/GiniVision-Example.ipa', mandatory: false, notifyTeam: false, releaseNotesMethod: [$class: 'NoReleaseNotes'], uploadMethod: [$class: 'VersionCreation', appId: env.HOCKEYAPP_ID]]], debugMode: false, failGracefully: false])

        sh 'rm -rf build'
      }
    }
    stage('Pod lint') {
      when {
        branch 'master'
      }
      steps {
        sh '/usr/local/bin/pod lib lint'
      }
    }
  }
}
