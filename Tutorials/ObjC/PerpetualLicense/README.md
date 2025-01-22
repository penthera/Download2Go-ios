Tutorial - HelloWorld Sample
=======================================
## Summary
A simple HelloWorld getting started example for how Penthera download and off-line playback works using a perpetual license.
</br>
</br>

## XCode Setup:
</br>
</br>
## VirtuosoClientDownloadEngine.framework
If you embed the framework directly (vs using CocoaPods) you will need to change several build settings as follows:

### Setup
This demo comes pre-configured with a license that works only for this app.  To configure the SDK in your own app, contact support@penthera.com.  To update the license:

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
