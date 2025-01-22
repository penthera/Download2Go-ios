Tutorial - Example1_1: Pause & Resume Active Download
=======================================
## Summary
This sample demonstrates pausing an asset while downloading.
</br>
</br>

## XCode Setup:

## React-Native:

1) From the tutorial root directory ``Example1_1`` install node_modules: ``npm install``
2) From the ``ios`` subdirectory install CocoaPods: ``pod install``

For information on the React-Native environment, visit https://facebook.github.io/react-native/docs/getting-started

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
You will need to create a bridging header (Swift Projects only). 
