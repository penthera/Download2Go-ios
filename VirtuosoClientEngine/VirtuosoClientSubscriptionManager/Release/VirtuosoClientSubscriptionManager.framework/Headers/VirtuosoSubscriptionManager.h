/*!
 *  @header Virtuoso Subscription Manager
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
 *  @copyright (c) 2013 Penthera Inc. All Rights Reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "VirtuosoSubscriptionDefaultDataSource.h"

/*!
 *
 *  @typedef kVSM_ManagerFailureCode
 *
 *  @abstract The kVSM_ManagerFailureCode values are used to indicate various startup failure modes in the Manager.  The
 *            codes can be used to diagnose potential issues with startup, including communications issues with the Backplane
 */
typedef NS_ENUM(NSInteger, kVSM_ManagerFailureCode)
{
    /** The provided application secret,key, or user ID is invalid */
    kVSM_ManagerFailureAuthentication = -1,
    
    /** The provided Backplane could not be reached */
    kVSM_ManagerFailureBackplaneUnreachable = -2,
    
    /** The Backplane encountered an internal error or returned an unexpected response */
    kVSM_ManagerFailureUnknownBackplaneError = -3,
    
    /** The VirtuosoDownloadManager instance has not been properly started and is unavailable. 
        Manager methods will not function properly until after the VirtuosoDownloadManager has been started. */
    kVSM_ManagerFailureNotAvailable = -4,
    
    /** The device is currently offline and cannot perform the requested call */
    kVSM_ManagerFailureOffline = -5,
};

/*!
 *
 *  @typedef kVSM_Status
 *
 *  @abstract The kVSM_Status values indicate the current activity status of the Manager.
 *
 *  @constant kVSM_Unknown
 *  @constant kVSM_Offline
 *  @constant kVSM_Started
 *  @constant kVSM_Receiving
 *  @constant kVSM_Errors
 */
typedef NS_ENUM(NSInteger, kVSM_Status)
{
    /** The Manager hasn't finished starting up yet and status has not yet been determined */
    kVSM_Unknown = -1,
    
    /** The Manager cannot take any action, as the device is currently offline */
    kVSM_Offline = 0,
    
    /** The Manager has successfully authenticated, but hasn't received any data yet */
    kVSM_Started = 1,
    
    /** The Manager is operational and receiving content from the Backplane */
	kVSM_Receiving = 2,
    
    /** Errors occurred while processing subscriptions that prevent the Manager from 
        continuing.  Recoverable errors will be reported, but Manager status will remain
        at kVSM_Receiving. */
	kVSM_Errors = 3,
};


/*!
 *
 *  @typedef SubscriptionResultBlock
 *
 *  @discussion Provides the result of a push token update, subscribe, or unsubscribe request.  If unsuccessful, the error parameter will contain a detailed error.
 *
 *  @param success Whether or not the request succeeded
 *
 *  @param error   If an error occurred, this value will be non-nil and will contain detailed error data
 */
typedef void(^SubscriptionResultBlock)(Boolean success, NSError* _Nullable error);

/*!
 *  @typedef SubscriptionListResultBlock
 *
 *  @discussion Provides a list of feed UUID values the Manager is currently monitoring.
 *
 *  @param subscriptions A list of feed UUID values
 *
 *  @param error A NSError containing a failure code and debug string, or nil of no error occurred.
 */
typedef void(^SubscriptionListResultBlock)(NSArray* _Nonnull subscriptions, NSError* _Nullable error);

/*!
 *
 * @typedef SyncCompleteBlock
 *
 * @discussion Indicates that a subscription sync with the Backplane has completed.  A subscription sync will automatically create any required data source
 *             objects using the registered data source class and execute the data source.  It is up to the Caller to register for data source
 *             change notifications and handle incoming data from them appropriately.  When this block is called, all data sources will have finished
 *             any pending queries and the entire sync process will be completed.
 *
 *  @param success Whether or not the request succeeded
 *
 *  @param subscriptions If the request succeeded then an NSArray of subscription Feed UUID values, otherwise nil
 *
 *  @param error   If an error occurred, this value will be non-nil and will contain detailed error data
 */
