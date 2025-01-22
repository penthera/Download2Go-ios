Tutorial - HelloWorld Sample
=======================================
## Summary
A simple HelloWorld getting started example for how Penthera download and off-line playback works using a perpetual license.
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

### VirtuosoClientDownloadEngine.framework:
If you embed the framework directly (vs using CocoaPods) you will need to change several build settings as follows:

### Setup
This demo comes pre-configured with a perpetual license that will only function within this application. In a real application, you will need to request a license from support@penthera.com

Opening Info.plist search for the following:</br>

	<key>VirtuosoLicense</key>
	<string>replace_with_your_app_sdk_license</string>

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
