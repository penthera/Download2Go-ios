Tutorial - Example7.3: FastPlay Playlists
=======================================
## Summary
This sample demonstrates FastPlay Playlists. Assets added to this type of Playlist will trigger next asset download as soon as the asset begins playback for FastPlay.
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

### Search Paths
Set Search Paths to where VirtuosoClientDownloadEngine.framework is located for the following:</br>

* Framework Search Paths
* Library Search Paths

Also make sure to include VirtuosoClientDownloadEngine.framework in both Embedded Binaries and Linked Frameworks.
</br>
</br>

### Importing Penthera SDK
You will need to create a bridging header as shown in this project to import the Penthera header. 
