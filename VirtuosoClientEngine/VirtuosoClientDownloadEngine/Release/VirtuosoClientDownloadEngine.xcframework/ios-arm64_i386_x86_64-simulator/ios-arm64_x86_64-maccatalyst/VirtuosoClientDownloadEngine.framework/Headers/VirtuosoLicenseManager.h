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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 *
 */
#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoDefaultAVAssetResourceLoaderDelegate.h>

/*!
*  @typedef VirtuosoLicenseConfiguration
*
*  @abstract Configuration object used to initialize LicenseManager
*/
@interface VirtuosoLicenseConfiguration : NSObject

/*!
*  @abstract  A URL suffix to be appended to the base license URL.
*/
@property (nonatomic, strong)NSString* _Nullable urlSuffix;

/*!
*  @abstract  A NSDate timestamp indicating when the license should be renewed
*/
@property (nonatomic, strong)NSDate* _Nullable renewalDate;

/*!
*  @abstract   A dictionary of key-value pairs to be added to the license request as URL parameters
*/
@property (nonatomic, strong)NSDictionary* _Nullable customParameters;

/*!
*  @abstract    A dictionary of key-value pairs to be added to the DRM request headers
*/
@property (nonatomic, strong)NSDictionary* _Nullable customHeaders;

/*!
*  @abstract Creates License configuration object with specified parameters
*
*  @param suffix        A URL suffix to be appended to the base license URL.
*  @param renewal      A NSDate timestamp indicating when the license should be renewed
*  @param parameters A dictionary of key-value pairs to be added to the license request as URL parameters
*  @param headers    A dictionary of key-value pairs to be added to the DRM request headers
**/
-(instancetype _Nullable )initWithSuffix:(NSString* _Nullable)suffix
                                 renewal:(NSDate* _Nullable)renewal
                              parameters:(NSDictionary* _Nullable)parameters
                                 headers:(NSDictionary* _Nullable)headers;

@end

@class VirtuosoAsset;

@protocol VirtuosoAVAssetResourceLoaderDelegate;

/*!
 *  @typedef LicenseRefreshComplete
 *
 *  @abstract Callback method invoked when a DRM license refresh is completed.
 */
typedef void (^LicenseRefreshComplete)(Boolean);

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
 *  @abstract  Allows custom processing of the SPC license request and the license response
 */
@protocol VirtuosoLicenseProcessingDelegate <NSObject>

/*!
 *  @abstract Allows a custom CID to be used with the SDK default AVAssetResourceLoaderDelegate
 *
 *  @discussion Normally, the asset CID is extracted from the FairPlay license URL, which takes the form
 *              skd://<contentID>.  Some license servers put the required content ID elsewhere.  If you
 *              don't need to adjust the content ID, you can return nil and the SDK will use the default value
 *              it detects.  If you need to override this value, you can return the proper content ID to use from
 *              this method.
 *
 *  @param asset The VirtuosoAsset the licensing request is for
 *  @param fpRequest The URL provided to the AVAssetResourceLoaderDelegate for the licensing request
 *  @return The CID value to use during SPC creation
 */
- (NSString* _Nullable)extractCIDForAsset:(VirtuosoAsset* _Nonnull)asset fromFairPlayRequest:(NSURL* _Nonnull)fpRequest;

/*!
 *  @abstract Allows custom processing of the FairPlay POST body before it is send.
 *
 *  @discussion Normally, the SPC data is posted as binary as the POST body to the fairplay server.
 *              If this is the case, you can just return the spc input without modification.  If your
 *              server requires some custom format (base64 encoding or JSON wrapping, for example), then you
 *              should receive the input SPC and return an NSData object suitable for posting in the POST body
 *              to your licensing server.
 *
 *  @param asset The VirtuosoAsset the licensing request is for
 *  @param spc The Apple-generated SPC data value
 *  @return An NSData object suitable for the license server POST body
 */
