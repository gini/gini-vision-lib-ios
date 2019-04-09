Pod::Spec.new do |s|
  s.name             = 'GiniVision'
  s.version          = '5.0.0'
  s.summary          = 'Computer Vision Library for scanning documents.'

  s.description      = <<-DESC
Gini provides an information extraction system for analyzing documents (e. g. invoices or
contracts), specifically information such as the document sender or the amount to pay in an invoice.

The Gini Vision Library for iOS provides functionality to capture documents with mobile phones.
                       DESC

  s.homepage         = 'https://www.gini.net/en/developer/'
  s.license          = { :type => 'Private', :file => 'LICENSE' }
  s.author           = { 'Gini GmbH' => 'hello@gini.net' }
  s.frameworks       = 'AVFoundation', 'CoreMotion', 'Photos'
  s.source           = { :git => 'https://github.com/gini/gini-vision-lib-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gini'
  s.swift_version    = '5.0'
  s.ios.deployment_target = '10.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'GiniVision/Classes/Core/**/*'
    core.resources = 'GiniVision/Assets/*'
  end

  s.subspec 'Networking' do |networking|
    networking.source_files = 'GiniVision/Classes/Networking/*.swift', 'GiniVision/Classes/Networking/Extensions/*.swift'
    networking.dependency "GiniVision/Core"
    networking.dependency 'Gini/Documents'
  end

  s.subspec 'Networking+Pinning' do |pinning|
    pinning.source_files = 'GiniVision/Classes/Networking/Pinning/*'
    pinning.dependency "GiniVision/Networking"
    pinning.dependency 'Gini/Pinning'
  end

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'GiniVision/Tests/*.swift'
    test_spec.resources = 'GiniVision/Tests/Assets/*'
    test_spec.requires_app_host = true
  end

end
