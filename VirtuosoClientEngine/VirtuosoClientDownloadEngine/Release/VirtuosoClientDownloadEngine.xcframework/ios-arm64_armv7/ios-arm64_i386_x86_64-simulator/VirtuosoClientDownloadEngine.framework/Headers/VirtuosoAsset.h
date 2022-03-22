/*!
 *  @header VirtuosoAsset
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
 */

#ifndef VASSET
#define VASSET

#import <Foundation/Foundation.h>

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#endif

#import "VirtuosoConstants.h"
#import <VirtuosoClientDownloadEngine/VirtuosoVideoRendition.h>

#if IS_LIB==0
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>
#else
#import "VirtuosoPlayer.h"
#endif

@class VirtuosoAncillaryFile;
@class VirtuosoAdsProvider;
@class VirtuosoAssetConfig;

/*!
 *  @typedef AssetQueryCallback
 *
 *  @discussion Callback for findAsset methods
 *
 *  @param asset Reference to the asset, nil if not found.
 *  @param error If an error was encountered, most likely invalid parameter provided
 */
typedef void(^AssetQueryCallback)(VirtuosoAsset* _Nullable asset, NSError*  _Nullable error);

/*!
 *  @typedef AssetAdStatus
 *
 *  @abstract Asset Ads status
 */
typedef NS_ENUM(NSInteger, AssetAdStatus)
{
    /** Ads not initialized */
    AssetAdStatus_Uninitialized,
    
    /** Ads refresh in process */
    AssetAdStatus_RefreshInProcess,
    
    /** Ads refresh completed successfully */
    AssetAdStatus_RefreshComplete,
    
    /** Ads refresh completed with errors */
    AssetAdStatus_RefreshCompleteWithErrors,
    
    /** Ads refresh failed */
    AssetAdStatus_RefreshFailure,
    
    /** Ads refresh has been queued for refresh once Network is available. */
    AssetAdStatus_QueuedForRefresh,
    
    /** Ads have been downloaded.  Not all ad providers will set this state.*/
    AssetAdStatus_DownloadComplete,
    
    /** Ads are currently playing.*/
    AssetAdStatus_Playing
};

/**---------------------------------------------------------------------------------------
 * @name Download engine Delegates
 *  ---------------------------------------------------------------------------------------
 */
#pragma mark
#pragma mark Protocols
#pragma mark

/*!
 *  @abstract This delegate defines the methods that can be implemented
 *            to allow modification of Asset URL's before downloading.
 *
 *            This is an advanced feature which is entirely optional.
 */
@protocol VirtuosoPrepareUrlDelegate <NSObject>

@optional

/*!
 *  @abstract Allows modification of the main manifest download request before download happens.
 *
 *  @discussion Allows modification of the main manifest download request before download happens.
 *
 *  @param request NSMutableURLRequest
 *  @param asset Asset for which main manifest is being downloaded
 */
-(void)prepareManifestRequest:(NSMutableURLRequest* _Nonnull)request forAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Allows client layer to extract cookies following download of the main manifest.
 *
 *  @discussion Allows client layer to extract cookies following download of the main manifest.
 *
 *  @param response NSURLResponse
 *  @param asset Asset for which main manifest was downloaded
 */
-(void)processManifestResponse:(NSURLResponse* _Nonnull)response forAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Allows modification of the sub-manifest Url prior to download.
 *
 *  @discussion Fires during asset parsing, prior to the start of a download.
 *
 *  @param url The URL that is about to be downloaded.
 *  @param manifestType Type of sub-manifest for this URL.
 *  @param asset The VirtuosoAsset.
 *
 *  @return Return the updated url, or nil to use the original url.
 */
-(NSString* _Nullable)prepareSubManifestURL:(NSString* _Nonnull)url manifestType:(kVDM_ManifestType)manifestType forAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Allows modification of the Segment Url prior to download.
 *
 *  @discussion Fires during asset parsing, prior to the start of a download.
 *
 *  @param url The URL that is about to be downloaded.
 *  @param asset The VirtuosoAsset.
 *
 *  @return Return the updated url, or nil to use the original url.
 */
-(NSString* _Nullable)prepareSegmentURL:(NSString* _Nonnull)url forAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Allows modification of the video encryption key URL prior to download.
 *
 *  @discussion Fires during asset parsing, prior to the start of a download.
 *
 *  @param url The URL that is about to be downloaded.
 *  @param asset The VirtuosoAsset.
 *
 *  @return Return the updated url, or nil to use the original url.
 */
-(NSString* _Nullable)prepareEncryptionKeyURL:(NSString* _Nonnull)url forAsset:(VirtuosoAsset* _Nonnull)asset;

@end


/*!
 *  @abstract Basic completion block used generically in methods
 */
typedef void (^BasicCompletionBlock)(void);

/*!
*  @typedef IsPlayableCompleteBlock
*
*  @discussion Callback for VirtuosoAsset isPlayable methods
*
*  @param isPlayable Boolean indicating whether asset is currently playable
*/
typedef void (^IsPlayableCompleteBlock)(Boolean isPlayable);

/*!
 *  @abstract If set, this block is called whenever an asset is about to request data from
 *            a network resource.
 *
 *  @discussion Certain types of DRM or CDN may require that additional parameters be placed on URLs
 *              beyond what is contained in the asset manifest.  In some cases, those security tokens
 *              are dynamically generated and short lived.  If set, whenever Virtuoso is about to access
 *              a network resource, you can return additional URL parameters to include in the request
 *              in this block and they will be appended to the network URL.  If you do not need to use
 *              additional URL parameters, do not set this block.
 *
 *              In order to maximize performance, Virtuoso will store your returned response in memory.
 *              Therefore, this block may not be called for every network request, but it will be called
 *              as-needed.
 *
 *              The dictionary you return should include the URL parameter names as the keys and the
 *              parameter value as the values.
 */
typedef NSDictionary<NSString*,NSString*>*_Nullable(^RequestAdditionalParametersBlock)(VirtuosoAsset* _Nonnull asset);

/*!
 *  @abstract Basic completion block used generically in methods
 */
typedef void (^CompletionBlockWithOptionalError)(NSError* _Nullable);

/*!
 *  @abstract Represents a conceptual "file" object in Virtuoso.
 *
 *  @discussion A VirtuosoAsset may be a single physical file (E.G. MP4) or a conceptual "group"
 *              of many smaller file segments (E.G. HLS/HSS).
 *
 *  @warning You must never instantiate an object of this type directly.
 *           You can create a VirtuosoAsset object via the provided static constructor methods.
 *
 */
@interface VirtuosoAsset : NSObject

/**---------------------------------------------------------------------------------------
 * @name Maintenance And Storage Tracking
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Maintenance And Storage Tracking
#pragma mark

/*!
 *  @abstract Returns the total device storage (in bytes) currently used by all downloaded Virtuoso files
 *
 *  @discussion This property makes blocking calls to the file system for each asset. This is a slow process and will block UI refreshes, best practice is to make this call using a background thread.
 *
 *  @return The total device storage (in bytes) currently used by all downloaded Virtuoso files
 */
+ (long long)storageUsed;

/*!
 *  @abstract Returns the amount of device storage (in bytes) still available for Virtuoso to use
 *
 *  @discussion allowableStorageRemaining isn't the same as "free disk space." It's
 *              the amount of disk space Virtuoso can use without violating any storage constraints,
 *              e.g. max storage and headroom.
 *
 *              This property makes blocking calls to the file system for each asset. This is a slow process and will block UI refreshes, best practice is to make this call using a background thread.
 *
 *  @return The total disk space (in bytes) still available to Virtuoso for downloads
 */
+ (long long)allowableStorageRemaining;