- (NSData* _Nullable)prepareSPCForAsset:(VirtuosoAsset* _Nonnull)asset inLicenseRequest:(NSData* _Nonnull)spc;

/*!
 *  @abstract Allows custom processing of the FairPlay license server response
 *
 *  @discussion Normally, the license server responds to a FairPlay request with binary representing
 *              the license response (CKC).  Some license servers wrap this CKC data with other encodings,
 *              such as base64 or JSON wrappers.  If your license server returns something other than raw
 *              CKC data, you will need to implement this method.  You should parse the response data and return
 *              the raw CKC data object, suitable for handing back to the player in the AVASsetResourceLoaderDelegate response.
 *
 *  @param asset The VirtuosoAsset the licensing request is for
 *  @param response The received response from the license server
 *  @return CKC data value suitable for handing to the player for DRM licensing
 */
- (NSData* _Nullable)extractCKCForAsset:(VirtuosoAsset* _Nonnull)asset inLicenseResponse:(NSData* _Nonnull)response;

@optional
/*!
* @abstract If you have configured custom DRM Types, this method allows you to indicate which to use for processing this asset.
*
* @discussion Normally, the resource loader will use the kVLM_FairPlay DRM type to process all requests using the configuration
*                           stored in the VirtuosoLicenseManager.  However, if you need to use different DRM systems for different assets you
*                           wish to download, you can set configuratins with VirtuosoLicenseManager using custom DRM type codes and
*                           implement this method to indicate which DRM SubType should be used for the asset. The SubType is an arbitrary, non-nil string that uniquely identifies ths DRM system.
*
*
*  @param asset The VirtuosoAsset to resolve DRM SubType for.
*  @return non-nil string ideitifying the DRM SubType for the Asset.
*/
- (NSString* _Nullable)drmSubTypeForAsset:(VirtuosoAsset* _Nonnull)asset;

@end

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
 *  @param customHeaders    A dictionary of key-value pairs to be added to the DRM request headers
 *  @param renewalDate      A NSDate timestamp indicating when the license should be renewed
 *  @param asset            The asset requiring an offline playback license
 */
- (void)lookupLicenseURLSuffix:(NSString* _Nonnull * _Nullable)urlSuffix
                 andParameters:(NSDictionary* _Nonnull * _Nullable)customParameters
             additionalHeaders:(NSDictionary* _Nonnull * _Nullable)customHeaders
                   renewalDate:(NSDate* _Nonnull * _Nullable)renewalDate
                      forAsset:(VirtuosoAsset* _Nonnull)asset;

-(VirtuosoLicenseConfiguration* _Nullable)lookupLicenseForAsset:(VirtuosoAsset* _Nonnull)asset;

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
 *  @param url The URL to the license server for the given DRM type, a nil value will remove the license server URL.
 *  @param type The DRM type to configure
 */
+ (void)setLicenseServerURL:(NSString* _Nullable)url forDRM:(kVLM_DRMType)type;
/*!
*  @abstract Sets the license server URL for a particular DRM type
*
*  @param url The URL to the license server for the given DRM type
*  @param type The DRM type to configure
*  @param subType String identifying the DRM subtype
 */
+ (void)setLicenseServerURL:(NSString* _Nonnull)url forDRM:(kVLM_DRMType)type andSubType:(NSString* _Nonnull)subType;
/*!
 *  @abstract Retrieves the configured license server URL for a particular DRM type
 *
 *  @param type The DRM type to retrieve the license URL for
 *
 *  @return The configured license server URL for the given DRM type
 */
+ (nullable NSString*)licenseServerURLForDRM:(kVLM_DRMType)type;

