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
@class VirtuosoPlaylist;

@interface VirtuosoPermissionSettingInfo : NSObject
@property (nonatomic, copy)NSString* _Nonnull permission;
@property (nonatomic, strong)NSNumber* _Nonnull currentValue;
@property (nonatomic, strong)NSNumber* _Nonnull previousValue;
@property (nonatomic, strong)NSDate* _Nonnull dateChanged;
@end

/*!
*  @abstract Delegate interface for Download Engine notifications.
 *
 * @discussion This delegate provides an easy to use interface for monitoring the many Notifications emitted by the Download engine. Note some methods are required, while others are optional.
*/
@protocol VirtuosoDownloadEngineNotificationsDelegate <NSObject>

@optional
/*!
 *  @abstract Called whenever the Engine starts downloading a VirtuosoAsset object.
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDidStartDownloadingAssetNotification
 *
 *  @param asset VirtuosoAsset asset
 *
 */
-(void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Called whenever the Engine reports progress for a VirtuosoAsset object
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineProgressUpdatedForAssetNotification
 *
 *  @param asset VirtuosoAsset asset
 *
 */
-(void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Called when an asset is being processed after background transfer
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineProgressUpdatedForAssetProcessingNotification
 *
 *  @param asset VirtuosoAsset asset
 *
 */
-(void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Called whenever the Engine reports a VirtuosoAsset as complete
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDidFinishDownloadingAssetNotification
 *
 *  @param asset VirtuosoAsset asset
 *
 */
-(void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
*  @abstract Called whenever asset is deleted
*
*  @discussion This callback is invoked in-response to Notification kAssetDeletedNotification
*
*  @param assetID VirtuosoAsset.assetID for the asset that was deleted.
*
*/
-(void)downloadEngineDeletedAssetId:(NSString* _Nonnull)assetID;

/*!
 *  @abstract Called whenever the Engine reports a VirtuosoAncillaryFile as complete
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDidFinishDownloadingAssetNotification
 *
 *  @param ancillary VirtuosoAncillaryFile that finished
 *
 *  @param asset VirtuosoAsset asset
 *
 */
-(void)downloadEngineDidFinishDownloadingAncillary:(VirtuosoAncillaryFile* _Nonnull)ancillary forAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Called whenever the Engine reports a VirtuosoAsset has expired
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDidResetExpiredAssetsNotification
 *
 *  @param asset VirtuosoAsset asset
 *
 */
-(void)downloadEngineAssetDidExpire:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Called whenever the Engine reports result of DRM
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDRMResultForAssetNotification
 *
 *  @param asset VirtuosoAsset asset
 *
 *  @param error NSError indicating cause of DRM refresh failure
 *
 */
-(void)downloadEngineDRMResultForAsset:(VirtuosoAsset* _Nonnull)asset withError:(NSError* _Nullable)error;

/*!
 *  @abstract Called whenever the Engine status changes
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineStatusDidChangeNotification
 *
 *  @param status Engine status enum kVDE_DownloadEngineStatus
 *
 *  @param statusInfo Engine VirtuosoEngineStatusInfo information
 *
 */
-(void)downloadEngineStatusChange:(kVDE_DownloadEngineStatus)status statusInfo:(VirtuosoEngineStatusInfo* _Nonnull)statusInfo;

/*!
 *  @abstract Called when internal logic changes queue order.  All we need to do is refresh the tables.
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineInternalQueueUpdateNotification
 *
 */
-(void)downloadEngineInternalQueueUpdate;

/*!
 *  @abstract Called whenever the Engine encounters a recoverable issue.
 *
 *  @discussion Called whenever the Engine encounters a recoverable issue.  These are events that MAY be of concern to the Caller, but the Engine will
 *  continue the download process without intervention.
 *
 *  @param asset VirtuosoAsset asset
 *
 *  @param error optional NSError
 *
 */
-(void)downloadEngineDidEncounterWarningForAsset:(VirtuosoAsset* _Nonnull)asset error:(NSError* _Nullable)error;

/*!
 *  @abstract Called whenever the Engine encounters an error
 *
 *  @discussion Called whenever the Engine encounters an error that it cannot recover from.  This type of error will cause the engine to retry download of the file.  If too many errors are encountered, the Engine will move on to the next item in the queue.
 *
 *  @param asset VirtuosoAsset asset
 *
 *  @param error NSError for indicating the error details
 *
 *  @param task NSURLSessionTask for the error
 *
 *  @param data NSData for the HTTP Response.
 *
 *  @param statusCode Http Status Code (NSNumber integerValue) if this was for an Http error.
 *
 */
-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset* _Nonnull)asset
                                         error:(NSError* _Nullable)error
                                          task:(NSURLSessionTask* _Nullable)task
                                          data:(NSData* _Nullable)data
                                    statusCode:(NSNumber* _Nullable)statusCode;

/*!
 *  @abstract Called whenever the Engine is about to enter background
 *
 *  @discussion Called some period of time after the main application has been put into the background by the User.  Depending on application configuration, the Engine will keep the app alive in the background for some period of time in order to continue active downloads.  Once the Engine cannot keep the application alive any longer, due to iOS constraints, the Engine will pause downloads and allow the application to be put to sleep.  Before going to sleep, this notification is called to allow the Caller to take potential action if downloads were still pending at this point.
 *
 *  @param continuingAssets VirtuosoAsset asset
 *
 *  @param pausingAssets NSError for indicating the error details
 *
 */
-(void)downloadEngineIsEnteringBackground:(NSArray* _Nullable)continuingAssets pausingAssets:(NSArray* _Nullable)pausingAssets;

/*!
 *  @abstract Called whenever the Engine enabled or disabled
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineEnableDisableChangeNotificationKey
 *
 *  @param enabled True indicates engine was enabled, False was disabled
 */
-(void)downloadEngineEnableStateChange:(Boolean)enabled;

/*!
 *  @abstract Called when data store update begins
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDidBeginDataStoreUpgradeNotification
 *
 */
-(void)downloadEngineDidBeginDataStoreUpgrade;

/*!
 *  @abstract Called when data store update finishes
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineDidFinishDataStoreUpgradeNotification
 *
 */
-(void)downloadEngineDidFinishDataStoreUpgrade;

/*!
 *  @abstract Called when Asset.deleteAll completes
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEngineAllAssetsDeletedNotification
 *
 */
-(void)downloadEngineAllAssetsDeleted;

/*!
 *  @abstract Called when Asset.deleteAssets completes
 *
 *  @discussion This callback is invoked in-response to Notification kDownloadEnginelAssetsDeletedNotification
 *
 *  @param deletedAssetIDs Array of assetIDs for the deleted assets
 *
 */
-(void)downloadEngineAssetsDeleted:(NSArray<NSString*>*  _Nullable)deletedAssetIDs;

/*!
 *  @abstract Called when startupWithBackplane completes
 *
 *  @discussion This callback is invoked when startupWithBackplane completes.
 *
 *  @param succeeded YES indicates the backplane started successfully, NO indicates failure.
 */
-(void)downloadEngineStartupComplete:(Boolean)succeeded;

/*!
 *  @abstract Called when startupWithBackplane detects user change that will require assets be deleted.
 *
 *  @discussion Called when startupWithBackplane detects user change that will require assets be deleted.
 *
 */
-(void)downloadEngineStartupUserDeleteStarted;

/*!
*  @abstract Called when the operating system detects a change in network reachability.
*
*  @discussion This callback is invoked when the operating system detects a change in network reachability.
*
*  @param previousNetworkReachability The previous state of network reachability.  During the first invocaton of the callback this value will always be kVL_Invalid.
*
*  @param currentNetworkReachability The current state of network reachability.  Compare currentNetworkReachability with previousNetworkReachability to determine change in network reachability.
*
*/

-(void)downloadEngineNetworkReachabilityChange:(kVL_BearerType)previousNetworkReachability
                    currentNetworkReachability:(kVL_BearerType)currentNetworkReachability;

/*!
*  @abstract Called when a FastPlay Asset is ready to play.
*
*  @discussion This callback is invoked when a FastPlay Asset is ready to play.
*
*  @param asset VirtuosoAsset for asset that is ready for FastPlay
*
*/
-(void)downloadEngineFastPlayAssetReady:(VirtuosoAsset* _Nonnull)asset;

/*!
*  @abstract Called when playback is stopped on an asset.
*
*  @param asset VirtuosoAsset for asset that was playing
*
*/
-(void)downloadEnginePlaybackStopped:(VirtuosoAsset* _Nonnull)asset;

/*!
 @abstract Download permission granted
 
 @discussion This callback is invoked when permission has been granted for an asset. This notificaiton is only emitted when Permissions are enabled.
 
 @param asset Asset for which permission was granted
 @param date Date and Time when permission was granted
 */
-(void)permissionGrantedForAsset:(VirtuosoAsset* _Nonnull)asset  requestDate:(NSDate* _Nonnull)date ;

/*!
*  @abstract Download permission was denied
*
*  @discussion This callback is invoked when permission has been denied for an asset. This notificaiton will only be emitted when Permissions are currently enabled.
*
 @param asset Asset for which permisison to download was denied
 @param date Date and time when request was made
 @param reason Reason why permision was denied. See kVBP_StatusCode
*
*/
-(void)permissionDeniedForAsset:(VirtuosoAsset* _Nonnull)asset requestDate:(NSDate* _Nonnull)date withReason:(kVBP_StatusCode)reason;

/*!
*  @abstract Initial settings for Permisions
*
*  @discussion This callback is invoked at startup to notify listeners of initial Permission settings
*
 * @param changes Array of VirtuosoPermissionSettingInfo for permission settings.
 * @param requestDate Date and time when request was made
*
*/
-(void)permissionSettingInitialState:(NSArray<VirtuosoPermissionSettingInfo*>* _Nonnull)changes requestDate:(NSDate* _Nonnull)requestDate;

/*!
*  @abstract Permission settings changes
*
*  @discussion This callback is invoked when permission has received permission setting changes.
*
 @param changes Array of VirtuosoPermissionSettingInfo for permission settings that have changed.
 @param requestDate Date and time when request was made
 @param source Source of call that generated this setting change.
*
*/
-(void)permissionSettingChange:(NSArray<VirtuosoPermissionSettingInfo*>* _Nonnull)changes  requestDate:(NSDate* _Nonnull)requestDate source:(NSString*_Nullable)source;


/*!
*  @abstract Playlist change
*
*  @discussion This callback is invoked when a playlist change happens
*
 @param playlist Playlist that has changed
*
*/
-(void)playlistChange:(VirtuosoPlaylist* _Nonnull)playlist;

@end

/*!
 *  @abstract Listens for Download Engine Notifications and invokes the VirtuosoDownloadEngineNotificationsDelegate callbacks.
 *
 *  @discussion Use this class to monitor Engine notifications. Implement the VirtuosoDownloadEngineNotificationsDelegate and register it using  VirtuosoDownloadEngineNotificationManager to receive Notifications.
 */
@interface VirtuosoDownloadEngineNotificationManager : NSObject

/*!
 *  @abstract Delegate callback
 */
@property (nonatomic, strong, readonly)id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull delegate;

/*!
 *  @abstract Operation queue upon which the callbacks will happen
 */
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull notifyQueue;

/*!
 *  @abstract Asset ID that will be used to filter delegate callbacks. Nil to skip filtering.
 */
@property (nonatomic, strong, readonly)NSString* _Nullable assetID;

/*!
 *  @abstract Creates an instance
 *
 *  @param delegate Delegate that will be called
 *
 *  @return Instance of this component, nil on failure.
 *
 */
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate;

/*!
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

/*!
 *  @abstract Creates an instance
 *
 *  @param delegate Delegate that will be called
 *
 *  @param assetID Asset ID for the asset to filter on, nil to skip filtering.
 *
 *  @return Instance of this component, nil on failure.
 *
*/
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate
                                  assetID:(NSString* _Nullable)assetID;

/*!
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

/*!
 *  @abstract Unregister event listener
 *  @discussion Unregister event listener will stop posting notifcations to the delegate.
*/
-(void)unregister;

@end

#endif /* VirtuosoDownloadEngineNotificationsManager_h */