typedef void(^SyncCompleteBlock)(Boolean success, NSArray* _Nullable subscriptions, NSError* _Nullable error);


#pragma mark
#pragma mark NSNotification UserInfo keys
#pragma mark

/*!
 *  @constant kSubscriptionManagerStatusDidChangeNotificationStatusKey
 *
 *  @abstract This key is used to find the new status within the userInfo dictionary sent by various NSNotificationCenter notices.
 */
extern NSString* _Nonnull const kSubscriptionManagerStatusDidChangeNotificationStatusKey;

/*!
 *  @constant kSubscriptionManagerNotificationVirtuosoAssetsKey
 *
 *  @abstract This key is used to find the VirtuosoAsset array within the userInfo dictionary sent by various NSNotificationCenter notices.
 */
extern NSString* _Nonnull const kSubscriptionManagerNotificationVirtuosoAssetsKey;

/*!
 *  @constant kSubscriptionManagerNotifiationVirtuosoAssetUUIDsKey
 *
 *  @abstract This key is used to find the array of VirtuosoAsset UUID values within the userInfo dictionary sent by various NSNotificationCenter
 *            notices.
 */
extern NSString* _Nonnull const kSubscriptionManagerNotificationVirtuosoAssetUUIDsKey;


#pragma mark
#pragma mark Subscription Manager NSNotification Names
#pragma mark

/*!
 *  @constant kSubscriptionManagerStatusDidChangeNotification
 *
 *  @abstract The current status of the Subscription Manager.  The updated status will be in the
 *            user info dictionary under the kSubscriptionManagerStatusDidChangeNotificationStatusKey.
 */
extern NSString* _Nonnull const kSubscriptionManagerStatusDidChangeNotification;

/*!
 *  @constant kSubscriptionManagerAssetDeletedNotification
 *
 *  @abstract Notification sent by the Manager when downloaded asset is automatically deleted based on Subscription settings.
 *            An NSArray containing the UUID values of any VirtuosoAsset objects that were deleted will be in the user info dictionary under the
 *            kSubscriptionManagerNotificationVirtuosoAssetUUIDsKey.  You should use those values to update your own bookkeeping.
 */
extern NSString* _Nonnull const kSubscriptionManagerAssetDeletedNotification;

/*!
 *  @constant kSubscriptionManagerAssetDeferredNotification
 *
 *  @abstract Notification sent by the Manager when asset downloads are skipped based on Subscription settings.  An NSArray containing
 *            any VirtuosoAsset objects that were created, but not added to the download queue, will be in the user info dictionary
 *            under the kSubscriptionManagerNotificationVirtuosoAssetsKey.
 */
extern NSString* _Nonnull const kSubscriptionManagerAssetDeferredNotification;

/*! 
 *  @constant kSubscriptionManagerAssetAddedNotification
 *
 *  @abstract Notification sent by the Manager when a new aset has been added to the system as a result of any sync with the Backplane.
 *            An NSArray containing any VirtuosoAsset objects that were added will be in the user info dictionary under the
 *            kSubscriptionManagerNotificationVirtuosoAssetsKey.  This notification indicates that the asset was new and is
 *            being downloaded.  If the sync happened via the method with manual options, only items from a currently subscribed feed
 *            added after the last sync time will be downloaded, according to the specified Manager download rules.  
 *            The Caller should rely on Download Engine APIs to track updates to the VirtuosoAsset items and download status.
 *
 *  @warning To insure maximum system performance, the Caller must ensure that VirtuosoAsset items are deleted when no longer needed.  This 
 *           would normally be triggered when asset expires or is removed from the catalog.  It is the Caller's responsibility to delete
 *           VirtuosoAsset items.
 */
extern NSString* _Nonnull const kSubscriptionManagerAssetAddedNotification;

/*!
 *  @constant kSubscriptionManagerDidFinishSyncNotification
 *
 *  @abstract Notification sent by the Manager when a subscription sync with the Backplane has completed.
 */
extern NSString* _Nonnull const kSubscriptionManagerDidFinishSyncNotification;