/*!
*  @abstract Retrieves the configured license server URL for a particular DRM type
*
*  @param type The DRM type to retrieve the license URL for
*  @param subType String identifying the DRM subtype
*
*  @return The configured license server URL for the given DRM type
*/
+ (nullable NSString*)licenseServerURLForDRM:(kVLM_DRMType)type andSubType:(NSString* _Nullable)subType;

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
*  @abstract Downloads the client app certificate from the provided URL
*
*  @discussion As a part of DRM processing, some DRM platforms require a client security
*              certificate.  Best practices dictate that this certificate is not hard-coded
*              in the client app.  This method is used to load the required client app
*              certificate from a remote location.
*
*  @param url The URL to the client app certificate
*  @param type The DRM type to configure
*  @param subType String identifying the DRM subtype
*/
+ (void)downloadClientAppCertificateFromURL:(nonnull NSString*)url forDRM:(kVLM_DRMType)type andSubType:(NSString* _Nonnull)subType;

/*!
 *  @abstract Sets the client app certificate from a previously downloaded or internal source
 *
 *
 *  @discussion As a part of DRM processing, some DRM platforms require a client security
 *              certificate.  Best practices dictate that this certificate is not hard-coded
 *              in the client app.  This method is used to load the required client app
 *              certificate from a remote location.
 *
 *  @param certificate The data representing the client app certificate. If this parameter is nil the certificate is removed.
 *  @param type The DRM type to configure
 */
+ (void)setClientAppCertificate:(NSData* _Nullable)certificate forDRM:(kVLM_DRMType)type;
/*!
*  @abstract Sets the client app certificate from a previously downloaded or internal source
*
*
*  @discussion As a part of DRM processing, some DRM platforms require a client security
*              certificate.  Best practices dictate that this certificate is not hard-coded
*              in the client app.  This method is used to load the required client app
*              certificate from a remote location.
*
*  @param certificate The data representing the client app certificate. If this parameter is nil the certificate is removed.
*  @param type The DRM type to configure
*  @param subType String identifying the DRM subtype
*/
+ (void)setClientAppCertificate:(NSData* _Nullable)certificate forDRM:(kVLM_DRMType)type andSubType:(NSString* _Nonnull)subType;
/*!
 *  @abstract Retrieves the previously downloaded client app security certificate, if it exists
 *
 *  @param type The DRM type to configure
 *
 *  @return The client app security certificate, if it exists, for the given DRM type
 */
+ (nullable NSData*)clientAppCertificateForDRM:(kVLM_DRMType)type;
/*!
*  @abstract Retrieves the previously downloaded client app security certificate, if it exists
*
*  @param type The DRM type to configure
*  @param subType String identifying the DRM subtype
*
*  @return The client app security certificate, if it exists, for the given DRM type
*/
+ (nullable NSData*)clientAppCertificateForDRM:(kVLM_DRMType)type andSubType:(nullable NSString*)subType;
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
 *
 *  @return Boolean true if success
 *
 */
+ (Boolean)downloadOfflineLicenseForAsset:(nonnull VirtuosoAsset *)asset;

/*!
 *  @abstract Indicates whether the license for the given asset needs to be refreshed
 *
 *  @discussion Assets with pass through protection will always return false
 *
 *  @param asset The asset to query refreshing DRM licensing for
 *
 *  @return Boolean true if downloaded license needs to be refreshed
 */
+ (BOOL)doesLicenseForAssetRequireRefresh:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Asynchronously refreshes any previously downloaded license for the given asset
 *
 *  @param asset The asset to refresh DRM licensing for
 *  @param onComplete A block to call when DRM licenses have been refreshed. This block will be called on a background thread. If you need to access the main thread, make sure to switch contexts.
 */
+ (void)refreshLicenseForAsset:(nonnull VirtuosoAsset*)asset whenComplete:(nullable LicenseRefreshComplete)onComplete;

/*!
 *  @abstract Synchronously refreshes any previously downloaded license for the given asset
 *
 *  @param asset The asset to refresh DRM licensing for
 */
+ (void)refreshLicenseForAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Asynchronously deletes any previously downloaded license for the given asset
 *
 *  @param asset The asset to remove DRM licensing for
 *  @param onComplete A block to call when DRM licenses have been removed
 */
