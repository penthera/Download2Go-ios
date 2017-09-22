/*!
 *  @header Virtuoso Download Engine
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

#ifndef VDENGINE
#define VDENGINE

#import <Foundation/Foundation.h>
#import "VirtuosoConstants.h"

@class VirtuosoAsset;
@class VirtuosoDevice;

/*!
 *  @abstract The central control for all download-related activities.
 *
 *  @discussion A singleton object that handles all download activity and monitoring conditions and settings.
 *              Maintains the download queue, which is a list of VirtuosoAsset objects enqueued for download.  
 *              Receives config values from the Backplane. Monitors device state. Ensures that downloads 
 *              only occur consistent with the current configuration.
 *
 *  @warning You must never instantiate an object of this type directly.
*            The VirtuosoDownloadEngine is a singleton and should only be accessed via the
 *           provided instance method.
 *
 */
@interface VirtuosoDownloadEngine : NSObject

/**---------------------------------------------------------------------------------------
 * @name Utility
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Utility
#pragma mark

/*!
 *  @abstract The singleton instance access method
 *
 *  @discussion You must never instantiate a local copy of the VirtuosoDownloadEngine object.  This object
 *              is intended to be a static singleton accessed through the instance method only.  Instantiating a local
 *              copy will throw an exception.
 *
 *  @return Returns the VirtuosoDownloadEngine object instance.
 */
+ (nonnull VirtuosoDownloadEngine*)instance;

/*!
 *  @abstract Returns the version of this build.
 *
 *  @discussion The Virtuoso version is set at compile-time.  You may use this version as a reference
 *              for documentation and debugging purposes.
 *
 *  @return The compile-time configured version of this Virtuoso build
 */
+ (nonnull NSString*)versionString;

/**---------------------------------------------------------------------------------------
 * @name Startup and Shutdown
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Startup and Shutdown Actions
#pragma mark

/*!
 *  @abstract You must call this method to initialize Virtuoso before you call any other Virtuoso method.
 *
 *  @discussion Sets up Virtuoso for use with a Backplane instance.
 *
 *  @warning    Except as otherwise documented, if you attempt to call other methods before
 *              this one, you'll get an exception. If you catch and ignore the exceptions,
 *              Virtuoso behavior will be undefined. If you attempt to use the VirtuosoSubscriptionManager
 *              before starting up, its instance method will return nil.
 *
 *  @param backplaneURL A root URL pointing to the location of the Backplane endpoints
 *
 *  @param user The Backplane user to use
 *
 *  @param externalDeviceID An optional externally-defined device UUID
 *
 *  @param privateKey The Penthera-provided private key
 *
 *  @param publicKey The Penthera-provided public key
 *
 *  @return A startup code indicating the result
 */
- (kVDE_EngineStartupCode)startupWithBackplane:(nonnull NSString*)backplaneURL
                                          user:(nonnull NSString*)user
                              externalDeviceID:(nullable NSString*)externalDeviceID
                                    privateKey:(nonnull NSString*)privateKey
                                     publicKey:(nonnull NSString*)publicKey;

/*!
 *  @abstract Resets Virtuoso without unregistering the device or deleting assets.
 *
 *  @discussion Normally, if a user logs out of the enclosing app, you would call the device unregister
 *              method for the user's device, which deletes all assets, removes the device from the backplane,
 *              and resets the engine state.  If complex business logic requires that you do not do these things
 *              when the user logs out (if you want to allow the same user to log back in without losing 
 *              downloads, for instance), then you would use this method, rather than the device unregister method.
 *
 *              After this method has been called, you must call 
 *              startupWithBackplane:user:externalDeviceID:privateKey:publicKey: again befor you call any other
 *              Virtuoso method.  
 *
 *  @warning    After calling this method, except as otherwise documented, if you attempt to call other methods
 *              before calling startupWithBackplane:user:externalDeviceID:privateKey:publicKey:, you'll get an
 *              exception. If you catch and ignore the exceptions, Virtuoso behavior will be undefined. If you 
 *              attempt to use the VirtuosoSubscriptionManager before starting up, its instance method will return nil.
 */
- (void)shutdown;

/**---------------------------------------------------------------------------------------
 * @name Backplane
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Backplane Actions
#pragma mark

/*!
 *  @abstract Causes a sync with the Backplane
 *
 *  @discussion Virtuoso will automatically sync with the Backplane at opportune times.  Use this method to request
 *              a sync based on your own logic.  If you want to force a sync, even if the backplane has synced recently,
 *              then pass YES to the parameter.
 *
 *  @param now Used to force a sync, even if the backplane has synced recently.
 */
- (void)syncWithBackplaneNow:(Boolean)now;