/*!
 *  @abstract The central control for all subscription-related activities.
 *
 *  @discussion A singleton object that handles all subscription activity and environment settings/status monitoring relating to subscriptions.  The Manager 
 *              associates episodes with the feed they belong to and downloads and deletes new episodes according to system preferences.
 *
 *  @warning The Caller must NEVER instantiate an object of this type directly.  The VirtuosoSubscriptionManager is a singleton and should only be accessed via the
 *           provided instance method.
 *
 *  @warning The VirtuosoSubscriptionManager and the entire VirtuosoClientSubscriptionService module has a link-time dependency on the VirtuosoClientDownloadEngine
 *           module.  
 */

@interface VirtuosoSubscriptionManager : NSObject

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
 *  @discussion The Caller MUST NEVER instantiate a local copy of the VirtuosoSubscriptionManager object.  This object
 *              is intended to be a static singleton accessed through the instance method only.  Instantiating a local
 *              copy will throw an exception.
 *
 *  @warning The VirtuosoDownloadEngine must be started successfully before any attempts to access the VirtuosoSubscriptionManager 
 *           instance method.  Any attempts to access the Manager in any way prior to successful Engine startup will result
 *           in a nil instance.
 *
 *  @warning It is best to ensure that a network connection exists prior to first calling the instance method.  This allows the 
 *           Manager to validate it's configuration and proceed to a 'started' state.  If you first call the instance method
 *           while the device is offline, it will begin in the 'offline' state until you access the Manager while online.
 *
 *  @return Returns the VirtuosoSubscriptionManager object instance, or nil if the VirtuosoDownloadEngine hasn't been started yet.
 */
+ (nullable VirtuosoSubscriptionManager*)instance;

/**---------------------------------------------------------------------------------------
 * @name Backplane Actions
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Backplane Actions
#pragma mark

/*!
 *  @abstract Forces a manual subscription sync with the Backplane, using standard parameters
 *
 *  @discussion The Manager will automatically sync subscriptions with the Backplane every time the app is foregrounded,
 *              and potentially at other required moments for internal Manager consistency.  This method
 *              can be used to increase the sync frequency, as required by the Caller.  
 *
 *  @param onComplete A completion block indicating sync has completed
 *
 *  @see syncSubscriptionsWithBackplaneNowForDataSince:returningOnlySubscribedFeeds:onComplete:
 */
- (void)syncSubscriptionsWithBackplaneNowOnComplete:(nullable SyncCompleteBlock)onComplete;

/*!
 *  @abstract Forces a manual subscription sync with the Backplane, using custom parameters
 *
 *  @discussion Under standard conditions, automatic syncs or syncs via syncSubscriptionsWithBackplaneNowOnComplete: will be sufficient
 *              to process all incoming subscriptions.  Under some scenarios, it may be desirable to have older data
 *              or data about all subscribable feeds returned by the Backplane.  This method allows the Caller to manually
 *              specify a timestamp for data freshness and an option to return data from only currently subscribed feeds.
 *
 *  @warning When syncing data with this method, only items that were added to the Backplane after the last sync and are within
 *           the current subscription list will be automatically be processed and downloaded.  Other older or unsubscribed items
 *           may be returned and reported in the processing results, but these outdated items will be ignored by the Manager.
 *
 *  @param since Data will only be returned if it has been modified after this timestamp.  If nil, all data will be returned.
 *
 *  @param subscribed If YES, then only data for currently subscribed feeds will be returned.  If NO, then data for all subscribable feeds 
 *                    will be returned.
 *
 *  @param onComplete A completion block indicating sync has completed
 *
 *  @see syncSubscriptionsWithBackplaneNowOnComplete:
 */
- (void)syncSubscriptionsWithBackplaneNowForDataSince:(nullable NSDate*)since
                         returningOnlySubscribedFeeds:(Boolean)subscribed
                                           onComplete:(nullable SyncCompleteBlock)onComplete;


/*! 
 *  @abstract The last time the Manager successfully synced with the Backplane.
 */
@property (nonatomic,readonly,nullable) NSDate* lastSubscriptionSyncTime;

/*!
 *  @abstract Cancels all subscriptions.
 *
 *  @param onComplete A completion block indicating the unsubscription process is compplete.
 */
- (void)unregisterSubscriptionsOnComplete:(nullable SubscriptionResultBlock)onComplete;

