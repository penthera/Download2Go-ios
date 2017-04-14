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
 *  @discussion Some DRM implementations require that an additional unique asset license ID be appended
 *              to the license server URL.  Some DRM implementations may also require that an additional
 *              token parameter is included as a property on the license server url.  Both of these values
 *              are optional, and if you pass nil, they will not be used.  If you do pass these values, the
 *              resulting license server request will be in the format <license_server_base_url>/<licenseID>?token=<licenseToken>.
 *
 *              Note that the parameters for licenseID and licenseToken are pointers to pointers.  To provide
 *              the values, set your desired values to the dereferenced parameter (See the SDK Demo app for an 
 *              example).
 *
 *  @param licenseID An asset-unique DRM license ID
 *  @param licenseToken A unique token parameter to include as part of the DRM license request.
 *  @param asset The asset requiring an offline playback license
 */
- (void)lookupID:( NSString* _Nonnull * _Nullable)licenseID andLicenseToken:( NSString* _Nonnull * _Nullable)licenseToken forAsset:(VirtuosoAsset* _Nonnull)asset;

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
 */
+ (nullable NSData*)clientAppCertificateForDRM:(kVLM_DRMType)type;

/*!
 *  @abstract Downloads a DRM playback license for later offline playback
 *
 *  @discussion In order to insure the device has a local playback license, you should
 *              call this method as early as possible in the download lifecycle.  For
 *              Widevine protected assets, this method should be called when the download
 *              completes.  For FairPlay protected assets, this method should be called when
 *              the download begins.
 *
 *              If the DRM implementation requires a license ID or token to acquire the license, you must
 *              set these parameters via setID:andLicenseToken: prior to calling this method.
 *
 *  @param asset The asset requiring an offline playback license
 */
+ (void)downloadOfflineLicenseForAsset:(nonnull VirtuosoAsset *)asset;

/*!
 *  @abstract Deletes any previously downloaded license for the given asset
 *
 *  @param asset The asset to remove DRM licensing for
 *  @param onComplete A block to call when DRM licenses have been removed
 */
+ (void)removeLicenseForAsset:(nonnull VirtuosoAsset*)asset whenComplete:(nullable void (^)())onComplete;

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
