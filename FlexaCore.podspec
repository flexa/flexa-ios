Pod::Spec.new do |s|
  s.name         = "FlexaCore"
  s.version      = "1.1.1"
  s.summary      = "Flexa Core"
  s.description  = "Flexa Core module by Flexa"
  s.homepage     = "https://github.com/flexa/flexa-ios"
  s.authors      = "Flexa Network Inc.F <developers@flexa.network> (https://developer.flexa.network)"
  s.license      = { :type => 'MIT' }

  s.module_name = "FlexaCore"
  s.platform = :ios
  s.swift_version = "5.1"
  s.ios.deployment_target  = '16.0'

  s.source       = { :git => "https://github.com/flexa/flexa-ios", :tag => s.version }
  s.source_files = 'FlexaCore/Sources/**/*.{swift}'
  
  s.resource_bundle = {
    'FlexaCoreSVG' => "FlexaCore/Sources/Resources/svgs/*.svg"
  }

  s.dependency 'Factory', '~> 2.4.3'
  s.dependency 'DeviceKit', '~> 5.0.0'
  s.dependency 'KeychainAccess', '~> 4.2.2'
  s.dependency 'SwiftUIIntrospect', "~> 26.0.0"
  s.dependency 'FlexaNetworking', "~> #{s.version}"
  s.dependency 'FlexaUICore', "~> #{s.version}"
  s.dependency 'Base32', "~> 1.1.2"
  s.dependency 'SVGView', "~> 1.0.4"

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'FlexaCore/Tests/**/*.{swift}'

    test_spec.dependency 'Nimble', '~> 13.2.0'
    test_spec.dependency 'Quick', '~> 7.0.0'
    test_spec.dependency 'Fakery', '~> 5.1.0'
  end
end
