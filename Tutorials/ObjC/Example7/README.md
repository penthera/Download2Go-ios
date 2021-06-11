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
> <key>NSAllowsArbitraryLoads</key>
> <true/>
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
