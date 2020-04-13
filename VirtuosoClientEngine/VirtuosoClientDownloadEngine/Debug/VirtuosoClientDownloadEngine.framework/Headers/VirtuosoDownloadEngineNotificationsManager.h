//
//  VirtuosoDownloadEngineNotificationsManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 11/8/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#ifndef VirtuosoDownloadEngineNotificationsManager_h
#define VirtuosoDownloadEngineNotificationsManager_h
#import "VirtuosoConstants.h"
#import "VirtuosoLogger.h"

@class VirtuosoAsset;
@class VirtuosoAncillaryFile;
@class VirtuosoEngineStatusInfo;

/*
 *  @abstract Delegate interface for Download Engine notifications
 *
 */
@protocol VirtuosoDownloadEngineNotificationsDelegate <NSObject>

@required
/*
 *  @abstract Called whenever the Engine starts downloading a VirtuosoAsset object.
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidStartDownloadingAssetNotification
 *
 */
-(void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  @abstract Called whenever the Engine reports progress for a VirtuosoAsset object
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineProgressUpdatedForAssetNotification
 *
 */
-(void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  @abstract Called when an asset is being processed after background transfer
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineProgressUpdatedForAssetProcessingNotification
 *
 */
-(void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  @abstract Called whenever the Engine reports a VirtuosoAsset as complete
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidFinishDownloadingAssetNotification
 *
 */
-(void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset* _Nonnull)asset;

@optional
/*
*  @abstract Called whenever asset is deleted
*
*  @description This callback is invoked in-response to Notification kBackplaneAssetDeletedNotification
*
*/
-(void)downloadEngineDeletedAssetId:(NSString* _Nonnull)assetID;

/*
 *  @abstract Called whenever the Engine reports a consistency scan complete for an asset
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidFinishConsistencyScanAssetNotification
 *
 */
-(void)downloadEngineConsistencyScanCompletedForAsset:(VirtuosoAsset* _Nonnull)asset;


/*
 *  @abstract Called whenever the Engine reports a VirtuosoAncillaryFile as complete
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidFinishDownloadingAssetNotification
 *
 */
-(void)downloadEngineDidFinishDownloadingAncillary:(VirtuosoAncillaryFile* _Nonnull)ancillary forAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  @abstract Called whenever the Engine reports a VirtuosoAsset has expired
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidResetExpiredAssetsNotification
 *
 */
-(void)downloadEngineAssetDidExpire:(VirtuosoAsset* _Nonnull)asset;

/*
 *  @abstract Called whenever the Engine reports result of DRM
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDRMResultForAssetNotification
 *
 */
-(void)downloadEngineDRMResultForAsset:(VirtuosoAsset* _Nonnull)asset withError:(NSError* _Nullable)error;

/*
 *  @abstract Called whenever the Engine status changes
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineStatusDidChangeNotification
 *
 */
-(void)downloadEngineStatusChange:(kVDE_DownloadEngineStatus)status statusInfo:(VirtuosoEngineStatusInfo* _Nonnull)statusInfo;

/*
 *  @abstract Called when internal logic changes queue order.  All we need to do is refresh the tables.
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineInternalQueueUpdateNotification
 *
 */
-(void)downloadEngineInternalQueueUpdate;

/*
 *  @abstract Called whenever the Engine encounters a recoverable issue.
 *
 *  @description Called whenever the Engine encounters a recoverable issue.  These are events that MAY be of concern to the Caller, but the Engine will
 *  continue the download process without intervention.
 *
 *  This callback is invoked in-response to Notification kDownloadEngineDidEncounterWarningNotification
 *
 */
-(void)downloadEngineDidEncounterWarningForAsset:(VirtuosoAsset* _Nonnull)asset error:(NSError* _Nullable)error;

/*
 *  @abstract Called whenever the Engine encounters an error
 *
 *  @description Called whenever the Engine encounters an error that it cannot recover from.  This type of error will cause the engine to retry download of the file.  If too many errors are encountered, the Engine will move on to the next item in the queue.
 *
 *  This callback is invoked in-response to Notification kDownloadEngineDidFinishDataStoreUpgradeNotification
 *
 */
-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset* _Nonnull)asset
                                         error:(NSError* _Nullable)error
                                          task:(NSURLSessionTask* _Nullable)task
                                          data:(NSData* _Nullable)data
                                    statusCode:(NSNumber* _Nullable)statusCode;

/*
 *  @abstract Called when the Engine is entering Background
 
 *  @description Called some period of time after the main application has been put into the background by the User.  Depending on application configuration, the Engine will keep the app alive in the background for some period of time in order to continue active downloads.  Once the Engine cannot keep the application alive any longer, due to iOS constraints, the Engine will pause downloads and allow the application to be put to sleep.  Before going to sleep, this notification is called to allow the Caller to take potential action if downloads were still pending at this point.
 *
 *  This callback is invoked in-response to Notification kDownloadEngineIsEnteringBackgroundNotification
 *
 */
-(void)downloadEngineIsEnteringBackground:(NSArray* _Nullable)continuingAssets pausingAssets:(NSArray* _Nullable)pausingAssets;

/*
 *  @abstract Called whenever the Engine enabled or disabled
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineEnableDisableChangeNotificationKey
 *
 */
-(void)downloadEngineEnableStateChange:(Boolean)enabled;

/*
 *  @abstract Called when data store update begins
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidBeginDataStoreUpgradeNotification
 *
 */
-(void)downloadEngineDidBeginDataStoreUpgrade;

/*
 *  @abstract Called when data store update finishes
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineDidFinishDataStoreUpgradeNotification
 *
 */
-(void)downloadEngineDidFinishDataStoreUpgrade;

/*
 *  @abstract Called when Asset.deleteAll completes
 *
 *  @description This callback is invoked in-response to Notification kDownloadEngineAllAssetsDeletedNotification
 *
 */
-(void)downloadEngineAllAssetsDeleted;


/*
 *  @abstract Called when startupWithBackplane completes
 *
 *  @description This callback is invoked when startupWithBackplane completes.
 *
 *  @param succeeded YES indicates the backplane started successfully, NO indicates failure.
 */
-(void)downloadEngineStartupComplete:(Boolean)succeeded;

/*
 *  @abstract Called when startupWithBackplane detects user change that will require assets be deleted.
 *
 *  @description Called when startupWithBackplane detects user change that will require assets be deleted.
 *
 */
-(void)downloadEngineStartupUserDeleteStarted;

/*
*  @abstract Called when the operating system detects a change in network reachability.
*
*  @description This callback is invoked when the operating system detects a change in network reachability.
*
*  @param previousNetworkReachability The previous state of network reachability.  During the first invocaton of the callback this value will always be kVL_Invalid.
*
*  @param currentNetworkReachability The current state of network reachability.  Compare currentNetworkReachability with previousNetworkReachability to determine change in network reachability.
*
*/

-(void)downloadEngineNetworkReachabilityChange:(kVL_BearerType)previousNetworkReachability
                    currentNetworkReachability:(kVL_BearerType)currentNetworkReachability;

/*
*  @abstract Called when a FastPlay Asset is ready to play.
*
*  @description This callback is invoked when a FastPlay Asset is ready to play.
*
*  @param asset VirtuosoAsset for asset that is ready for FastPlay
*
*/
-(void)downloadEngineFastPlayAssetReady:(VirtuosoAsset* _Nonnull)asset;

@end

/*
 *  @abstract Manages callbacks for Download Engine Notifications
 *
 *  @description A view that wants to recevie delegate callbacks should hold an instance of this class and initialize it during view load. The Download engine will invoke the callbacks as events occur.
 *
 */
@interface VirtuosoDownloadEngineNotificationManager : NSObject

/*
 *  @abstract Delegate callback
 */
@property (nonatomic, strong, readonly)id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull delegate;

/*
 *  @abstract Operation queue upon which the callbacks will happen
 */
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull queue;

/*
 *  @abstract Asset ID that will be used to filter delegate callbacks. Nil to skip filtering.
 */
@property (atomic, copy)NSString* _Nullable assetID;

/*
 *  @abstract Creates an instance
 *
 *  @param delegate Delegate that will be called
 *
 *  @return Instance of this component, nil on failure.
 *
 */
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate;

/*
 *  @abstract Creates an instance
 *
 *  @param delegate Delegate that will be called
 *
 *  @param queue NSOperationQueue the callback will be invoked on.
 *
 *  @return Instance of this component, nil on failure.
 *
 */
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate
                                    queue:(NSOperationQueue* _Nonnull)queue;

/*
 *  @abstract Creates an instance
 *
 *  @param delegate Delegate that will be called
 *
 *  @param queue NSOperationQueue the callback will be invoked on.
 *
 *  @param assetID Asset ID for the asset to filter on, nil to skip filtering.
 *
 *  @return Instance of this component, nil on failure.
 *
*/
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate
                                    queue:(NSOperationQueue* _Nonnull)queue
                                  assetID:(NSString* _Nullable)assetID;

@end

#endif /* VirtuosoDownloadEngineNotificationsManager_h */