/*!
 *  @abstract The URL where the Backplane lives
 */
@property (nonatomic,readonly,nonnull) NSString* backplaneURL;

/*!
 *  @abstract The user used to authenticate with the Backplane
 */
@property (nonatomic,readonly,nonnull) NSString* user;

/*!
 *  @abstract The external device ID provided to Virtuoso during startup
 */
@property (nonatomic,readonly,nullable) NSString* externalDeviceID;

/*!
 *  @abstract The Virtuoso-assigned unique device ID for this device
 */
@property (nonatomic,readonly,nonnull) NSString* deviceID;

/*!
 *  @abstract The Penthera-provided application secret (unique to each customer) used to authenticate with the Backplane
 */
@property (nonatomic,readonly,nonnull) NSString* secret;

/*!
 *  @abstract The Penthera-provided application key (unique to each customer) used to authenticate with the Backplane
 */
@property (nonatomic,readonly,nonnull) NSString* key;

/**---------------------------------------------------------------------------------------
 * @name Engine Status
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Engine Status
#pragma mark

/*!
 *  @abstract Virtuoso's global 'enable' state
 *
 *  @discussion The "master switch" for downloading. 
 *              When Virtuoso is disabled, you can change settings and manipulate the download queue, but
 *              Virtuoso will be blocked and will not download. Virtuoso does not modify this switch, but you
 *              may do so, if you wish. Once you set a value, that value persists across app restarts. 
 *              Default is YES.
 */
@property (nonatomic,assign) Boolean enabled;

/*!
 *  @abstract Whether Virtuoso has been started (i.e. had a startup method called)
 */
@property (nonatomic,readonly) Boolean started;

/*!
 *  @abstract The current Virtuoso download Engine status
 */
@property (nonatomic,readonly) kVDE_DownloadEngineStatus status;

/*!
 *  @abstract A convenience method to return a displayable version of the downloadBandwidth property.
 *
 *  @discussion This value will automatically adjust for human-readable display, including 
 *              shifting and displaying appropriate units.
 */
@property (nonatomic,readonly,nonnull) NSString* downloadBandwidthString;

/*!
 *  @abstract Effective download throughput in KBps
 *
 *  @discussion Virtuoso collects download statistics on a 10 second interval. This value is a short-term average,
 *              based on the most recent 30 seconds of data.  Note that it is not possible to track the throughput of
 *              background downloads, and this value only applies to data transferred while the app is in the foreground.
 */
@property (nonatomic,readonly) double downloadBandwidth;

/*!
 *  @abstract The UUID for asset Virtuoso is currently downloading.
 *
 *  @discussion This value is only valid when the application is active.  Once Virtuoso has transferred
 *              to background downloads, Virtuoso may download none, one, or all of the assets at once.
 *              Status for these background downloads will be updated when the application resumes operation
 *              in the foreground.
 */
@property (nonatomic,readonly,nullable) NSString* currentlyDownloadingAsset;

/*!
 *  @abstract The date/time of the last successful Backplane sync
 */
@property (nonatomic,readonly,nullable) NSDate* lastBackplaneSyncTime;

/*!
 *  @abstract Whether authorization with the Backplane has timed out
 *
 *  @discussion If YES, then attempts to create a VirtuosoFileProxy for any assets will return nil,
 *              and all attempts to access the local file paths for assets on disk via Virtuoso
 *              objects will also return nil.
 */
@property (nonatomic,readonly) Boolean offlineTimedOut;

/*!
 *  @abstract When the Virtuoso SDK license expires
 *
 *  @discussion If your SDK license expires, then this property returns the date/time when the license
 *              will expire, otherwise it returns nil.
 */
@property (nonatomic,readonly,nullable) NSDate* licenseExpiry;

/*!
 *  @abstract Whether this device is permitted to download
 *
 *  @discussion Virtuoso ANDs this value with the enabled property to determine if it should permit downloads.
 *              This property is included as a convenience to quickly access the effective download permissions
 *              for the current device.
 */
@property (nonatomic,readonly) Boolean downloadEnabled;

/*!
 *  @abstract Returns an array of VirtuosoDevice objects associated with the registered User.  
 *            The array is current as of the last sync with the Backplane.
 */
@property (nonatomic,readonly,nonnull) NSArray* devices;

/**---------------------------------------------------------------------------------------
 * @name Queue Management
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Queue Management
#pragma mark

/*!
 *  @abstract Returns an ordered array of UUID strings for VirtuosoAsset items in the download queue.
 *
 *  @discussion Items at the beginning of the queue will be downloaded first.  
 *              This method returns a copy of the queue; changes to the returned array will have no 
 *              effect on the active queue.
 *
 *  @return An ordered array of UUID strings representing VirtuosoAsset objects enqueued for download.
 */