/**---------------------------------------------------------------------------------------
 * @name Creation
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Creation
#pragma mark

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion Creates instance of VirtuosoAsset using the parameters in VirtuosoAssetConfig.
 *  The asset will be created and (config.autoAddToQueue = TRUE) then automatically added to the download queue.
  *
 *  @param config Instance of VirtuosoAssetConfig with properties set appropriately to download the Asset.
 *
 *  @return A new VirtuosoAsset object, or nil if an error occurred.
 */
+ (nullable VirtuosoAsset*)assetWithConfig:(nonnull VirtuosoAssetConfig*)config;

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion Creates instance of VirtuosoAsset using the parameters in VirtuosoAssetConfig and provide callbacks.
 *
 *  @param config Instance of VirtuosoAssetConfig with properties set appropriately to download the Asset.
 *
 *  @param readyBlock Called when the asset is ready to be added to the download queue
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 *
 *  @return A new VirtuosoAsset object, or nil if an error occurred.
 */
+ (nullable VirtuosoAsset*)assetWithConfig:(nonnull VirtuosoAssetConfig*)config
                           onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                              onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/**---------------------------------------------------------------------------------------
 * @name Creation (Deprecated)
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Creation (Deprecated)
#pragma mark

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion One of several constructors for creating an in-memory VirtuosoAsset object.
 *              This one relies on the default expiry-after-download and expiry-after-play rules.
 *              This is a blocking call, avoid using this method from MainThread
 *
 *  @warning The SDK does not check or prevent download of Assets with codec not supported by hardware on the device.
 *
 *  @param assetURL The remote URL for the file (where to download from).
 *
 *  @param assetID A globally unique identifier for the asset. Used in all log events.
 *                 IMPORTANT: This value must be globally unique across all assets within the Catalog.
 *                 Dupicate AssetID's are not allowed.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param publishDate Virtuoso will not provide API access to the asset until this date. Nil means "now."
 *
 *  @param expiryDate Virtuoso will not provide API access to the asset after this date. Nil means no expiry.
 *
 *  @param assetDownloadLimit Virtuoso applies this value instead of the backplane-defined global asset download limit
 *                            A value < 0 means to use the backplane defined value.  A value of 0 means unlimited.  A
 *                            value > 0 will be applied to download permissions checks for this asset.
 *
 *  @param enableFastPlay If enabled, Virtuoso will automatically download the initial portion of the asset as soon
 *                        as the asset is created.  Whenever an asset is streamed, the cached beginning of the asset
 *                        will be returned to the player immediatley, eliminating startup buffer time for streamed playback.
 *
 *  @param userInfo A convenience field allowing you to associate arbitrary data with an asset.
 *                  Virtuoso will serialize this data and store it, but not explicitly use this data.
 *                  The provided userInfo must be property-list compatible. May be nil.
 *
 *  @param readyBlock Called when the asset is ready to be added to the download queue
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 *
 *  @return A new VirtuosoAsset object, or nil if an error occurred.
  *
  *  @deprecated This method has been deprecated and replaced by VirtuosoAsset method assetWithConfig.
 */

+ (nullable VirtuosoAsset*)assetWithRemoteURL:(nonnull NSString*)assetURL
                                      assetID:(nonnull NSString*)assetID
                                  description:(nonnull NSString*)description
                                  publishDate:(nullable NSDate*)publishDate
                                   expiryDate:(nullable NSDate*)expiryDate
                           assetDownloadLimit:(int)assetDownloadLimit
                               enableFastPlay:(Boolean)enableFastPlay
                                     userInfo:(nullable NSDictionary*)userInfo
                           onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                              onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock __attribute__((deprecated("method replaced by  assetWithConfig.")));

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion One of several constructors for creating an in-memory VirtuosoAsset object.
 *              This constructor sets the expiry after download and play intervals explicitly.
 *              This is a blocking call, avoid using this method from MainThread
 *
 *  @warning The SDK does not check or prevent download of Assets with codec not supported by hardware on the device.
 *
 *  @param assetURL The remote URL for the file (where to download from).
 *
 *  @param assetID A globally unique identifier for the asset. Used in all log events.
 *                 IMPORTANT: This value must be globally unique across all assets within the Catalog.
 *                 Dupicate AssetID's are not allowed.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param publishDate Virtuoso will not provide API access to the asset until this date. Nil means "now."
 *
 *  @param expiryDate Virtuoso will not provide API access to the asset after this date. Nil means no expiry.
 *
 *  @param expiryAfterDownload Amount of time after Virtuoso completes download of asset that
 *                             Virtuoso will delete the asset. In seconds.  <=0.0 means no expiry.
 *
 *  @param expiryAfterPlay Amount of time after the asset is first played that
 *                         Virtuoso will delete the asset. In seconds.  <=0.0 means no expiry.
 *
 *  @param assetDownloadLimit Virtuoso applies this value instead of the backplane-defined global asset download limit
 *                            A value < 0 means to use the backplane defined value.  A value of 0 means unlimited.  A
 *                            value > 0 will be applied to download permissions checks for this asset.
 *
 *  @param enableFastPlay If enabled, Virtuoso will automatically download the initial portion of the asset as soon
 *                        as the asset is created.  Whenever an asset is streamed, the cached beginning of the asset
 *                        will be returned to the player immediatley, eliminating startup buffer time for streamed playback.
 *
 *  @param userInfo A convenience field allowing you to associate arbitrary data with an asset.
 *                  Virtuoso will serialize this data and store it, but not explicitly use this data.
 *                  The provided userInfo must be property-list compatible. May be nil.
 *
 *  @param readyBlock Called when the asset is ready to be added to the download queue
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 *
 *  @return A new VirtuosoAsset object, or nil if an error occurred.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoAsset method assetWithConfig.
 */
+ (nullable VirtuosoAsset*)assetWithRemoteURL:(nonnull NSString*)assetURL
                                      assetID:(nonnull NSString*)assetID
                                  description:(nonnull NSString*)description
                                  publishDate:(nullable NSDate*)publishDate
                                   expiryDate:(nullable NSDate*)expiryDate
                          expiryAfterDownload:(NSTimeInterval)expiryAfterDownload
                              expiryAfterPlay:(NSTimeInterval)expiryAfterPlay
                           assetDownloadLimit:(int)assetDownloadLimit
                               enableFastPlay:(Boolean)enableFastPlay
                                     userInfo:(nullable NSDictionary*)userInfo
                           onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                              onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock __attribute__((deprecated("method replaced by  assetWithConfig.")));

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion One of several constructors for creating an in-memory VirtuosoAsset object.
 *              This constructor sets the expiry after download and play intervals explicitly.
 *              This is a blocking call, avoid using this method from MainThread
 *
 *  @warning The SDK does not check or prevent download of Assets with codec not supported by hardware on the device.
 *
 *  @param assetURL The remote URL for the file (where to download from).
 *
 *  @param assetID A globally unique identifier for the asset. Used in all log events.
 *                 IMPORTANT: This value must be globally unique across all assets within the Catalog.
 *                 Dupicate AssetID's are not allowed.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param publishDate Virtuoso will not provide API access to the asset until this date. Nil means "now."
 *
 *  @param expiryDate Virtuoso will not provide API access to the asset after this date. Nil means no expiry.
 *
 *  @param expiryAfterDownload Amount of time after Virtuoso completes download of asset that
 *                             Virtuoso will delete the asset. In seconds.  <=0.0 means no expiry.
 *
 *  @param expiryAfterPlay Amount of time after the asset is first played that
 *                         Virtuoso will delete the asset. In seconds.  <=0.0 means no expiry.
 *
 *  @param assetDownloadLimit Virtuoso applies this value instead of the backplane-defined global asset download limit
 *                            A value < 0 means to use the backplane defined value.  A value of 0 means unlimited.  A
 *                            value > 0 will be applied to download permissions checks for this asset.
 *
 *  @param enableFastPlay If enabled, Virtuoso will automatically download the initial portion of the asset as soon
 *                        as the asset is created.  Whenever an asset is streamed, the cached beginning of the asset
 *                        will be returned to the player immediatley, eliminating startup buffer time for streamed playback.
 *
 *  @param ancillaries Optional array of VirtuosoAncillaryFile to be downloaded
 *
 *  @param adsProvider Optional AdsProvider to use with this Asset.
 *
 *  @param userInfo A convenience field allowing you to associate arbitrary data with an asset.
 *                  Virtuoso will serialize this data and store it, but not explicitly use this data.
 *                  The provided userInfo must be property-list compatible. May be nil.
 *
 *  @param readyBlock Called when the asset is ready to be added to the download queue
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 *
 *  @return A new VirtuosoAsset object, or nil if an error occurred.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoAsset method assetWithConfig.
 */