/**---------------------------------------------------------------------------------------
 * @name Subscription Manager Status
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Subscription Manager Status
#pragma mark

/*!
 *  @abstract Configures the Manager to utilize a particular data source class
 *
 *  @discussion By default, the Manager will automatically create and start instances of the VirtuosoSubscriptionBackplaneDataSource for metadata lookups.
 *              Calling this method allows the Caller to specify an alternate custom class for these operations.
 *
 *  @param dataSourceClass A Class instance to use for metadata lookup operations
 */
- (void)registerDataSource:(nonnull Class<VirtuosoSubscriptionDataSource>)dataSourceClass;

/*!
 *  @abstract The current Subscription Manager status
 */
@property (nonatomic,readonly) kVSM_Status status;

/**---------------------------------------------------------------------------------------
 * @name Subscription Management
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Subscription Management
#pragma mark

/*!
 *  @abstract Returns a list of VirtuosoAsset UUID values that represent items currently tracked in the subscription feed.
 *
 *  @param feedAssetID The feed to return items for
 *  @return A list of items in the subscription feed
 */
- (nonnull NSArray*)itemsInTrackingFeed:(nonnull NSString*)feedAssetID;

/*!
 *  @abstract Includes the provided episode in the Manager's feed tracking lists
 *
 *  @discussion The Manager only enforces business rules (max items, auto-delete) on items that it downloaded as a result of subscription 
 *              syncing.  In some cases, the caller may wish to have downloads generated externally to the Manager included in Manager
 *              business rule processing.  When a VirtuosoAsset item is passed to this method, it will be included during all enforcement
 *              actions.  If the feed already contains "max items" when this method is called, then business rules will be enforced and older
 *              items may be deleted, as with standard processing.
 *
 *  @param item A VirtuosoAsset item to include in business rule processing
 *
 *  @param feedAssetID The feed to associate the item with
 */
- (void)includeItem:(nonnull VirtuosoAsset*)item inTrackingFeed:(nonnull NSString*)feedAssetID;

/*!
 *  @abstract Registers the Manager for updates from the Backplane relating to the provided Subscription ID
 *
 *  @discussion Calling this method registers the Manager to receive updates about the provided Subscription ID.  The Subscription is
 *              a reference to any "subscribeable" thing, and may reference a channel, a series, a feed, or any other conceptual representation
 *              of a "thing" that provides periodic content updates.  The only requirement is that each Subscription is identified by a unique
 *              identifier that the Caller must provide.  This method uses the Manager defaults for maximumSubscriptionItemsPerFeed and
 *              autodeleteOldItems.
 *
 *  @warning The provided feed must have been created on the Backplane prior to attempts to subscribe to it.  This must be done via the Backplane
 *           web portal or via the Backplane APIs.  See Backplane documentation for details.
 *
 *  @param feedAssetID The unique externally defined feed Asset ID
 *
 *  @param onComplete A completion block to call with request results
 */
- (void)registerForSubscription:(nonnull NSString*)feedAssetID onComplete:(nullable SubscriptionResultBlock)onComplete;

/*!
 *  @abstract Registers the Manager for updates from the Backplane relating to the provided Subscription ID
 *
 *  @discussion Calling this method registers the Manager to receive updates about the provided Subscription ID.  The Subscription is
 *              a reference to any "subscribeable" thing, and may reference a channel, a series, a feed, or any other conceptual representation
 *              of a "thing" that provides periodic content updates.  The only requirement is that each Subscription is identified by a unique
 *              identifier that the Caller must provide.  The Caller may also provide a per-subscription max item limit and specify an auto-delete
 *              option.  When new items are added, old items will be removed or new downloads will be deferred, such that only the configured 
 *              number of items remains on disk at any one time.
 *
 *  @param feedAssetID The unique externally defined feed Asset ID
 *
 *  @param maximumSubscriptionItems The total number of items from this Subscription to keep on disk at any given time
 *
 *  @param autodelete Whether or not to delete previously downloaded items to make room for new ones
 *
 *  @param maxBitrate The maximum bitrate to use when downloading streamed video.  Ignored if the new episode is not a streamed video.  This
 *                    value will be treated as the default for all new episodes.  Specific values provided by the Backplane metadata or data source
 *                    will override this value.
 *
 *  @param onComplete A completion block to call with request results
 */
