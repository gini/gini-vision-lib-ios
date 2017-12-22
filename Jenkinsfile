pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      environment {
        GEONOSIS_USER_PASSWORD = credentials('GeonosisUserPassword')
      }
      steps {
        sh 'security unlock-keychain -p ${GEONOSIS_USER_PASSWORD} login.keychain'
        sh '/usr/local/bin/pod install --project-directory=Example/'
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Example" -destination \'platform=iOS Simulator,name=iPhone 6\' | /usr/local/bin/xcpretty -c'
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Example/GiniVision.xcworkspace -scheme "GiniVision-Example" -destination \'platform=iOS Simulator,name=iPhone 6\' -skip-testing:GiniVision_UITests | /usr/local/bin/xcpretty -c'
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
        CLIENT_ID = credentials('VisionClientID')
        CLIENT_PASSWORD = credentials('VisionClientPassword')
      }
      steps {
        sh 'rm -rf build'
        sh 'mkdir build'
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'scripts/build-number-bump.sh ${HOCKEYAPP_API_KEY} ${HOCKEYAPP_ID}'
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme GiniVision-Example -configuration Release archive -archivePath build/GiniVision.xcarchive | /usr/local/bin/xcpretty -c'
        sh 'xcodebuild -exportArchive -archivePath build/GiniVision.xcarchive -exportOptionsPlist scripts/exportOptions.plist -exportPath build -allowProvisioningUpdates | /usr/local/bin/xcpretty -c'
        step([$class: 'HockeyappRecorder', applications: [[apiToken: env.HOCKEYAPP_API_KEY, downloadAllowed: true, filePath: 'build/GiniVision-Example.ipa', mandatory: false, notifyTeam: false, releaseNotesMethod: [$class: 'NoReleaseNotes'], uploadMethod: [$class: 'VersionCreation', appId: env.HOCKEYAPP_ID]]], debugMode: false, failGracefully: false])

        sh 'rm -rf build'
        sh 'rm Example/Release-keys.xcconfig'
      }
      post {
        always {
          sh 'rm Example/Credentials.plist || true'
        }
      }
    }
    stage('Pod lint') {
      when {
        branch 'master'
      }
      steps {
        sh '/usr/local/bin/pod lib lint --allow-warnings'
      }
    }
  }
}
