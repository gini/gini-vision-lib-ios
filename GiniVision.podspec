Pod::Spec.new do |s|
  s.name             = 'GiniVision'
  s.version          = '3.3.1'
  s.summary          = 'Computer Vision Library for scanning documents.'

  s.description      = <<-DESC
Gini provides an information extraction system for analyzing documents (e. g. invoices or
contracts), specifically information such as the document sender or the amount to pay in an invoice.

The Gini Vision Library for iOS provides functionality to capture documents with mobile phones.
                       DESC

  s.homepage         = 'https://www.gini.net/en/developer/'
  s.license          = { :type => 'Private', :file => 'LICENSE' }
  s.author           = { 'Peter Pult' => 'p.pult@gini.net' }
  s.source           = { :git => 'https://github.com/gini/gini-vision-lib-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gini'
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'GiniVision/Classes/Core/**/*'
    core.resources = 'GiniVision/Assets/*'
  end

  s.subspec 'Networking' do |networking|
    networking.source_files = 'GiniVision/Classes/Networking/**/*'
    networking.dependency "Gini-iOS-SDK", "~> 0.6.0"
  end

  s.frameworks = 'AVFoundation', 'CoreMotion', 'Photos'
end
