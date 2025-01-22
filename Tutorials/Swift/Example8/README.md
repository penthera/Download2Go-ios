Tutorials
=======================================

#### Swift sample code covering various DRM setup options

* BuyDRM - Example8.1
* Castlabs - Example8.2
* FairPlay - Example8.3
* Widevine - Example8.4


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


