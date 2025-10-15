Pod::Spec.new do |s|
  s.name         = "FlexaSpend"
  s.version      = "1.1.3"
  s.summary      = "FlexaSpend"
  s.description  = "FlexaSpend module by Flexa"
  s.homepage     = "https://github.com/flexa/flexa-ios"
  s.authors      = "Flexa Network Inc.F <developers@flexa.network> (https://developer.flexa.network)"
  s.license      = { :type => 'MIT' }

  s.module_name = "FlexaSpend"
  s.platform = :ios
  s.swift_version = "5.1"
  s.ios.deployment_target  = '16.0'

  s.source       = { :git => "https://github.com/flexa/flexa-ios", :tag => s.version }
  s.source_files = 'FlexaSpend/Sources/**/*.{swift}'
  
  s.resource_bundle = {
    'FlexaSpendColors' => "FlexaSpend/Sources/Resources/SpendColors.xcassets",
  }

  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.flexa.FlexaSpend' }

  s.dependency 'Factory', '~> 2.4.3'
  s.dependency 'FlexaCore', "~> #{s.version}"
  s.dependency 'FlexaUICore', "~> #{s.version}"

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'FlexaSpend/Tests/**/*.{swift}'
    test_spec.dependency 'Nimble', '~> 13.2.0'
    test_spec.dependency 'Quick', '~> 7.0.0'
    test_spec.dependency 'Fakery', '~> 5.1.0'
  end
end
