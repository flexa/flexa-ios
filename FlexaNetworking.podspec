Pod::Spec.new do |s|
  s.name         = "FlexaNetworking"
  s.version      = "1.0.1"
  s.summary      = "Spend Networking"
  s.description  = "Spend Networking module by Flexa"
  s.homepage     = "https://github.com/flexa/flexa-ios"
  s.authors      = "Flexa Network Inc.F <developers@flexa.network> (https://developer.flexa.network)"
  s.license      = { :type => 'MIT' }

  s.module_name = "FlexaNetworking"
  s.platform = :ios
  s.swift_version = "5.1"
  s.ios.deployment_target  = '15.0'

  s.source       = { :git => "https://github.com/flexa/flexa-ios", :tag => s.version }
  s.source_files = 'FlexaNetworking/Sources/**/*.{swift}'

  s.dependency 'Factory', '~> 2.3.0'
end