+ (nullable VirtuosoAsset*)assetWithRemoteURL:(nonnull NSString*)assetURL
                                      assetID:(nonnull NSString*)assetID
                                  description:(nonnull NSString*)description
                                  publishDate:(nullable NSDate*)publishDate
                                   expiryDate:(nullable NSDate*)expiryDate
                          expiryAfterDownload:(NSTimeInterval)expiryAfterDownload
                              expiryAfterPlay:(NSTimeInterval)expiryAfterPlay
                           assetDownloadLimit:(int)assetDownloadLimit
                               enableFastPlay:(Boolean)enableFastPlay
                                  ancillaries:(nullable NSArray*)ancillaries
                                  adsProvider:(nullable VirtuosoAdsProvider*)adsProvider
                                     userInfo:(nullable NSDictionary*)userInfo
                           onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                              onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock __attribute__((deprecated("method replaced by  assetWithConfig.")));

/**---------------------------------------------------------------------------------------
 * @name Ancillaries
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Ancillaries
#pragma mark

/*!
 *  @abstract Adds an ancillary file to the download for this asset
 *
 *  @param file VirtuosoAncillaryFile object describing the file to be downloaded
 *
 *  @return Boolean indicating success or failure
 */
- (Boolean)addAncillaryFile:(VirtuosoAncillaryFile* _Nonnull)file;

/*!
 *  @abstract Adds an ancillary file to the download for this asset
 *
 *  @param file VirtuosoAncillaryFile object describing the file to be downloaded
 *  @param asset VirtuosoAsset object to add an ancillary file download to
 *
 *  @return Boolean indicating success or failure
 */
+ (Boolean)addAncillaryFile:(VirtuosoAncillaryFile* _Nonnull)file inAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Removes an ancillary file from this asset, deleting any download.
 *
 *  @param downloadUrl Ancillary file URL
 *
 *  @param completion optional callback which is invoked once the ancillary has been deleted.
 *
 *  @return Boolean indicating success or failure
 */
-(Boolean)removeAncillaryFile:(NSString* _Nonnull)downloadUrl completion:(CompletionBlockWithOptionalError _Nullable)completion;

/*!
 *  @abstract Retrieves all of the ancillary files assocated awith this asset
 *
 *  @discussion This is a BLOCKING call that will query CoreData for all ancillary files.
 *               See findAllCompleted for a non-blocking call.
 *
 *  @return Array of VirtuosoAncillaryFile objects. Empty if none.
 */
-(NSArray<VirtuosoAncillaryFile*>*_Nonnull)findAllAncillaries;

/*!
 *  @abstract Retrieves ancillary files with the specified tag for this asset
 *
 *  @discussion This is a BLOCKING call that will query CoreData for all ancillary files.
 *               See findAllCompleted for a non-blocking call.
 *
 *  @param tag The tag to filter on
 *
 *  @return Array of VirtuosoAncillaryFile objects with the specified tag. Empty if none.
 */
-(NSArray<VirtuosoAncillaryFile*>*_Nonnull)findAllAncillariesWithTag:(NSString* _Nonnull)tag;

/*!
 *  @abstract Retrieves ancillaries that have completed downloading.
 *
 *  @discussion This is a non-blocking call that will be faster than findAllAncillaries
 *               and it will only return Ancillaries that have downloaded.
 *
 *  @return Array of VirtuosoAncillaryFile objects. Empty if none.
 */
-(NSArray<VirtuosoAncillaryFile*>*_Nonnull)findCompletedAncillaries;

/*!
 *  @abstract Retrieves ancillaries that have completed downloading with the specified tag.
 *
 *  @discussion This is a non-blocking call that will be faster than findAllAncillariesWithTag
 *               and it will only return Ancillaries that have downloaded with the specified tag.
 *
 *  @param tag The tag to filter on
 *
 *  @return Array of VirtuosoAncillaryFile objects with the specified tag. Empty if none.
 */
-(NSArray<VirtuosoAncillaryFile*>*_Nonnull)findCompletedAncillariesWithTag:(NSString* _Nonnull)tag;



/**---------------------------------------------------------------------------------------
 * @name Retrieval
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Retrieval
#pragma mark

/*!
 *  @abstract Returns an array of all assets.  This method only returns non-ad content.
 *
 *  @discussion This method only returns non-ad content.  If the Caller wishes to retrieve ads,
 *              they must be instantiated by UUID after retrieving the ad load from an ad-supported
 *              asset.
 *              This is a blocking call, avoid using this method from MainThread
 *
 *  @param availabilityFilter Whether to filter the returned array against the availability window.
 *                            If NO, then all VirtuosoAsset objects are returned.
 *                            If YES, then Virtuoso filters out all assets that are unavailable,
 *                            based on their publishDate and expiry constraints.
 *
 *  @return An NSArray of VirtuosoAsset objects
 */
+ (nonnull NSArray*)assetsWithAvailabilityFilter:(Boolean)availabilityFilter;

/*!
 *  @abstract Returns an array of all pending (undownloaded) assets.  This method only returns non-ad content.
 *
 *  @discussion The returned content will be sorted by queue order first, and then by creation date.
 *
 *              This method only returns non-ad content.  If the Caller wishes to retrieve ads,
 *              they must be instantiated by UUID after retrieving the ad load from an ad-supported
 *              asset.
 *
 *  @param availabilityFilter Whether to filter the returned array against the availability window.
 *                            If NO, then all VirtuosoAsset objects are returned.
 *                            If YES, then Virtuoso filters out all assets that are unavailable,
 *                            based on their publishDate and expiry constraints.
 *
 *  @return An NSArray of VirtuosoAsset objects
 */
+ (nonnull NSArray*)pendingAssetsWithAvailabilityFilter:(Boolean)availabilityFilter;

/*!
 *  @abstract Returns an array of all completed (downloaded) assets.  This method only returns non-ad content.
 *
 *  @discussion The returned content will be sorted by download completion date.
 *
 *              This method only returns non-ad content.  If the Caller wishes to retrieve ads,
 *              they must be instantiated by UUID after retrieving the ad load from an ad-supported
 *              asset.
 *
 *  @warning An asset in this array does not necessarily have the asset data on disk.  If business rules have
 *           reset the asset (E.G. to enforce expiry) then the asset may be marked as completed, not not have any
 *           local data.  You should check the relevant asset properties (expiry, window) before attempting to play
 *           the asset.
 *
 *  @param availabilityFilter Whether to filter the returned array against the availability window.
 *                            If NO, then all VirtuosoAsset objects are returned.
 *                            If YES, then Virtuoso filters out all assets that are unavailable,
 *                            based on their publishDate and expiry constraints.
 *
 *  @return An NSArray of VirtuosoAsset objects
 */
+ (nonnull NSArray*)completedAssetsWithAvailabilityFilter:(Boolean)availabilityFilter;

