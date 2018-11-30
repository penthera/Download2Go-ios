//
//  VirtuosoBackplaneNotificationsManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 11/8/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#ifndef VirtuosoBackplaneNotificationsManager_h
#define VirtuosoBackplaneNotificationsManager_h

@protocol VirtuosoBackplaneNotificationsDelegate <NSObject>

@required

// kBackplaneSyncResultNotification
-(void)backplaneSyncCompleteWithStatus:(Boolean)status error:(NSError* _Nullable)error;

/*
 *  Called whenever the Backplane deletes assets
 */
// kBackplaneAssetDeletedNotification
-(void)backplaneDeletedAssetId:(NSString* _Nonnull)assetID;

/*
 *  The Backplane issued a remote kill request.  The SDK will have reverted back to an uninitialized state and we must call the startup method again.  In this demo,
 *  we query the User for the Group and User to use, so we're going to revert ourselves back to startup state and ask for those values again, before calling startup.
 */
// kBackplaneRemoteKillNotification
-(void)backplaneRemoteKill;

/*
 * When the Backplane notifies us that our device was unregistered, treat it like a remote wipe request.  The unregister action will already have cleared
 * out all the SDK state, so we just need to reset and ask for credentials again.
 */
// kBackplaneDidUnregisterDeviceNotification
-(void)backplaneDidUnregisterDeviceWithStatus:(Boolean)success error:(NSError* _Nullable)error;

@end

@interface VirtuosoBackplaneNotificationsManager : NSObject

@property (nonatomic, strong, readonly)id<VirtuosoBackplaneNotificationsDelegate> _Nonnull delegate;
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull queue;

-(instancetype _Nullable)initWithDelegate:(id<VirtuosoBackplaneNotificationsDelegate> _Nonnull)delegate;
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoBackplaneNotificationsDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;

@end

#endif /* VirtuosoBackplaneNotificationsManager_h */
