Pod::Spec.new do |s|
  s.name         = "Flexa"
  s.version      = "1.0.6"
  s.summary      = "Flexa SDK"
  s.description  = "Flexa SDK by Flexa"
  s.homepage     = "https://github.com/flexa/flexa-ios"
  s.authors      = "Flexa Network Inc.F <developers@flexa.network> (https://developer.flexa.network)"
  s.license      = { :type => 'MIT' }

  s.module_name = "Flexa"
  s.platform = :ios
  s.swift_version = "5.1"
  s.ios.deployment_target  = '15.0'

  s.source       = { :git => "https://github.com/flexa/flexa-ios", :tag => s.version }
  s.source_files = 'Sources/**/*.{swift}'

  s.default_subspec = 'Complete'

  s.subspec 'Complete' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.dependency 'FlexaSpend', "~> #{s.version}"
    ss.dependency 'FlexaLoad', "~> #{s.version}"
    ss.dependency 'FlexaScan', "~> #{s.version}"
    ss.dependency 'FlexaUICore', "~> #{s.version}"
    ss.dependency 'FlexaNetworking', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'Core' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'Scan' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.dependency 'FlexaScan', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'FlexaLoad' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.dependency 'FlexaLoad', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'Spend' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.dependency 'FlexaSpend', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'Theming' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'UI' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.dependency 'FlexaUICore', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.subspec 'Networking' do |ss|
    ss.dependency 'FlexaCore', "~> #{s.version}"
    ss.dependency 'FlexaNetworking', "~> #{s.version}"
    ss.ios.deployment_target = '15.0'
  end

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'

    test_spec.dependency 'Nimble', '~> 13.2.0'
    test_spec.dependency 'Quick', '~> 7.0.0'
    test_spec.dependency 'Fakery', '~> 5.1.0'
  end
end
