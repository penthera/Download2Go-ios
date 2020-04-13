//
//  VirtuoslAdsNotificationManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 11/8/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#ifndef VirtuoslAdsNotificationManager_h
#define VirtuoslAdsNotificationManager_h

@class VirtuosoAsset;

@protocol VirtuosoAdsManagerNotificationDelegate <NSObject>

@required
-(void)adsRefreshFailure:(VirtuosoAsset* _Nonnull)asset
                        error:(NSError* _Nullable)error;

-(void)adsRefreshStatusUpdate:(VirtuosoAsset* _Nonnull)asset;

-(void)adsTrackingNotificationForAsset:(VirtuosoAsset* _Nullable)asset url:(NSString* _Nonnull)url userInfo:(NSDictionary* _Nonnull)userInfo;
@end

@interface VirtuosoAdsNotificationsManager : NSObject

@property (nonatomic, strong, readonly)id<VirtuosoAdsManagerNotificationDelegate> _Nonnull delegate;
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull queue;
@property (atomic, copy)NSString* _Nullable assetID;

-(instancetype _Nullable)initWithDelegate:(id<VirtuosoAdsManagerNotificationDelegate> _Nonnull)delegate;
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoAdsManagerNotificationDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoAdsManagerNotificationDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue assetID:(NSString* _Nullable)sssetID;

@end

#endif /* VirtuoslAdsNotificationManager_h */
