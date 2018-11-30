//
//  VirtuosoNotificationManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 11/7/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#ifndef VirtuosoNotificationManager_h
#define VirtuosoNotificationManager_h
#import "VirtuosoConstants.h"
#import "VirtuosoSubscriptionNotificationsManager.h"

@class VirtuosoAsset;

@protocol VirtuosoSubscriptionsManagerDelegate <NSObject>

@required
/*
 *  The Subscription Manager may auto-delete assets that exceed the maximum items per feed.  If you are maintaining your own metadata and
 *  are linking the VirtuosoAsset UUID values to your own metadata, then you should update your bookeeping here.
 */
// kSubscriptionManagerAssetDeletedNotification
-(void)subscriptionManagerAssetDelete:(NSArray<NSString*>* _Nonnull)assetIdentifiers;

/*
 *  When the Subscription Manager adds new assets, we need to refresh the views, so the new assets get shown
 */
// kSubscriptionManagerAssetAddedNotification
-(void)subscriptionManagerAddedAssets:(NSArray<VirtuosoAsset*>* _Nonnull)assets;

@end


@interface VirtuosoSubscriptionNotificationsManager : NSObject

@property (nonatomic, strong, readonly)id<VirtuosoSubscriptionsManagerDelegate> _Nonnull delegate;
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull queue;

-(instancetype _Nullable)initWithDelegate:(id<VirtuosoSubscriptionsManagerDelegate> _Nonnull)delegate;
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoSubscriptionsManagerDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;

@end

#endif /* VirtuosoNotificationManager_h */
