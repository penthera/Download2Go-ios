Tutorial - Example8.4: Widevine DRM
=======================================
## Summary
This sample demonstrates setup of Widevine DRM
</br>
</br>
Several source code variables have to be setup for this Tutorial to work.

* private var licenseUrl: String? = nil

##### licenseUrl:
URL to the license server for FairPlay

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
