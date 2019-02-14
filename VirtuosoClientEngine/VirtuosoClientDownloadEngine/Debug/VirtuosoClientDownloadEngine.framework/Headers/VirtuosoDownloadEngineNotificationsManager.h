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

@class VirtuosoAsset;

@protocol VirtuosoDownloadEngineNotificationsDelegate <NSObject>

// MARK: DownloadEngine
@required
/*
 *  Called whenever the Engine starts downloading a VirtuosoAsset object.
 */
// kDownloadEngineDidStartDownloadingAssetNotification
-(void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  Called whenever the Engine reports progress for a VirtuosoAsset object
 */
// kDownloadEngineProgressUpdatedForAssetNotification
-(void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  Called when an asset is being processed after background transfer
 */
// kDownloadEngineProgressUpdatedForAssetProcessingNotification
-(void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  Called whenever the Engine reports a VirtuosoAsset as complete
 */
// kDownloadEngineDidFinishDownloadingAssetNotification
-(void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset* _Nonnull)asset;

@optional
/*
 *  Called whenever the Engine reports refresh of DRM
 */
// kDownloadEngineDRMRefreshForAssetNotification
-(void)downloadEngineDRMRefreshForAsset:(VirtuosoAsset* _Nonnull)asset;

/*
 *  Called whenever the Engine status changes
 */
// kDownloadEngineStatusDidChangeNotification
-(void)downloadEngineStatusChange:(kVDE_DownloadEngineStatus)status;
/*
 *  Called when internal logic changes queue order.  All we need to do is refresh the tables.
 */
// kDownloadEngineInternalQueueUpdateNotification
-(void)downloadEngineInternalQueueUpdate;

/*
 *  Called whenever the Engine encounters a recoverable issue.  These are events that MAY be of concern to the Caller, but the Engine will continue
 *  the download process without intervention.
 */
// kDownloadEngineDidEncounterWarningNotification
-(void)downloadEngineDidEncounterWarningForAsset:(VirtuosoAsset* _Nonnull)asset error:(NSError* _Nullable)error;

/*
 *  Called whenever the Engine encounters an error that it cannot recover from.  This type of error will cause the engine to retry download of the file.  If too many
 *  errors are encountered, the Engine will move on to the next item in the queue.
 */
// kDownloadEngineDidEncounterErrorNotification
-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset* _Nonnull)asset error:(NSError* _Nullable)error;

/*
 *  Called some period of time after the main application has been put into the background by the User.  Depending on application configuration, the Engine will keep the
 *  app alive in the background for some period of time in order to continue active downloads.  Once the Engine cannot keep the application alive any longer, due to iOS
 *  constraints, the Engine will pause downloads and allow the application to be put to sleep.  Before going to sleep, this notification is called to allow the Caller
 *  to take potential action if downloads were still pending at this point.
 */
// kDownloadEngineIsEnteringBackgroundNotification
-(void)downloadEngineIsEnteringBackground:(NSArray* _Nullable)continuingAssets pausingAssets:(NSArray* _Nullable)pausingAssets;

/*
 *  Called whenever the Engine enabled or disabled
 */
// kDownloadEngineEnableDisableChangeNotificationKey
-(void)downloadEngineEnableStateChange:(Boolean)enabled;

// kDownloadEngineDidBeginDataStoreUpgradeNotification
-(void)downloadEngineDidBeginDataStoreUpgrade;

// kDownloadEngineDidFinishDataStoreUpgradeNotification
-(void)downloadEngineDidFinishDataStoreUpgrade;

@end

@interface VirtuosoDownloadEngineNotificationManager : NSObject

@property (nonatomic, strong, readonly)id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull delegate;
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull queue;
@property (atomic, copy)NSString* _Nullable assetID;

-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate;
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoDownloadEngineNotificationsDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue assetID:(NSString* _Nullable)assetID;

@end

#endif /* VirtuosoDownloadEngineNotificationsManager_h */
