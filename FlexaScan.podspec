Pod::Spec.new do |s|
  s.name         = "FlexaScan"
  s.version      = "1.0.3"
  s.summary      = "FlexaScan"
  s.description  = "QR code scanner by Flexa"
  s.homepage     = "https://github.com/flexa/flexa-ios"
  s.authors      = "Flexa Network Inc.F <developers@flexa.network> (https://developer.flexa.network)"
  s.license      = { :type => 'MIT' }

  s.module_name = "FlexaScan"
  s.platform = :ios
  s.swift_version = "5.1"
  s.ios.deployment_target  = '15.0'

  s.source       = { :git => "https://github.com/flexa/flexa-ios", :tag => s.version }
  s.source_files = 'FlexaScan/Sources/**/*.{swift}'

  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.flexa.FlexaScan' }

  s.dependency 'FlexaCore', "~> #{s.version}"

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'FlexaScan/Tests/**/*.{swift}'

    test_spec.dependency 'Nimble', '~> 13.2.0'
    test_spec.dependency 'Quick', '~> 7.0.0'
    test_spec.dependency 'Fakery', '~> 5.1.0'
  end

end
