Pod::Spec.new do |s|
  s.name             = 'GiniVision'
  s.version          = '3.3.4'
  s.summary          = 'Computer Vision Library for scanning documents.'

  s.description      = <<-DESC
Gini provides an information extraction system for analyzing documents (e. g. invoices or
contracts), specifically information such as the document sender or the amount to pay in an invoice.

The Gini Vision Library for iOS provides functionality to capture documents with mobile phones.
                       DESC

  s.homepage         = 'https://www.gini.net/en/developer/'
  s.license          = { :type => 'Private', :file => 'LICENSE' }
  s.author           = { 'Gini GmbH' => 'hello@gini.net' }
  s.source           = { :git => 'https://github.com/gini/gini-vision-lib-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gini'
  s.swift_version    = '3.2'
  s.ios.deployment_target = '8.0'

  s.source_files = 'GiniVision/Classes/**/*'
  s.resources = 'GiniVision/Assets/*'

  s.frameworks = 'AVFoundation', 'CoreMotion', 'Photos'
end