+ (void)removeLicenseForAsset:(nonnull VirtuosoAsset*)asset whenComplete:(nullable void (^)(void))onComplete;

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
 *  @abstract Configures the VirtuosoLicenseManager to utilize a particular AVContentKeySession for licensing
 *
 *  @discussion Methods in VirtuosoLicenseManager that reference AVContentKeySession APIs should be used for all devices
 *              on iOS >= iOS 11.0.  If you are supporting devices lower than iOS 11.0, implementing the methods for
 *              AVAssetResourceLoaderDelegate may also be required.  If you use the default Virtuoso implementations
 *              then the appropriate method is chosen automtically for you.
 *
 *              By default, the VirtuosoLicenseManager will automatically use an internal AVContentKeySession for
 *              DRM licensing and playback.  Calling this method allows you to specify an alternate version for these operations.
 *
 *  @param avContentKeySession An AVContentKeySession to use for internal DRM operations
 */
+ (void)registerAVContentKeySession:(nonnull AVContentKeySession*)avContentKeySession API_AVAILABLE(ios(10.3));

/*!
 *  @abstract Returns the currently configured AVContentKeySession
 *
 *  @return The currently configured AVContentKeySession
 */
+ (nonnull AVContentKeySession*)registeredAVContentKeySession API_AVAILABLE(ios(10.3));

/*!
 *  @abstract Configures the VirtuosoLicenseManager to utilize a particular AVAssetResourceLoaderDelegate class
 *
 *  @discussion Starting in iOS 11, Apple will only be adding new FairPlay features to AVContentKeySession DRM implementations.
 *              We strongly recommend updating to AVContentKeySession for DRM if you are only supporting iOS 11 and higher.
 *              Access to functions like dual expiry licenses are only available via that implementation.  Penthera cannot guarantee
 *              how long AVAssetResourceLoaderDelegate implementations will remain supported by Apple.
 *
 *              By default, the VirtuosoLicenseManager will automatically create and use instances of the
 *              DefaultVirtuosoAVAssetResourceLoaderDelegate for DRM licensing and playback.  Calling this method allows
 *              you to specify an alternate custom class for these operations.
 *
 *  @param resourceLoaderDelegateClass A Class instance type to use for internal AVAssetResourceLoaderDelegate operations
 *
 *  @deprecated Replaced with registerAVContentKeySession
*/
+ (void)registerAVAssetResourceLoaderDelegate:(nonnull Class<VirtuosoAVAssetResourceLoaderDelegate>)resourceLoaderDelegateClass  __attribute__((deprecated("See registerAVContentKeySession.")));

/*!
 *  @abstract Remvoes previously configured AVAssetResourceLoaderDelegate class
*/
+ (void)removeAVAssetResourceLoaderDelegate;

/*!
 *  @abstract Returns the currently configured AVAssetResourceLoaderDelegate class
 *
 *  @return The currently configured AVAssetResourceLoaderDelegate class
 *
 *  @deprecated Replaced with registerAVContentKeySession
 */
+ (nonnull Class<VirtuosoAVAssetResourceLoaderDelegate>)registeredAVAssetResourceLoaderDelegate  __attribute__((deprecated("See registerAVContentKeySession.")));

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

/*!
 *  @abstract Sets the license processing delegate
 *
 *  @discussion Some DRM implementations require that an additional unique asset license ID be appended
 *              to the license server URL.  Some DRM implementations may also require that an additional
 *              token parameter is included as a property on the license server url.  If you need to provide
 *              these values, set the delegate here and Virtuoso will ask for them as needed.
 *
 *  @param delegate The delegate that will provide license ID and license token lookups
 */
+ (void)setLicenseProcessingDelegate:(nullable id<VirtuosoLicenseProcessingDelegate>)delegate;

+ (nullable id<VirtuosoLicenseProcessingDelegate>)licenseProcessingDelegate;

@end
