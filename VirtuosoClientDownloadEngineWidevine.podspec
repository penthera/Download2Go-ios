#
# Be sure to run `pod lib lint VirtuosoClientDownloadEngineWidevine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VirtuosoClientDownloadEngineWidevine'
  s.version          = '4.2.12'
  s.summary          = 'A best-of-breed download and offline viewing solution for video.'
  s.homepage         = 'http://penthera.com'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'josh-penthera' => 'josh.pressnell@penthera.com' }
  s.source           = { :http => 'https://github.com/penthera/Download2Go-ios/releases/download/v4.2.12/VirtuosoClientDownloadEngineWidevine.xcframework.zip' }

  s.ios.deployment_target = '10.0'

  s.source_files = 'VirtuosoClientDownloadEngine.xcframework/ios-armv7/VirtuosoClientDownloadEngine.framework/Headers/*'
  
  s.ios.vendored_frameworks = 'VirtuosoClientDownloadEngine.xcframework'
  s.preserve_path = 'VirtuosoClientDownloadEngine.xcframework/*'
  s.module_map = 'VirtuosoClientDownloadEngine.xcframework/ios-armv7/VirtuosoClientDownloadEngine.framework/Modules/module.modulemap'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
