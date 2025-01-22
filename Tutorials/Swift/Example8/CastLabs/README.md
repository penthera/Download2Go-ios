Tutorial - Example8.2: CastLabs DRM
=======================================
## Summary
This sample demonstrates setup of CastLabs DRM
</br>
</br>
Several source code variables have to be setup for this Tutorial to work.

* private var sampleAssetManifestUrl: String? = nil
* private var sampleAssetType = kVDE_AssetType.vde_AssetTypeHLSsampleAssetManifestUrl
* private var certificateUrl: String? = nil
* private var licenseUrl: String? = nil
* private var authenticationXml: String? = nil
* private var userID: String? = nil
* private var customerName: String? = nil
* private var sessionID: String? = nil

##### sampleAssetManifestUrl:
This should be set to the URL of the sample Asset using BuyDRM

##### sampleAssetType:
This should be set to match the asset type (HLS, HSS, DASH)

##### certificateUrl:
URL to download the client FairPlay certificate

##### licenseUrl:
URL to the license server for FairPlay

##### authenticationXml:
The authentication XML required by BuyDRM

##### userID:
CastLabs userID property

##### customerName:
CastLabs customerName property

##### sessionID:
CastLabs sessionID property


</br>

</br>
</br>

## XCode Setup
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
