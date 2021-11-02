Tutorial - Example17: Rendition Delegate
=======================================
This tutorial shows how to use the asset rendition delegate.

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
