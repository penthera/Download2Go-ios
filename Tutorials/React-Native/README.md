Tutorials
=======================================

#### React-Native sample code covering the following

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

For each tutorial you will need to install node_modules and CocoaPods

1) From the tutorial root directory install node_modules: ``npm install``
2) From the ``ios`` subdirectory install CocoaPods: ``pod install``

For information on the React-Native environment, visit https://facebook.github.io/react-native/docs/getting-started

* Download2Go_Hello_World - minimal example showing download and offline playback
* Example1_1 - Pause / resume downloading
* Example10 - FastPlay example