#
# Be sure to run `pod lib lint VirtuosoClientDownloadEngineBitcode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

# Specifications for the local installation of the VituosoClientDownloadEngine with Bitcode

Pod::Spec.new do |s|
  s.name             = 'VirtuosoClientDownloadEngine'
  s.version          = '4.0'
  s.summary          = 'A best-of-breed download and offline viewing solution for video.'
  s.homepage         = 'http://penthera.com'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'josh-penthera' => 'josh.pressnell@penthera.com' }
  s.source           = { :http => 'file:' + __dir__ + '/../../VirtuosoClientEngine/CocoaPodsProducts/VirtuosoClientDownloadEngineBitcode.zip' } 

  s.ios.deployment_target = '11.0'

  s.source_files = 'VirtuosoClientDownloadEngine.framework/Headers/*'
  
  s.ios.vendored_frameworks = 'VirtuosoClientDownloadEngine.framework'
  s.preserve_path = 'VirtuosoClientDownloadEngine.framework/Modules/module.modulemap'
  s.module_map = 'VirtuosoClientDownloadEngine.framework/Modules/module.modulemap'

end