- (void)registerForSubscription:(nonnull NSString*)feedAssetID
               withMaximumItems:(int)maximumSubscriptionItems
          andAutodeleteOldItems:(Boolean)autodelete
                     maxBitrate:(int)maxBitrate
                     onComplete:(nullable SubscriptionResultBlock)onComplete;

/*!
 *  @abstract Applies new feed options to a subscribed feed
 *
 *  @discussion If a subscription already exists, this method may be used to update the feed business rules used by the manager without requiring 
 *              an unsubscribe and resubscribe.  If a subscription does not exist for the provided asset ID, then this method does nothing.
 *
 *  @param feedAssetID The unique externally defined feed Asset ID
 *
 *  @param maximumSubscriptionItems The total number of items from this Subscription to keep on disk at any given time
 *
 *  @param autodelete Whether or not to delete previously downloaded items to make room for new ones
 *
 *  @param maxBitrate The maximum bitrate to use when downloading streamed video.  Ignored if the new episode is not a streamed video.  This
 *                    value will be treated as the default for all new episodes.  Specific values provided by the Backplane metadata or data source
 *                    will override this value.
 */
- (void)updateSubscription:(nonnull NSString*)feedAssetID
          withMaximumItems:(int)maximumSubscriptionItems
     andAutodeleteOldItems:(Boolean)autodelete
                maxBitrate:(int)maxBitrate;

/*!
 *  @abstract Unregisters the Manager for updates from the Backplane relating to the provided Subscription ID
 *
 *  @discussion Calling this method unregisters the Manager to receive updates about the provided Subscription ID.  The Subscription is
 *              a reference to any "subscribeable" thing, and may reference a channel, a series, a feed, or any other conceptual representation
 *              of a "thing" that provides periodic content updates.  The only requirement is that each Subscription is identified by a unique
 *              identifier that the Caller must provide.
 *
 *  @param feedAssetID The unique externally defined feed Asset ID
 *
 *  @param onComplete A completion block to call with request results
 */
- (void)unregisterForSubscription:(nonnull NSString*)feedAssetID onComplete:(nullable SubscriptionResultBlock)onComplete;

/*!
 *  @abstract Returns a list of existing subscriptions
 *
 *  @discussion Returns a list of Feed Asset ID values representing Subscriptions currently being monitored by the Manager
 *
 *  @param onComplete A completion block to call with request results
 */
- (void)subscriptionsOnComplete:(nullable SubscriptionListResultBlock)onComplete;



/**---------------------------------------------------------------------------------------
 * @name Settings
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Settings
#pragma mark

/*!
 * @abstract The maximum number of subscription items, per feed, to keep on disk at any given time
 *
 * @discussion This is a global parameter and applies to all subscriptions.  A subscription registered with an individual max value will always
 *             use that value instead of this global default.  A value less than or equal to 0 indicates "no limit".  The default is 0.
 */
@property (nonatomic,assign) int maximumSubscriptionItemsPerFeed;

/*!
 *  @abstract Whether the Manager should delete old items to make way for new ones, based on maximumSubscriptionItemsPerFeed, or keep old items and defer
 *            automatic download of new ones.
 *
 *  @discussion Determines how the SDK behaves when a new episode is available and the device is already storing its quota from this feed.
 *              If YES, then delete oldest episode(s) from disk. The SDK reports the deleted items in the proper notification.  
 *              If NO, then the SDK will create a VirtuosoAsset object for the new episode, but won’t automatically download it.  
 *              These deferred items are reported in the proper notification.
 */
@property (nonatomic,assign) Boolean autodeleteOldItems;

/*!
 *  @abstract The maximum bitrate to use when downloading streamed videos.
 *
 *  @discussion This is a global paramter and applies to all subscriptions.  A subscription registered with an individual max value will always use
 *              that value instead of this global default.  A value of 0 indicates "highest possible".  The default is 0.  Individual episodes may further
 *              override this default and the feed-specific value by providing a max bitrate value in the episode metadata.
 */
@property (nonatomic,assign) int maxBitrate;

@end