/*!
 *  @abstract Lookup an asset by UUID.
 *
 *  @discussion Every asset has a UUID, which Virtuoso assigns to the asset when you instantiate it.
 *              The return value may be nil (if no object exists with the given UUID).
 *              This is a blocking call, avoid using this method from MainThread
 *
 *  @param uuid The UUID (universally unique identifier) corresponding to the asset
 *
 *  @param availabilityFilter Whether to filter the return value against the availability window.
 *                            If NO, then the asset will be returned if it exists.
 *                            If YES, then Virtuoso will return nil for the asset if it is unavailable,
 *                            based on its publishDate and expiry constraints.
 *
 *  @return An instantiated VirtuosoAsset object or nil, if the asset doesn't exist or is unavailable.
 */
+ (nullable VirtuosoAsset*)assetWithUUID:(nonnull NSString*)uuid availabilityFilter:(Boolean)availabilityFilter;

/*!
 *  @abstract Lookup an asset by assetID.
 *
 *  @discussion Each asset requires an assetID value, which you provided when you instantiated the asset.
 *              The returned object may be nil (if no object exists with the given assetID.)
 *              This is a blocking call, avoid using this method from MainThread
 *
 *  @param assetID The assetID corresponding to the asset
 *
 *  @param availabilityFilter Whether to filter the return value against the availability window.
 *                            If NO, then the asset will be returned if it exists.
 *                            If YES, then Virtuoso will return nil for the asset if it is unavailable,
 *                            based on its publishDate and expiry constraints.
 *
 *  @return An instantiated VirtuosoAsset object or nil, if the asset does not exist or is unavailable.
 */
+ (nullable VirtuosoAsset*)assetWithAssetID:(nonnull NSString*)assetID availabilityFilter:(Boolean)availabilityFilter;


/*!
 *  @abstract Lookup an asset by drmLicensePath
 *
 *  @discussion Each asset requires a drmLicensePath value, which you provided when you instantiated the asset.
 *              The returned object may be nil (if no asset exists with the given drmLicensePath)
 *
 *  @warning This method should only be invoked from a background thread to prevent iOS (Springboard) from terminating the app while blocking the UI thread.
 *
 *  @param drmLicensePath The drmLicensePath corresponding to the asset
 *
 *  @return An array of assets or nil, if the asset does not exist or is unavailable
 */

+ (nullable NSArray*)assetsWithDrmLicensePath:(nonnull NSString*)drmLicensePath;

/*!
*  @abstract Find an asset by UUID.
*
*  @discussion Every asset has a UUID, which Virtuoso assigns to the asset when you instantiate it.
*
*  @param uuid The UUID (universally unique identifier) corresponding to the asset
*
*  @param availabilityFilter Whether to filter the return value against the availability window.
*                            If NO, then the asset will be returned if it exists.
*                            If YES, then Virtuoso will return nil for the asset if it is unavailable,
*                            based on its publishDate and expiry constraints.
*
* @param callback AssetQueryCallback callback that is invoked when the asset is retrieved. Callback happens on callers NSOperationQueue
*                              If an error is encountered NSError will be set. If the asset was found a reference will be returned. If asset is nil, it was not found.
*/
+ (void)findAssetWithUUID:(nonnull NSString*)uuid
       availabilityFilter:(Boolean)availabilityFilter
            assetCallback:(nonnull AssetQueryCallback)callback;

/*!
*  @abstract Find an asset by UUID.
*
*  @discussion Every asset has a UUID, which Virtuoso assigns to the asset when you instantiate it.
*
*  @param uuid The UUID (universally unique identifier) corresponding to the asset
*
*  @param availabilityFilter Whether to filter the return value against the availability window.
*                            If NO, then the asset will be returned if it exists.
*                            If YES, then Virtuoso will return nil for the asset if it is unavailable,
*                            based on its publishDate and expiry constraints.
*
* @param queue NSNotificationQueue on which to make the callback. If nil is specified the SDK will use
*                          VirtuosoDownloadEngine.notificationQueue if non-nil, otherwise it will use NSOperationQueue.currentQueue
*
* @param callback AssetQueryCallback callback that is invoked when the asset is retrieved.
*                              If an error is encountered NSError will be set. If the asset was found a reference will be returned. If asset is nil, it was not found.
*/
+ (void)findAssetWithUUID:(nonnull NSString*)uuid
       availabilityFilter:(Boolean)availabilityFilter
                    queue:(nullable NSOperationQueue*)queue
            assetCallback:(nonnull AssetQueryCallback)callback;

/*!
*  @abstract Find an asset by assetID.
*
*  @discussion Each asset requires an assetID value, which you provided when you instantiated the asset.
*
*  @param assetID The assetID corresponding to the asset
*
*  @param availabilityFilter Whether to filter the return value against the availability window.
*                            If NO, then the asset will be returned if it exists.
*                            If YES, then Virtuoso will return nil for the asset if it is unavailable,
*                            based on its publishDate and expiry constraints.
*
* @param callback AssetQueryCallback callback that is invoked when the asset is retrieved. Callback happens on callers NSOperationQueue
*                              If an error is encountered NSError will be set. If the asset was found a reference will be returned. If asset is nil, it was not found.
*/
+ (void)findAssetWithAssetID:(nonnull NSString*)assetID
          availabilityFilter:(Boolean)availabilityFilter
               assetCallback:(nonnull AssetQueryCallback)callback;

/*!
*  @abstract Find an asset by assetID.
*
*  @discussion Each asset requires an assetID value, which you provided when you instantiated the asset.
*
*  @param assetID The assetID corresponding to the asset
*
*  @param availabilityFilter Whether to filter the return value against the availability window.
*                            If NO, then the asset will be returned if it exists.
*                            If YES, then Virtuoso will return nil for the asset if it is unavailable,
*                            based on its publishDate and expiry constraints.
*
* @param queue NSNotificationQueue on which to make the callback. If nil is specified the SDK will use
*                          VirtuosoDownloadEngine.notificationQueue if non-nil, otherwise it will use NSOperationQueue.currentQueue
*
* @param callback AssetQueryCallback callback that is invoked when the asset is retrieved.
*                              If an error is encountered NSError will be set. If the asset was found a reference will be returned. If asset is nil, it was not found.
*/
+ (void)findAssetWithAssetID:(nonnull NSString*)assetID
          availabilityFilter:(Boolean)availabilityFilter
                       queue:(nullable NSOperationQueue*)queue
               assetCallback:(nonnull AssetQueryCallback)callback;


/**---------------------------------------------------------------------------------------
 * @name Update And Delete
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Update and Delete
#pragma mark

/*!
 *  @abstract Reparses the main mainfest to add additional Audio, Closed Caption data, and download the changes.
 *
 *  @discussion The primary use case for this method would be to add additional Audio languages to the previous
 *              download. These new languages must be enabled in Settings.
 *
 *  @param completeBlock An optional block that will be called on completion. The callback block will be invoked once downloading
 *              is started but not necessarily before downloading has fully completed. Use VirtuosoDownloadEngineNotificationManager to monitor for download complete (downloadEngineDidFinishDownloadingAsset)
 *              
 *  @warning Asset manifest refresh is a time consuming operation and should not be invoked on MainThread unless the completeBlock is provided
 *              in order to ensure iOS does not terminate the app for not responding on MainThread. When the completeBlock is provided
 *              the refresh will happen on an async background thread and once complete the completeBlock will be invoked on the
 *              thread pool set for VirtuosoDownloadEngine.notificationQueue which defaults to MainThread if not otherwise set.
 *
 *  @return TRUE indicates the reparse was successfully started.
 */
-(Boolean)refreshManifestAndDownload:(AssetParsingCompletedBlock _Nullable)completeBlock;

