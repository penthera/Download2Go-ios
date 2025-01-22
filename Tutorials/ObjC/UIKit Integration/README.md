VirtuosoUIKit
=======================================

VirtuosoUIKit is an example of general best practice for integrating your
user interface with the SDK.  It is used as a common library throughout 
the Objective C tutorials to simplify the tutorial code and aid in understanding
SDK usage. 

Currently, VirtuosoUIKit supports the following basic classes to work with:

* UIAncillaryImageView - A subclass of UIImageView that automatically loads an
                         ancillary image (based on a tag) once the asset has 
                         downloaded it.
                         
* UIAssetPauseSwitch - A subclass of UISwitch that pauses/unpauses download of
                       an individual asset.
                       
* UIAssetProgressView - A subclass of UIProgressView that automatically displays 
                        the download progress of an asset.
                        
* UIAssetStatusLabel - A label that displays formatted status information about
                       an asset.
                       
* UIDownloadButton - A button that starts a download, or deletes an already started
                     download.
                     
* UIPlayButton - A button that automatically enables itself when an asset is playbable
                 and plays the asset when clicked.
                 
