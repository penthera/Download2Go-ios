Tutorial - Download2Go_Hello_World Sample
=======================================
## Summary
A simple Download2Go_Hello_World getting started example for how Penthera download and off-line playback works.
</br>
</br>

## XCode Setup:

## React-Native:

1) From the tutorial root directory ``Download2Go_Hello_World`` install node_modules: ``npm install``
2) From the ``ios`` subdirectory install CocoaPods: ``pod install``

For information on the React-Native environment, visit https://facebook.github.io/react-native/docs/getting-started

</br>
## VirtuosoClientDownloadEngine.framework
If you embed the framework directly (vs using CocoaPods) you will need to change several build settings as follows:

### Search Paths
Set Search Paths to where VirtuosoClientDownloadEngine.framework is located for the following:</br>

* Framework Search Paths
* Library Search Paths

Also make sure to include VirtuosoClientDownloadEngine.framework in both Embedded Binaries and Linked Frameworks.
</br>

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