/*!
 *  @abstract Refreshes the data in this object from the persistent data store
 *
 *  @discussion To ensure performance and thread-safety, Virtuoso objects are heavily cached.  Changes to
 *              one object instance are not guaranteed to be immediately reflected in other existing instances.
 *              Under most use cases, this will not be apparent, as Virtuoso always passes an updated object with
 *              each relevant notification.  But if you are storing instantiated objects externally to Virtuoso and are
 *              accessing property values that frequently change, such as fractionComplete or current size, then you
 *              may need to refresh the object to obtain the most up-to-date values.
 *
 *              If you pass a non-NULL completeBlock, then the method is asynchronous and will return
 *              immediately.  When the save has finished, the completion block will be called.  If you
 *              pass a NULL value for the completeBlock, then the save is synchronous.
 *
 *  @warning Asset refresh is a time consuming operation and should not be invoked on MainThread unless the completeBlock is provided
 *              in order to ensure iOS does not terminate the app for not responding on MainThread. When the completeBlock is provided
 *              the refresh will happen on an async background thread and once complete the completeBlock will be invoked on the
 *              thread pool set for VirtuosoDownloadEngine.notificationQueue which defaults to MainThread if not otherwise set.
 *
 *
 *  @param completeBlock An optional block that will be called when the refresh is complete
 */
- (void)refreshOnComplete:(nullable AsyncCompleteBlock)completeBlock;

/*!
 *  @abstract Persists the VirtuosoAsset object for later use
 *
 *  @discussion Virtuoso relies on in-memory caching to optimize performance.
 *              After making changes to an asset, you should call this method to ensure consistency.
 *              This method persists changes to the local instance of this object to disk.  Call refresh
 *              on an object to load up-to-date values from the persistent store into memory.
 *
 *              If you pass a non-NULL completeBlock, then the method is asynchronous and will return
 *              immediately.  When the save has finished, the completion block will be called.  If you
 *              pass a NULL value for the completeBlock, then the save is synchronous.
 *
 *  @param completeBlock An optional block that will be called when the refresh is complete
 */
- (void)saveOnComplete:(nullable AsyncCompleteBlock)completeBlock;

/*!
*  @abstract Deletes this asset
*
*  @discussion Deletes this asset.
*
*/
    
- (void)deleteAsset;

/*!
 *  @abstract Deletes this asset
 *
 *  @discussion Deletes this asset.  If you pass a non-NULL deletedBlock, then the method is
 *              asynchronous and will return immediately.  When the deletion has finished, the
 *              completion block will be called.  If you pass a NULL value for the deletedBlock,
 *              then the deletion is synchronous.
 *
 *  @warning Asset delete is a time consuming operation and should not be invoked on MainThread unless the completeBlock is provided
 *              in order to ensure iOS does not terminate the app for not responding on MainThread. When the completeBlock is provided
 *              the delete will happen on an async background thread and once complete the completeBlock will be invoked on the
 *              thread pool set for VirtuosoDownloadEngine.notificationQueue which defaults to MainThread if not otherwise set.
*
 *  @param deletedBlock Notifies that Virtuoso has finished deleting all asset resources from disk.
 */

- (void)deleteAssetOnComplete:(nullable AsyncCompleteBlock)deletedBlock;
    
/*!
 *  @abstract Deletes all assets.
 *
 *  @discussion Deletes all assets in the database. During delete, the Engine stops all parsing
 *              and downloading. Invoking deleteAll will remove all assets. Playlists will trigger downloads following deleteAll. This call will execute syncronously and should only be invoked from a background (non UI) thread because it will block and wait. If you do not want this method to trigger additional Playlist downloads you must first clear the playlist.
 */
+ (void)deleteAll;

/*!
 *  @abstract Deletes all assets from a supplied list of assets
 *
 *  @discussion Deletes assets asynchronously.  If you pass a non-NULL deletionsBlock,
 *              when all deletions have finished, the completion block will be called.
 *              For efficiency, backplane permissions are only updated after all assets
 *              have been deleted.
 *
 * @param assets Array of Assets to be deleted
 * @param completionBlock Block that is invoked upon completion of delete.
 */

+ (void)deleteAssets:(nonnull NSArray<VirtuosoAsset*>*)assets onComplete:(nullable AsyncCompleteBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Playback
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Playback
#pragma mark

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)

/*!
*  @abstract Check if asset is currently playable.
*
*  @discussion This method will return the same state as property isPlayable but will perform the check
*              in a thread-safe way which avoids SPRINGBOARD exceptions if the MainThread is blocked. The
*             the callback is invoked on MainThread.
*
*  @param asset Asset to play
*
*  @param callback Callback with a Boolean parameter indicating whether the Asset is Playable. See IsPlayableCompleteBlock.
*
*/
+(void)isPlayable:(VirtuosoAsset* _Nonnull)asset callback:(IsPlayableCompleteBlock _Nonnull)callback;

/*!
 *  @abstract Check if asset is currently playable.
 *
 *  @discussion This method will return the same state as property isPlayable but will perform the check
 *              in a thread-safe way which avoids SPRINGBOARD exceptions if the MainThread is blocked.
 *
 *  @param asset Asset to play
 *
 *  @param operationQueue NSOpertionQueue to be used for the callback.
 *
 *  @param callback Callback with a Boolean parameter indicating whether the Asset is Playable.
 *
 */
+(void)isPlayable:(VirtuosoAsset* _Nonnull)asset operationQueue:(NSOperationQueue* _Nonnull)operationQueue callback:(IsPlayableCompleteBlock _Nonnull)callback;

/*!
*  @abstract Check if asset is currently playable.
*
*  @discussion This method will return the same state as property isPlayable but will perform the check
*              in a thread-safe way which avoids SPRINGBOARD exceptions if the MainThread is blocked.
*
*  @param asset Asset to play
*
*  @param dispatchQueue DispatchQueue to be used for the callback.
*
*  @param callback Callback with a Boolean parameter indicating whether the Asset is Playable.
*
*/
+(void)isPlayable:(VirtuosoAsset* _Nonnull)asset dispatchQueue:(dispatch_queue_t _Nonnull)dispatchQueue callback:(IsPlayableCompleteBlock _Nonnull)callback;

/*!
 *  @abstract Plays this asset by presenting a standard MPMoviePlayerViewController from the
 *            specified parent view controller.
 *
 *  @discussion If all you need is the standard video player, this is the simplest mechanism to
 *              play an asset.  If your custom player follows the VirtuosoPlayer protocol, you can
 *              use the playFromViewController:usingPlayerClass method for playback. To play assets
 *              via a custom (perhaps DRM-enabled) video player, or if you require a more
 *              complex integration, use the VirtuosoClientHTTPServer class directly to setup playback.
 *
 *              This property requries blocking calls to CoreData. If accessed from MainThread, this call will
 *              block and wait for the call to complete BUT will run the MainThread NSRunLoop while the call
 *              completes. This may result in unusual sequencing of events in the UI Layer. For example, invoking
 *              this method in viewWillAppear may result in viewDidAppear executing before the call in viewWillAppear
 *              copletes executing the call to Asset.isPlayable. If critical initailzation is required i viewWillAppear is necessary
 *              before viewDidAppear is called, make sure that code is execute BEFORE invoking this method.
 *              Alternatively, invoke this method using async on the MainThread should resolve any timing issues.
 *
 * @warning     If the asset selected for Playback has not finished downloading, Penthera will make sure the asset is enabled for download (asset.paused = false), set the engine enabled for download, move the asset to top of queue, and will resume actively downloading the selected Asset if possible. This is necessary to reduce chances that Playback stalls while the asset is played. If these behaviors are not desired make sure the asset is not played until it has completed downloading.
 *
 *
 *  @param playbackType Whether to play the downloaded copy or the online copy
 *  @param parent    The parent view controller to present the movie player from
 *  @param onSuccess Called when playback succeeds
 *  @param onFail    Called when playback fails
 */
- (void)playUsingPlaybackType:(kVDE_AssetPlaybackType)playbackType fromViewController:(nonnull UIViewController*)parent
                    onSuccess:(nullable BasicCompletionBlock)onSuccess onFail:(nullable BasicCompletionBlock)onFail;

