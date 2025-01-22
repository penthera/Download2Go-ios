Tutorial - Example7: Playlists (Smart-Download's)
=======================================
## Summary
This sample demonstrates how Sequential Episode Playlists work. When creating an Asset, provide an array of 1..n Playlists. Each playlist can contain any number of AssetID's for the Video Assets included in the Playlist. As a Playlist item is played, and then deleted, Penthera will search for any Playlist in which the deleted asset existed and start the next sequential smart-download.
</br>
</br>

## XCode Setup
### Enable Downloads:
Dowloading Assets requires enabling App Transport Security settings in info.plist

```
>     <key>NSAppTransportSecurity</key>
>     <dict>
>         <key>NSAllowsArbitraryLoads</key>
>        <true/>
>     </dict>
```
</br>
</br>

### VirtuosoClientDownloadEngine.framework:
If you embed the framework directly (vs using CocoaPods) you will need to change several build settings as follows:

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


### Search Paths
Set Search Paths to where VirtuosoClientDownloadEngine.framework is located for the following:</br>

* Framework Search Paths
* Library Search Paths

Also make sure to include VirtuosoClientDownloadEngine.framework in both Embedded Binaries and Linked Frameworks.
</br>
</br>

### Importing Penthera SDK
You will need to create a bridging header as shown in this project to import the Penthera header. 
