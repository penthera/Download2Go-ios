#
# Be sure to run `pod lib lint VirtuosoClientDownloadEngineBitcode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VirtuosoClientSubscriptionManagerBitcode'
  s.version          = '3.14.14'
  s.summary          = 'A best-of-breed download and offline viewing solution for video.'
  s.homepage         = 'http://penthera.com'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'josh-penthera' => 'josh.pressnell@penthera.com' }
  s.source           = { :http => 'https://github.com/penthera/Cache-and-Carry-ios/releases/download/v3.14.14/VirtuosoClientSubscriptionManagerBitcode.zip' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'VirtuosoClientSubscriptionManager.framework/Headers/*'
  
  s.ios.vendored_frameworks = 'VirtuosoClientSubscriptionManager.framework'
  s.preserve_path = 'VirtuosoClientSubscriptionManager.framework/Modules/module.modulemap'
  s.module_map = 'VirtuosoClientSubscriptionManager.framework/Modules/module.modulemap'
  
end
