/*!
 *  @header VirtuosoLicenseManager
 *
 *  PENTHERA CONFIDENTIAL
 *
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  @copyright (c) 2016 Penthera Inc. All Rights Reserved.
 *
 */
#import <Foundation/Foundation.h>

@class VirtuosoAsset;
@protocol VirtuosoAVAssetResourceLoaderDelegate;

/*!
 *  @typedef kVLM_DRMType
 *
 *  @abstract DRM types internally supported by Virtuoso
 */
typedef NS_ENUM(NSInteger, kVLM_DRMType)
{
    /** DRM provided by Apple FairPlay */
    kVLM_FairPlay = 0,
    
    /** DRM provided by Google Widevine */
    kVLM_Widevine = 1,
};

/*!
 *  @abstract Delegate used to request optional license parameters for license aquisition
 *
 *  @discussion Some DRM implementations require that an additional unique asset license ID be appended
 *              to the license server URL.  Some DRM implementations may also require that an additional
 *              token parameter is included as a property on the license server url.  Both of these values
 *              are optional, and if you pass nil, or do not set the delegate, they will not be used.  
 *              If you do pass these values, the resulting license server request will be in the 
 *              format <license_server_base_url>/<licenseID>?token=<licenseToken>.
 */
@protocol VirtuosoLicenseManagerDelegate <NSObject>

/*!
 *  @abstract Requests optional license parameters for license aquisition
 *
 *  @discussion Some DRM implementations require that an additional unique URL suffix be appended
 *              to the license server URL.  Some DRM implementations may also require that an additional
 *              custom parameters be included on the license server url.  Both of these values
 *              are optional, and if you pass nil, they will not be used.  If you do pass these values, the
 *              resulting license server request will be in the format <license_server_base_url>/<url_suffix>?<parameters>.
 *
 *              Note that the parameters for both values are pointers to pointers.  To provide
 *              the values, set your desired values to the dereferenced parameter (See the SDK Demo app for an 
 *              example).
 *
 *  @param urlSuffix        A URL suffix to be appended to the base license URL.
 *  @param customParameters A dictionary of key-value pairs to be added to the license request as URL parameters
 *  @param asset            The asset requiring an offline playback license
 */
- (void)lookupLicenseURLSuffix:(NSString* _Nonnull * _Nullable)urlSuffix
                 andParameters:(NSDictionary* _Nonnull * _Nullable)customParameters
                      forAsset:(VirtuosoAsset* _Nonnull)asset;

@end


/*!
 *  @abstract VirtuosoLicenseManager is a static class that handles interactions with DRM platforms.
 */
@interface VirtuosoLicenseManager : NSObject

/*!
 *  @abstract Indicates whether built-in DASH video playback and Widevine DRM is available
 */
+ (BOOL)widevineAvailable;

/*!
 *  @abstract Indicates whether FairPlay DRM for streaming video is available
 */
+ (BOOL)fairplayStreamingAvailable;

/*!
 *  @abstract Indicates whether FairPlay DRM for downloaded video is available
 */
+ (BOOL)fairplayPersistenceAvailable;

/*!
 *  @abstract Sets the license server URL for a particular DRM type
 *
 *  @param url The URL to the license server for the given DRM type
 *  @param type The DRM type to configure
 */
+ (void)setLicenseServerURL:(nonnull NSString*)url forDRM:(kVLM_DRMType)type;

/*!
 *  @abstract Retrieves the configured license server URL for a particular DRM type
 *
 *  @param type The DRM type to retrieve the license URL for
 *
 *  @return The configured license server URL for the given DRM type
 */
+ (nullable NSString*)licenseServerURLForDRM:(kVLM_DRMType)type;

/*!
 *  @abstract Downloads the client app certificate from the provided URL
 *
 *  @discussion As a part of DRM processing, some DRM platforms require a client security
 *              certificate.  Best practices dictate that this certificate is not hard-coded
 *              in the client app.  This method is used to load the required client app 
 *              certificate from a remote location.
 *
 *  @param url The URL to the client app certificate
 *  @param type The DRM type to configure
 */