/*!
 *  @abstract Plays this asset using a custom player class.  You are responsible for presentation.
 *
 *  @discussion Provides a basic mechanism to play assets using a custom class that follows
 *              the VirtuosoPlayer protocol.  You are responsible for instantiating and configuring the player,
 *              and presenting it in the UI hierarchy after calling this method. To play assets
 *              via a custom (perhaps DRM-enabled) video player, or if you require a more
 *              complex integration, use the VirtuosoClientHTTPServer class directly.
 *
 * @warning     If the asset selected for Playback has not finished downloading, Penthera will make sure the asset is enabled for download (asset.paused = false), set the engine enabled for download, move the asset to top of queue, and will resume actively downloading the selected Asset if possible. This is necessary to reduce chances that Playback stalls while the asset is played. If these behaviors are not desired make sure the asset is not played until it has completed downloading.
 *
 *
 *  @param playbackType Whether to play the downloaded copy or the online copy
 *  @param player An object that follows the VirtuosoPlayer protocol.
 *  @param onSuccess Called when playback succeeds
 *  @param onFail    Called when playback fails
 */
- (void)playUsingPlaybackType:(kVDE_AssetPlaybackType)playbackType andPlayer:(nonnull id<VirtuosoPlayer>)player
                    onSuccess:(nullable BasicCompletionBlock)onSuccess onFail:(nullable BasicCompletionBlock)onFail;

#endif

/*!
 *  @abstract Called when playback finishes (the video player exits) to cleanup the session.
 *
 *  @discussion Should only be called if playback was started using playUsingPlaybackType:.  If you
 *              started playback using VirtuosoClientHTTPServer directly, you should call the shutdown
 *              method of that class instead.
 */
- (void)stoppedPlaying;


/**---------------------------------------------------------------------------------------
 * @name Download State
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Download State
#pragma mark

/*!
*  @abstract The internally defined maximum number of times the asset will be retried prior to reporting blocked
*
*  @discussion If Virtuoso fails to download an asset in the queue, it will retry the download this
*              number of times, before moving to the next item in the queue.  In this way,
*              Virtuoso cycles through the entire queue. Virtuoso will perform this
*              number of repeat attempts for each previously-failed download,
*              before stopping and reporting that the queue is blocked.
*
*  @see downloadRetryCount
*  @see maximumDownloadRetriesExceeded
*/
@property (nonatomic, readonly, class) NSInteger downloadRetryLimit;

/*!
 *  @abstract How many passes Virtuoso has made attempting to download this asset
 *
 *  @discussion If Virtuoso fails to download an asset in the queue, it will retry the download
 *              downloadRetryLimit times, before moving to the next item in the queue.  In this way,
 *              Virtuoso cycles through the entire queue. Virtuoso will perform downloadRetryLimit
 *              number of repeat attempts for each previously-failed download,
 *              before stopping and reporting that the queue is blocked.
 *
 *  @see downloadRetryLimit
 *  @see maximumDownloadRetriesExceeded
 */
@property (nonatomic, readonly) int downloadRetryCount;

/*!
*  @abstract Indicates if this asset is blocked because it has been retried and failed too many times
*
*  @discussion If Virtuoso fails to download an asset in the queue, it will retry the download
*              downloadRetryLimit times, before moving to the next item in the queue.  In this way,
*              Virtuoso cycles through the entire queue. Virtuoso will perform downloadRetryLimit
*              number of repeat attempts for each previously-failed download,
*              before stopping and reporting that the queue is blocked.
*
*  @see downloadRetryLimit
*  @see downloadRetryCount
*/
@property (nonatomic,readonly) Boolean maximumDownloadRetriesExceeded;


/*!
 *  @abstract Checks whether the asset is currently being processed by the Consistency scan
 */
@property (nonatomic, readonly)Boolean isConsistencyScanActive;

/*!
 *  @abstract Clears this asset's internal retry count, so Virtuoso will retry downloading it
 *
 *  @discussion When Virtuoso fails to download an asset, for whatever reason, Virtuoso will automatically retry the
 *              download N times. If Virtuoso fails N times, it will move to the next asset in the download queue.
 *              Eventually Virtuoso will loop through the download queue and reach this asset again, and re-attempt the
 *              download N more times. At some point, Virtuoso will have looped through the queue M times, and attempted
 *              to download the asset M*N times.
 *
 *              After M*N attempts, Virtuoso
 *               gives up, and will no longer atempt to download the asset.  When all pending
 *              assets have exceeded the allowable retries, Virtuoso enters the kVDE_DownloadMaxRetriesExceeded state and
 *              stops processing downloads until new assets are enqueued or existing assets are cleared.
 *
 *              This method resets the retry state, so Virtuoso will try downloading again.
 *
 *  @param onComplete A block to call when the engine has finished resetting the error count
 */
- (void)clearDownloadRetryCountOnComplete:(nullable BasicCompletionBlock)onComplete;


/**---------------------------------------------------------------------------------------
 * @name Availability And Windowing
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Availability and Windowing
#pragma mark

/*!
 *  @abstract Sets the inForcedExpire flag for this asset
 *
 *  @discussion Force-expire this asset. Does not affect asset's publishDate or expiryDate.
 *              After you call this method with YES, the isExpired and inForcedExpire properties will both return YES.
 *              You may call this method with NO to remove the forced expiry.
 *
 *  @warning Setting this value to YES immediately expires the asset and causes downloaded files to be removed from disk.
 *
 *  @param expired Whether this asset should be marked as inForcedExpire.
 */
- (void)forceExpire:(Boolean)expired;

/*!
 *  @abstract Sets this asset's availability window
 *
 *  @discussion Sets this asset's availability window.  This is the "validity schedule" for the asset.
 *              Virtuoso treats an asset outside of its availability window like an expired asset: Virtuoso does not
 *              return the asset in any lookup methods, nor does it provide access via the VirtuosoClientHTTPServer.
 *
 *              You can access an asset's window values via the publishDate (start) and expiryDate (end) properties.
 *
 *  @param start When this asset should be made available for access (publishDate)
 *
 *  @param end When this asset should be made unavailable for access (expiryDate)
 *
 */
- (void)setAvailabilityFrom:(nullable NSDate*)start to:(nullable NSDate*)end;

/**---------------------------------------------------------------------------------------
 * @name General Properties
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark General Properties
#pragma mark

/*!
 *  @abstract A universally unique identifier (UUID) that Virtuoso generates when it created this asset.
 *
 */
@property (nonatomic,readonly,nonnull) NSString* uuid;

/*!
 *  @abstract The asset type
 */
@property (nonatomic,readonly) kVDE_AssetType type;

/*!
 *  @abstract A unique identifier that you provide when instantiating this asset
 *
 *  @discussion Virtuoso uses the assetID in log events and for remote delete/wipe requests.
 */
@property (nonatomic,readonly,nonnull) NSString* assetID;

/*!
 *  @abstract A SHA256 hash generated from this particular asset instance.
 *
 *  @discussion The hash can be used to consistently identify this asset across multiple
 *              devices.  For HLS/HSS assets, this hash is only valid after the manifest has
 *              finished parsing.
 */
@property (nonatomic,readonly,nonnull) NSString* assetHash;

/*!
 *  @abstract Where this asset exists on the Internet
 *
 *  @discussion The asset URL is the addressable location on the Internet.
 *              It must include any required security or CDN tokens.
 *
 *              If your CDN uses dynamic URLs or another method where URLs change over time, Virtuoso
 *              may need to issue a network request to get a 'fresh' URL.  In that case, this method
 *              will block during this network request.
 */
@property (nonatomic,readonly,nonnull) NSString* assetURL;