- (nonnull NSArray*)assetsInQueue;

/*!
 *  @abstract Adds an asset to the download queue.
 *
 *  @discussion While the application is in the foreground, Virtuoso generally downloads assets in the order
 *              they appear in the queue. If Virtuoso encounters an error while downloading an asset, it may 
 *              put that asset aside and proceed to the next one in the queue. While in the background, queue
 *              order is suggested, but not enforced, and assets may download in any order. You should not make
 *              any assumptions about the number of assets Virtuoso may download in parallel.  Providing any index
 *              larger than the current queue size will result in the asset being added to the end of the queue.
 *
 *              If this method is called without a completion block, any required permissions checks will be done
 *              synchronously, and this method may block until they complete.  Any errors will be returned in the
 *              method's return value.  If this method is called with a completion block, then the method is 
 *              asynchronous, and the asset will be added to the queue after this method returns.  In this case,
 *              the return value will always be nil.  In either case, the asset will be added to the queue.  
 *              Any errors encountered while adding the asset asynchronously (E.G. permissions errors) will be 
 *              reported with the completion block.
 *
 *  @param asset      The asset to add to the download queue
 *  @param index      The index in the queue to add the asset at
 *  @param onComplete Completion block that fires after the asset has been added to the queue
 *
 *  @return An error indicating any issues that occurred while adding the asset to the queue, or nil if no error
 */
- (NSError* _Nullable)addToQueue:(nonnull VirtuosoAsset*)asset
                         atIndex:(NSUInteger)index
                      onComplete:(AssetAddToQueueCompleteBlock _Nullable )onComplete;

/*!
 *  @abstract Reorders the download queue.
 *
 *  @discussion While the enclosing application is in the foreground, Virtuoso generally downloads assets in the order
 *              they appear in the queue. If Virtuoso encounters an error while downloading an asset, it may
 *              put that asset aside and proceed to the next one in the queue. While in the background, queue
 *              order is suggested, but not enforced, and assets may download in any order. You should not make
 *              any assumptions about the number of assets Virtuoso may download in parallel.  Providing any index
 *              larger than the current queue size will result in the asset being added to the end of the queue.
 *
 *  @param asset The asset to move in the download queue
 *  @param index The index in the queue to move the asset to
 */
- (void)moveAsset:(nonnull VirtuosoAsset*)asset inQueueToIndex:(NSUInteger)index;

/*!
 *  @abstract Remove the given asset from the download queue.
 *
 *  @param asset The asset to remove from the download queue
 *
 *  @return The location the asset was removed from, if successful, or NSNotFound if the asset was not in the queue.
 */
- (NSUInteger)removeFromQueue:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Retrieves an asset in the download queue by remote URL.
 *
 *  @warning This method searches the entire queue and may block for some time.  It's far more 
 *           efficient to access the asset in the queue by known index or UUID value.
 *
 *  @param url The remote url of an asset to query for
 *
 *  @return Returns the VirtuosoAsset object on success or nil on failure.
 */
- (nullable VirtuosoAsset*)assetInQueueWithURL:(nonnull NSString*)url;

/*!
 *  @abstract Retrieves an asset in the download queue by UUID.
 *
 *  @param uuid The universally unique identifier (UUID) of the asset
 *
 *  @return Returns the VirtuosoAsset object on success or nil on failure.
 */
- (nullable VirtuosoAsset*)assetInQueueWithUUID:(nonnull NSString*)uuid;

/*!
 *  @abstract Removes all items from the download queue.
 */
- (void)flushQueue;


/**---------------------------------------------------------------------------------------
 * @name Various Properties
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Various Properties
#pragma mark

/*!
 *  @abstract Returns the network status, as reported by Virtuoso's internal Reachability instance.
 */
- (kVDE_NetworkStatus) currentNetworkStatus;

/*!
 *  @abstract Whether current network state permits downloading
 */
@property (nonatomic,readonly) Boolean networkStatusOK;

/*!
 *  @abstract Whether disk usage state permits downloading
 */
@property (nonatomic,readonly) Boolean diskStatusOK;

/*!
 *  @abstract Whether queue state permits downloading
 */
@property (nonatomic,readonly) Boolean queueStatusOK;

/*!
 *  @abstract Whether account-level business rules permit downloading
 */
@property (nonatomic,readonly) Boolean accountStatusOK;

/*!
 *  @abstract Whether the Virtuoso SDK license is currently valid
 */
@property (nonatomic,readonly) Boolean authenticationOK;

@end

#endif
