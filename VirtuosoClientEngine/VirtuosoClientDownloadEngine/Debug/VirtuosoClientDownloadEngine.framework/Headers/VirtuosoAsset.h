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
 *  @copyright (c) 2016 Penthera Inc. All Rights Reserved.
 */

#ifndef VASSET
#define VASSET

#import <Foundation/Foundation.h>

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#endif

#import "VirtuosoConstants.h"

#if IS_LIB==0
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>
#else
#import "VirtuosoPlayer.h"
#endif

/*!
 *  @abstract Basic completion block used generically in methods
 */
typedef void (^BasicCompletionBlock)();

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
+ (void)setRequestAdditionalParametersBlock:(nullable RequestAdditionalParametersBlock)block;

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion One of several constructors for creating an in-memory VirtuosoAsset object.
 *              This one relies on the default expiry-after-download and expiry-after-play rules.
 *
 *  @param assetURL The remote URL for the file (where to download from).
 *
 *  @param assetID A unique identifier for the asset. Used in all log events.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param publishDate Virtuoso will not provide API access to the asset until this date. Nil means "now."
 *
 *  @param expiryDate Virtuoso will not provide API access to the asset after this date. Nil means no expiry.
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
 */
+ (nullable VirtuosoAsset*)assetWithRemoteURL:(nonnull NSString*)assetURL
                                      assetID:(nonnull NSString*)assetID
                                  description:(nonnull NSString*)description
                                  publishDate:(nullable NSDate*)publishDate
                                   expiryDate:(nullable NSDate*)expiryDate
                               enableFastPlay:(Boolean)enableFastPlay
                                     userInfo:(nullable NSDictionary*)userInfo
                           onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                              onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/*!
 *  @abstract Creates a new in-memory VirtuosoAsset object.
 *
 *  @discussion One of several constructors for creating an in-memory VirtuosoAsset object.
 *              This constructor sets the expiry after download and play intervals explicitly.
 *
 *  @param assetURL The remote URL for the file (where to download from).
 *
 *  @param assetID A unique identifier for the asset. Used in all log events.
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
 */
+ (nullable VirtuosoAsset*)assetWithRemoteURL:(nonnull NSString*)assetURL
                                      assetID:(nonnull NSString*)assetID
                                  description:(nonnull NSString*)description
                                  publishDate:(nullable NSDate*)publishDate
                                   expiryDate:(nullable NSDate*)expiryDate
                          expiryAfterDownload:(NSTimeInterval)expiryAfterDownload
                              expiryAfterPlay:(NSTimeInterval)expiryAfterPlay
                               enableFastPlay:(Boolean)enableFastPlay
                                     userInfo:(nullable NSDictionary*)userInfo
                           onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                              onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;


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

/**---------------------------------------------------------------------------------------
 * @name Update And Delete
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Update and Delete
#pragma mark

/*!
 *  @abstract Refreshes the data in this object from the persistent data store
 *
 *  @discussion To ensure performance and thread-safety, Virtuoso objects are heavily cached.  Changes to
 *              one object instance are not guaranteed to be immediately reflected in other existing instances.
 *              Under most use cases, this will not be apparent, as Virtuoso always passes an updated object with
 *              each relevant notification.  But if you are storing instantiated objects externally to Virtuoso and are
 *              accessing property values that frequently change, such as fractionComplete or current size, then you
 *              may need to refresh the object to obtain the most up-to-date values.
 */
- (void)refresh;

/*!
 *  @abstract Persists the VirtuosoAsset object for later use
 *
 *  @discussion Virtuoso relies on in-memory caching to optimize performance.
 *              After making changes to an asset, you should call this method to ensure consistency.
 *              This method persists changes to the local instance of this object to disk.  Call refresh
 *              on an object to load up-to-date values from the persistent store into memory.
 */
- (void)save;

/*!
 *  @abstract Synchronously deletes this asset
 *
 *  @warning This method is synchronous. It will block until it has removed all files and internal data
 *           belonging to this asset.
 */
- (void)deleteAsset;

/*!
 *  @abstract Asynchronously deletes this asset
 *
 *  @discussion Deletes this asset.  This method is asynchronous and returns immediately.
 *
 *  @param deletedBlock Notifies that Virtuoso has finished deleting all asset resources from disk.
 */
