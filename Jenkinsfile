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
        sh 'git update-ref -d refs/remotes/origin/master'
        sh '/usr/local/bin/pod install --repo-update --project-directory=Example/'
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
      }
    }
    stage('Build ObjC') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "Example ObjC" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme "Example Swift" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Example/GiniVision.xcworkspace -scheme "Example Swift" -destination \'platform=iOS Simulator,name=iPhone 6\' -skip-testing:GiniVision_UITests'
      }
    }
    stage('Documentation') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
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
        sh 'scripts/build-number-bump.sh ${HOCKEYAPP_API_KEY} ${HOCKEYAPP_ID}'
        sh 'xcodebuild -workspace Example/GiniVision.xcworkspace -scheme GiniVision_Example -configuration Release archive -archivePath build/GiniVision.xcarchive'
        sh 'xcodebuild -exportArchive -archivePath build/GiniVision.xcarchive -exportOptionsPlist scripts/exportOptions.plist -exportPath build -allowProvisioningUpdates'
        step([$class: 'HockeyappRecorder', applications: [[apiToken: env.HOCKEYAPP_API_KEY, downloadAllowed: true, filePath: 'build/GiniVision_Example.ipa', mandatory: false, notifyTeam: false, releaseNotesMethod: [$class: 'NoReleaseNotes'], uploadMethod: [$class: 'VersionCreation', appId: env.HOCKEYAPP_ID]]], debugMode: false, failGracefully: false])

        sh 'rm -rf build'
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
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh '/usr/local/bin/pod lib lint --sources=https://github.com/gini/gini-podspecs.git,https://github.com/CocoaPods/Specs.git --allow-warnings'
      }
    }
  }
}
