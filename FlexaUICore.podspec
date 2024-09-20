Pod::Spec.new do |s|
  s.name         = "FlexaUICore"
  s.version      = "1.0.2"
  s.summary      = "Spend UI"
  s.description  = "Spend UI module by Flexa"
  s.homepage     = "https://github.com/flexa/flexa-ios"
  s.authors      = "Flexa Network Inc.F <developers@flexa.network> (https://developer.flexa.network)"
  s.license      = { :type => 'MIT' }

  s.module_name = "FlexaUICore"
  s.platform = :ios
  s.swift_version = "5.1"
  s.ios.deployment_target  = '15.0'

  s.source       = { :git => "https://github.com/flexa/flexa-ios", :tag => s.version }
  s.source_files = 'FlexaUICore/Sources/**/*.{swift}'

  s.dependency 'FlexaCore', "~> #{s.version}"
  s.dependency 'SwiftUIIntrospect', "~> 0.12.0"

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'FlexaUICore/Tests/**/*.{swift}'

    test_spec.dependency 'Nimble', '~> 13.2.0'
    test_spec.dependency 'Quick', '~> 7.0.0'
    test_spec.dependency 'Fakery', '~> 5.1.0'
  end
end