- (void)deleteAssetOnComplete:(nullable AssetDeletionCompleteBlock)deletedBlock;

/*!
 *  @abstract Deletes all assets.
 */
+ (void)deleteAll;

/**---------------------------------------------------------------------------------------
 * @name Playback
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Playback
#pragma mark

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)

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
 *  @param playbackType Whether to play the downloaded copy or the online copy
 *  @param parent    The parent view controller to present the movie player from
 *  @param onSuccess Called when playback succeeds
 *  @param onFail    Called when playback fails
 *
 *  @return Returns NO if the playback cannot be set up for some reason
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
 *  @param playbackType Whether to play the downloaded copy or the online copy
 *  @param player An object that follows the VirtuosoPlayer protocol.
 *  @param onSuccess Called when playback succeeds
 *  @param onFail    Called when playback fails
 *
 *  @return Returns NO if the playback cannot be set up for some reason
 */
- (void)playUsingPlaybackType:(kVDE_AssetPlaybackType)playbackType andPlayer:(nonnull id<VirtuosoPlayer>)player
                    onSuccess:(nullable BasicCompletionBlock)onSuccess onFail:(nullable BasicCompletionBlock)onFail;

#endif

/*!
 *  @abstract Called when playback finishes (the video player exits) to cleanup the session.
 *
 *  @discussion Should only be called if playback was started using playUsingPlayer:.  If you
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
 *  @abstract How many passes Virtuoso has made attempting to download this asset
 *
 *  @discussion If Virtuoso fails to download an asset in the queue, it will retry the download a certain
 *              (internally-defined) number of times, before moving to the next item in the queue.  In this way,
 *              Virtuoso cycles through the entire queue. Virtuoso will perform a certain (internally-defined)
 *              number of repeat attempts for each previously-failed download,
 *              before stopping and reporting that the queue is blocked.
 */
@property (nonatomic, readonly) int downloadRetryCount;

/*!
 *  @abstract Clears this asset's internal retry count, so Virtuoso will retry downloading it
 *
 *  @discussion When Virtuoso fails to download an asset, for whatever reason, Virtuoso will automatically retry the
 *              download N times. If Virtuoso fails N times, it will move to the next asset in the download queue.
 *              Eventually Virtuoso will loop through the download queue and reach this asset again, and re-attempt the
 *              download N more times. At some point, Virtuoso will have looped through the queue M times, and attempted
 *              to download the asset M*N times.
 *
 *              After M*N attempts, Virtuoso gives up, and will no longer atempt to download the asset.  When all pending
 *              assets have exceeded the allowable retries, Virtuoso enters the kVDE_DownloadMaxRetriesExceeded state and
 *              stops processing downloads until new assets are enqueued or existing assets are cleared.
 *
 *              This method resets the retry state, so Virtuoso will try downloading again.
 *
 *  @param onComplete A block to call when the engine has finished resetting the error count
 */
- (void)clearRetryCountOnComplete:(nullable BasicCompletionBlock)onComplete;


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
 *  @discussion If the backplane settings for 'maximum downloads per account' or 'lifetime asset download limit'
 *              are configured, then download permissions must be coordinated with the backplane in order to 
 *              insure these business rules are properly enforced.  Once the backplane has given permission
 *              for the asset to be downloaded, that permission is retained until a download error occurs, the 
 *              download completes successfully, or the download is deleted.
 */
@property (nonatomic,readonly) kVDE_AssetPermissionType downloadPermission;

/*!
 *  @abstract The current size of this asset
 *
 *  @discussion The amount of data that Virtuoso has downloaded for this asset (in bytes)
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
 *  @abstract Whether this asset is currently playable.
 *
 *  @discussion This value is calculated by evaluating download state, expiry rules, and ad requirements,
 *              and indicates whether attempts to play this asset will succeed.
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
 *  @abstract Whether this asset supports FastPlay
 */
@property (nonatomic,readonly) Boolean fastPlayEnabled;

/*!
 *  @abstract If this asset is ready to begin FastPlay playback
 *
 *  @discussion In order for an asset to successfully FastPlay, a small amount of the asset must be pre-downloaded.
 *              Until that initial download has completed, playing the asset will behave as if FastPlay was not
 *              enabled.
 */
@property (nonatomic,readonly) Boolean fastPlayReady;

@end

#endif