+ (void)downloadClientAppCertificateFromURL:(nonnull NSString*)url forDRM:(kVLM_DRMType)type;

/*!
 *  @abstract Retrieves the previously downloaded client app security certificate, if it exists
 *
 *  @param type The DRM type to configure
 *
 *  @return The client app security certificate, if it exists, for the given DRM type
 */
+ (nullable NSData*)clientAppCertificateForDRM:(kVLM_DRMType)type;

/*!
 *  @abstract Downloads a DRM playback license for later offline playback
 *
 *  @discussion This method is called automatically by the Virtuoso SDK at appropriate times.  You may use
 *              this method yourself to manually download or renew a DRM license.
 *
 *              The implementation of this method will instantiate a copy of the registered
 *              VirtuosoAVAssetResourceLoaderDelegate.  The registered delegate class should call
 *              the VirtuosoLicenseManager licenseForAsset: and setLicense:forAsset: methods to
 *              properly access or register the generated license.
 *
 *              If the DRM implementation requires a license ID or token to acquire the license, you must
 *              set these parameters via setID:andLicenseToken: prior to calling this method.
 *
 *  @param asset The asset requiring an offline playback license
 */
+ (void)downloadOfflineLicenseForAsset:(nonnull VirtuosoAsset *)asset;

/*!
 *  @abstract Asynchronously deletes any previously downloaded license for the given asset
 *
 *  @param asset The asset to remove DRM licensing for
 *  @param onComplete A block to call when DRM licenses have been removed
 */
+ (void)removeLicenseForAsset:(nonnull VirtuosoAsset*)asset whenComplete:(nullable void (^)())onComplete;

/*!
 *  @abstract Synchronously deletes any previously downloaded license for the given asset
 *
 *  @param asset The asset to remove DRM licensing for
 */
+ (void)removeLicenseForAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Returns the DRM license for the provided asset, or nil if a license does not exist
 *
 *  @param asset The asset to remove DRM licensing for
 *
 *  @return The DRM license for the asset, if it is accessible
 */
+ (nullable NSData*)licenseForAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Sets the DRM license for the provided asset
 *
 *  @param license The opaque DRM license data object for the asset
 *  @param asset   The asset to set DRM licensing for
 */
+ (void)setLicense:(nonnull NSData*)license forAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Configures the VirtuosoLicenseManager to utilize a particular AVAssetResourceLoaderDelegate class
 *
 *  @discussion By default, the VirtuosoLicenseManager will automatically create and use instances of the
 *              DefaultVirtuosoAVAssetResourceLoaderDelegate for DRM licensing and playback.
 *
 *              Calling this method allows you to specify an alternate custom class for these operations.
 *
 *  @param resourceLoaderDelegateClass A Class instance type to use for internal AVAssetResourceLoaderDelegate operations
 */
+ (void)registerAVAssetResourceLoaderDelegate:(nonnull Class<VirtuosoAVAssetResourceLoaderDelegate>)resourceLoaderDelegateClass;

/*!
 *  @abstract Returns the currently configured AVAssetResourceLoaderDelegate class
 *
 *  @return The currently configured AVAssetResourceLoaderDelegate class
 */
+ (nonnull Class<VirtuosoAVAssetResourceLoaderDelegate>)registeredAVAssetResourceLoaderDelegate;

/*!
 *  @abstract Sets the license manager delegate
 *
 *  @discussion Some DRM implementations require that an additional unique asset license ID be appended
 *              to the license server URL.  Some DRM implementations may also require that an additional
 *              token parameter is included as a property on the license server url.  If you need to provide
 *              these values, set the delegate here and Virtuoso will ask for them as needed.
 *
 *  @param delegate The delegate that will provide license ID and license token lookups
 */
+ (void)setDelegate:(nullable id<VirtuosoLicenseManagerDelegate>)delegate;

@end