/*!
 *  @abstract Where this asset exists on disk
 *
 *  @discussion The value of this property will be nil if this asset's type property is not
 *              kVDE_AssetTypeNonSegmented, if the asset has not finished downloading yet,
 *              or if the asset is not currently available due to expiry or windowing rules.
 *
 *  @see type
 *  @see isWithinViewingWindow
 *  @see isExpired
 *  @see isPlayable
 */
@property (nonatomic,readonly,nullable) NSString* filePath;

/*!
 *  @abstract Where this asset exists on disk
 *
 *  @discussion This property is a convenience method to return the NSURL version of the filePath
 *              property.
 *
 *  @see filePath
 */
@property (nonatomic,readonly,nullable) NSURL* fileURL;

/*!
 *  @abstract A human-readable description for this asset
 *
 *  @discussion Virtuoso does not use this internally, but does include it in logging output.
 *              You provided this value when instantiating this asset.
 */
@property (nonatomic,readonly,nonnull) NSString* description;

/*!
 *  @abstract Estimated size of this asset, in bytes
 *
 *  @discussion Virtuoso does not validate the size of VirtuosoAsset downloads, but it does use this value to help in
 *              determining when a VirtuosoAsset should be permitted to download.  Depending on the type of the asset
 *              this value may change over time, as Virtuoso can more accuractely determine the eventual completed size
 *              of the asset.
 */
@property (nonatomic,readonly) long long estimatedSize;

/*!
 *  @abstract Whether the backplane has given permission to download this asset
 *
 *  @discussion If the backplane settings for 'maximum downloads per account', 'lifetime asset download limit',
 *              or 'maximum copies of asset per account' are configured, then download permissions must be
 *              coordinated with the backplane in order to insure these business rules are properly enforced.
 *              Once the backplane has given permission for the asset to be downloaded, that permission is retained
 *              until a download error occurs, the download completes successfully, or the download is deleted.
 */
@property (nonatomic,readonly) kVDE_AssetPermissionType downloadPermission;

/*!
 *  @abstract The current size of this asset
 *
 *  @discussion The amount of data that Virtuoso has downloaded for this asset (in bytes). This property may return a cached value. Calls from MainThread always return a cached value. Calls from background threads may return a cached value. To ensure most current results, invoke asset.refreshOnComplete to refresh asset state.
 */
@property (nonatomic,readonly) long long currentSize;

/*!
 *  @abstract How much of this asset Virtuoso has already downloaded, as a fraction between 0.0 and 1.0
 *
 *  @discussion Virtuoso will calculate this value in various ways, depending on which method is the
 *              most efficient.  This value may be helpful for display purposes, but is not guaranteed precise.
 */
@property (nonatomic,readonly) double fractionComplete;

/*!
 *  @abstract The detected duration of the asset, in seconds, or kInvalidDuration if no duration has been detected.
 */
@property (nonatomic,readonly) NSTimeInterval duration;

/*!
 *  @abstract The current status of this asset
 *
 *  @discussion Virtuoso uses the most efficient methods possible to return current status of the aset.  Depending
 *              on the type of this asset and its status, this method may block for a short time.
 */
@property (nonatomic,readonly) kVDE_DownloadStatusType status;

/*!
 *  @abstract Errors Virtuoso encountered while downloading this asset
 */
@property (nonatomic,readonly) kVDE_DownloadErrorType error;

/*!
 *  @abstract The generic userInfo metadata for this asset
 *
 *  @discussion The userInfo dictionary is for you to store metadata alongside this asset.
 *              Since Virtuoso serializes this object, all objects contained within the userInfo dictionary
 *              MUST be property list compatible objects.  If you attempt to save non-compatible objects,
 *              the userInfo dictionary won't be persisted.
 */
@property (nonatomic,strong,nullable) NSDictionary* userInfo;

/*
 *  @abstract Additional HTTP headers that Virtuoso will use when requesting this asset from the remote web server
 *
 *  @discussion Virtuoso will include these headers in the network requests sent when downloading this asset.
 *              You may supply additional HTTP header values at the Engine or Asset levels.
 *              Lower-level values take precedence. For instance, if you provide the same header key in both
 *              levels, then the Asset value takes predecence over the Engine value.
 */
@property (nonatomic,strong,nullable) NSDictionary* additionalNetworkHeaders;

/*
 *  @abstract The asset protection type identified during asset creation.
 *
 *  @discussion In some configurations, special handling is required in order to download and play assets.
 *              Most of the time, you should pass the default value (kVDE_AssetProtectionTypePassthrough).  If
 *              instructed by Penthera support, you may be required to pass another value when the asset is created.
 */
@property (nonatomic,readonly) kVDE_AssetProtectionType assetProtectionType;

/*!
 *  @abstract Asset was created for fast-play download.
 */
@property (nonatomic,readonly) Boolean fastPlayEnabled;

/*!
 *  @abstract Asset was created for offline playback.
 */
@property (nonatomic,readonly) Boolean offlinePlayEnabled;

/*!
 *  @abstract Asset is ready for fastplay.
 *
 *  @discussion In order for an asset to successfully FastPlay, a small amount of the asset must be pre-downloaded.
 *              Avoid checks on this property from MainThread as this property must make blocking calls to CoreData.
 */
@property (nonatomic,readonly) Boolean fastPlayReady;

/*!
 * @abstract Video bitrate selected for the Asset
 */
@property (nonatomic, readonly)long long videoBitrate;

/*!
* @abstract Audio bitrate selected for the Asset
*/
@property (nonatomic, readonly)long long audioBitrate;

/*!
* @abstract Video resolution selected for the Asset. Nil if resolution not reported in manifest.
*/
@property (nonatomic, readonly,nullable)NSString* videoResolution;

/*!
* @abstract Bandwidth selection type. If AVERAGE-BANDWIDTH is specified in the manifest, returns "avg"; "peak" otherwise.
*/
@property (nonatomic, readonly, nonnull)NSString* bandwidthSelectionType;

/**---------------------------------------------------------------------------------------
* @name Ads Support
*  ---------------------------------------------------------------------------------------
*/
#pragma mark
#pragma mark Ads Support
#pragma mark

/*!
 *  @abstract AdsProvider assocated with the Asset.
 *
 */
@property (nonatomic, strong, readonly)VirtuosoAdsProvider* _Nonnull adsProvider;


/*!
 *  @abstract Indicates status of Ads refresh on this Asset.
 *
 *  @discussion Indicates status of Ads refresh on this Asset.
 *              Set this property to AssetAdStatus_Uninitialized and invoke reloadAds to manually refresh Ads.
 */
@property (nonatomic,assign,readonly)AssetAdStatus refreshAdsStatus;

/*!
 *  @abstract Starts async process to refresh Advertisements associated with this asset.
 *
 *  @discussion This method starts an async process to refresh ads assocated with this asset.
 *              NSNotification kReloadAdsCompleteNotification is raised when this call completes.
 *
 *              NSNotification UserInfo:
 *              - kDownloadEngineNotificationAssetKey: VirtuosoAsset* to which reloadAds was called
 *              - kDownloadEngineNotificationSuccessValueKey: NSNumber* Boolean TRUE = Success
 *              - kDownloadEngineNotificationErrorKey: NSError* identifies cause of error
 */
- (void)reloadAds;

/**---------------------------------------------------------------------------------------
 * @name Windowing/Expiry Related Properties
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Windows/Expiry Related Properties
#pragma mark

/*!
 *  @abstract Whether this asset has been force-expired
 *
 *  @discussion Indicates whether the you previously called forceExpire on this asset.
 *              If the return value is YES, then the isExpired property will also return YES.
 *
 *  @see forceExpire:
 */
@property (nonatomic,readonly) Boolean inForcedExpire;

/*!
 *  @abstract When this asset should become available
 *
 *  @discussion Virtuoso will download assets as soon as they are enqueued.
 *              But in some cases, you may wish to embargo an asset.
 *              You do so by setting the publishDate property in the future.
 *              Until this date, Virtuoso will disallow access to this asset via the
 *              VirtuosoClientHTTPServer, and will not include this asset in any filtered
 *              query methods.
 *
 *  @see expiryDate
 *  @see assetWithUUID:availabilityFilter:
 */
