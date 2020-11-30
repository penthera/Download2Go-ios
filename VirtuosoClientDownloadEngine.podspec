#
# Be sure to run `pod lib lint VirtuosoClientDownloadEngine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VirtuosoClientDownloadEngine'
  s.version          = '3.15.15.3'
  s.summary          = 'A best-of-breed download and offline viewing solution for video.'
  s.homepage         = 'http://penthera.com'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'josh-penthera' => 'josh.pressnell@penthera.com' }
  s.source           = { :http => 'https://github.com/penthera/Cache-and-Carry-ios/releases/download/v3.15.15.3/VirtuosoClientDownloadEngine.framework.zip' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'VirtuosoClientDownloadEngine.framework/Headers/*'
  
  s.ios.vendored_frameworks = 'VirtuosoClientDownloadEngine.framework'
  s.preserve_path = 'VirtuosoClientDownloadEngine.framework/Modules/module.modulemap'
  s.module_map = 'VirtuosoClientDownloadEngine.framework/Modules/module.modulemap'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
