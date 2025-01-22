Tutorials
=======================================

#### Objective-C Sample CocoaPods Integration

### Setup
To enable this demo you first need to contact Penthera Customer Support to request registration information including the following items:

* Backplane URL
* Backplane Public Key
* Backplane Private Key

Opening Info.plist search for the following:</br>

	<key>VirtuosoBackplaneUrl</key>
	<string>replace_with_your_backplane_url</string>

Replace "replace_with_your_backplane_url" with the URL Penthera Customer Support provided. 
</br>

Opening Info.plist search for the following:</br>

	<key>VirtuosoBackplaneMasterPublickey</key>
	<string>replace_with_your_public_key</string>

Replace "replace_with_your_public_key" with the Public Key Penthera Customer Support provided. 

</br>
Then scan the source code and replace "replace_with_your_public_key" with the public key provided by Penthera and replace "replace_with_your_private_key" with the private key Penthera provided. 

</br>


A working sample Podfile is already included in the tutorial directory and displayed below.  The default configuration uses the local version of the VirtuosoDownloadEngine CocoaPod without bitcode.

Once your Podfile is configured, invoke the command ```pod install``` to add the requested CocoaPods to the workspace.  Make sure your XCode project is not open.

Anytime you modify your Podfile, remember to rerun ```pod install```.

To update your CocoaPods to the latest version, run ```pod update```.

##### Sample Podfile:

    # Note: You can configure this Podfile to use the local CocoaPod included with the tutorials
    #       or pull a version from github.  For production code you would normally reference
    #       the github version.  For guaranteed compatibility with the tutorials, use the local version.

    #       You may also choose to use bitcode.

    local = true
    bitcode = false

    # Uncomment the next line to define a global platform for your project
    platform :ios, '9.0'

    if !local
      source 'https://github.com/penthera/Cache-and-Carry-specs.git'
      source 'https://github.com/CocoaPods/Specs.git'
    end

    target 'Example9' do
      # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
      use_frameworks!

      # Pods for Example9

      if local
        if bitcode
          pod 'VirtuosoClientDownloadEngine', :podspec => "../../CocoaPodsConfig/VirtuosoClientDownloadEngineBitcode.podspec"
        else
          pod 'VirtuosoClientDownloadEngine', :podspec => "../../CocoaPodsConfig/VirtuosoClientDownloadEngine.podspec"
        end
      else
        if bitcode
          # IMPORTANT - Include the most current Penthera SDK
          pod 'VirtuosoClientDownloadEngineBitcode'
          # ALTERNATIVE - Specify a specific version of Penthera SDK
          # pod 'VirtuosoClientDownloadEngineBitcode', '~> 3.15.13'
        else
          # IMPORTANT - Include the most current Penthera SDK
          pod 'VirtuosoClientDownloadEngine'
          # ALTERNATIVE - Specify a specific version of Penthera SDK
          # pod 'VirtuosoClientDownloadEngine', '~> 3.15.13'
        end
      end

      puts "Using" + (local ? " local" : " github") + " version of VirtuosoClientDownloadEngine CocoaPod" + (bitcode ? " with bitcode" : "") 

    end