@property (nonatomic,strong,nullable) NSDate* publishDate;

/*!
 *  @abstract As soon as possible after 'expiryDate' has passed, Virtuoso automatically deletes the asset.
 *
 *  @discussion A nil value means the asset never expires.
 */
@property (nonatomic,strong,nullable) NSDate* expiryDate;

/*!
 *  @abstract When this asset's DRM was last refreshed
 *
 *  @discussion For Virtuoso managed DRM, this property is updated with the Date when
 *              DRM was last successfully refreshed.
 */
@property (nonatomic,strong,nullable) NSDate* lastDRMRefresh;

/*!
 *  @abstract After the asset has completed download, as soon as possible after 'expiryAfterDownload'
 *            time has elapsed, Virtuoso automatically deletes the asset.
 *
 *  @discussion A value of zero means the asset never expires.
 */
@property (nonatomic,assign) NSTimeInterval expiryAfterDownload;

/*!
 *  @abstract After the asset is first played, as soon as possible after 'expiryAfterPlay' time has elapsed,
 *            Virtuoso automatically deletes the asset.
 *
 *  @see firstPlayDateTime
 *
 *  @discussion A value of zero means the asset never expires.
 */
@property (nonatomic,assign) NSTimeInterval expiryAfterPlay;

/*!
 *  @abstract Is this asset within its availability window?
 *
 */
@property (nonatomic,readonly) Boolean isWithinViewingWindow;

/*!
 *  @abstract Has this asset already expired?
 */
@property (nonatomic,readonly) Boolean isExpired;

/*!
 *  @abstract Has the ad associated with asset already expired?
 *
 *  @discussion If an ad is not associated with the asset, returns FALSE.
 *
 *              If an ad has not completed the ad refresh, returns FALSE.
 *
 *              Use the VFM_EnableAdExpiration setting to control this check.  The default setting (FALSE) is
 *              to NOT perform this check and return FALSE.  When set to TRUE, the value is calculated by calling
 *              the ad provider to evaluate the ad expiration date.
 */
@property (nonatomic,readonly)Boolean isAdExpired;

/*!
 *  @abstract Whether this asset is currently playable.
 *
 *  @discussion This value is calculated by evaluating download state, expiry rules, and ad requirements,
 *              and indicates whether attempts to play this asset are likely to succeed. Note also, this property
 *              requries blocking calls to CoreData. Avoid accessing this property from MainThread code.
 *
 *              For non-blocking scnearios:
 *              +(void)isPlayable:(VirtuosoAsset* _Nonnull)asset operationQueue:(NSOperationQueue* _Nonnull)operationQueue callback:(CompletionBlockWithStatus _Nonnull)callback;
 *              +(void)isPlayable:(VirtuosoAsset* _Nonnull)asset dispatchQueue:(dispatch_queue_t _Nonnull)dispatchQueue callback:(CompletionBlockWithStatus _Nonnull)callback;
 *
 * @warning     This property should not be accessed from MainThread code as the call may require several seconds to complete and will result in blocking UI updates.
 *
 */
@property (nonatomic,readonly) Boolean isPlayable;

/*!
 *  @abstract When Virtuoso predicts this asset will expire.
 *            Returns the soonest date based on all the expiry constraints for this asset.
 *            A return value of nil means the item never expires.
 */
@property (nonatomic,readonly,nullable) NSDate* effectiveExpiryDate;

/*!
 *  @abstract When Virtuoso finished downloading this asset.  Nil if Virtuoso hasn't completed the download yet.
 *
 */
@property (nonatomic,readonly,nullable) NSDate* downloadCompleteDateTime;

/*!
 *  @abstract When a VirtuosoAsset was created.
 *
 *  @discussion If this asset was created on the device, then this value is the time the asset was instantiated.  If
 *              this asset was pushed from the server via subscription or remote push, then this value is the time
 *              the asset was created in the Backplane.
 */
@property (nonatomic,readonly,nonnull) NSDate* creationDateTime;

/*!
 *  @abstract When this asset was first played.  Nil if Virtuoso is not aware of this asset being played yet.
 *
 *  @discussion Virtuoso doesn't always know when an asset is played.  Therefore,  you must set this value when
 *              playback of this asset begins. This allows Virtuoso to enforce 'expiryAfterPlay'.
 *              Setting this value if it has already been set does nothing, but the value can be reset to nil.
 *
 */
@property (nonatomic,strong,nullable) NSDate* firstPlayDateTime;

/*!
 *  @abstract Date and time when this asset was last played.  Nil if Virtuoso is not aware of this asset being played yet.
 *
 *  @discussion This property is automatically set when play_start event is triggered.
 *
 */
@property (nonatomic,strong,nullable) NSDate* lastPlaybackDateTime;

/*!
 *  @abstract The asset-specific lifetime download limit.
 *
 *  @discussion The Backplane specifies a globally applied lifetime download limit for all assets.  An individual
 *              asset may not be downloaded more than this number of times in a given account.  Once the asset has
 *              been successfully downloaded this many time, future attempts to download the asset will return an error.
 *              This optional value may be specified to override the lifetime download limit for this particular asset.
 *              If this value is greater than 0, it will be used for permissions calculations instead of the backplane-
 *              defined value.  This value is provided during creation of the asset and cannot be changed after creation.
 */
@property (nonatomic,readonly) int assetDownloadLimit;

/*!
 *  @abstract Whether this asset is currently paused or resumed.
 *
 *  @discussion Updates to this property are applied asynchronously
 */
@property (nonatomic,assign) Boolean isPaused;

/**---------------------------------------------------------------------------------------
 * @name Advanced Download Control
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Advanced Download Control
#pragma mark

/*!
 *  @abstract If set, this delegate is called as described in VirtuosoPrepareUrlDelegate.
 *
 *  @discussion This is an advanced feature. It allows the Customer to modify the various download
 *              Url's before downloading. See VirtuosoPrepareUrlDelegate for more information.
 */
@property (nonatomic, weak, class)id <VirtuosoPrepareUrlDelegate> _Nullable prepareUrlDelegate;

/*!
 *  @abstract If set, this delegate is called as described in VirtuosoVideoRendition.
 *
 *  @discussion This is an advanced feature. It allows the Customer to override internal SDK video rendition
 *              selection rules and to specify the rendition for download manually.  This delegate is only
 *              valid for HLS assets.  For all other asset types, this delegate is currently ignored.
 *
 *              See VirtuosoVideoRendition for more information.
 */
@property (nonatomic, weak, class)id <VirtuosoRenditionSelectionDelegate> _Nullable renditionSelectionDelegate;

/*!
 *  @abstract If set, this block is called whenever an asset is about to request data from
 *            a network resource.
 *
 *  @discussion Certain types of DRM or CDN may require that additional parameters be placed on URLs
 *              beyond what is contained in the asset manifest.  In some cases, those security tokens
 *              are dynamically generated and short lived.  If set, whenever Virtuoso is about to access
 *              a network resource, you can return additional URL parameters to include in the request
 *              in this block and they will be appended to the network URL.  If you do not need to use
 *              additional URL parameters, do not set this block.
 *
 *              In order to maximize performance, Virtuoso will store your returned response in memory.
 *              Therefore, this block may not be called for every network request, but it will be called
 *              as-needed.
 *
 *              The dictionary you return should include the URL parameter names as the keys and the
 *              parameter value as the values.
 *
 *  @param block A callback block used to retrieve additional URL parameters when downloading asset data.
 */
+ (void)setRequestAdditionalParametersBlock:(nullable RequestAdditionalParametersBlock)block __attribute__((deprecated("method replaced by  prepareUrlDelegate property.")));



@end

#endif
