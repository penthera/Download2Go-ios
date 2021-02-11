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

/*!
*  @abstract Delegate interface for Download Engine Ads notifications
*/
@protocol VirtuosoAdsManagerNotificationDelegate <NSObject>

@required

/*!
*  @abstract Called when Ads refresh fails
*
*  @param asset VirtuosoAsset for the Ad that failed to refresh.
*
*  @param error NSError indciating the error
*
*/
-(void)adsRefreshFailure:(VirtuosoAsset* _Nonnull)asset
                        error:(NSError* _Nullable)error;

/*!
*  @abstract Called when an Ad is being refreshed
*
*  @discussion This callback will happen when the engine is refreshing Ads for a VirtuosoAsset.
*
*  @param asset VirtuosoAsset for the Ad that is being refreshed
*
*/
-(void)adsRefreshStatusUpdate:(VirtuosoAsset* _Nonnull)asset;

/*!
*  @abstract Called whenever an Ad tracking beacon has been reported
*
*  @param asset VirtuosoAsset for which the tracking beacon was reported. This will be nil if the asset has since been deleted. 
*
*  @param url Ads beacon URL that was reported
*
*  @param httpResponseCode status code for request
*
*  @param userInfo NSDictionary containing both the asset.assetID (kDownloadEngineAssetIDKey) and asset.uuid (kDownloadEngineAssetUUIDKey)
*
*/
-(void)adsTrackingNotificationForAsset:(VirtuosoAsset* _Nullable)asset url:(NSString* _Nonnull)url httpResponseCode:(NSInteger)httpResponseCode userInfo:(NSDictionary* _Nonnull)userInfo;
@end

/*!
*  @abstract Listens for Ads related Engine notifications.
*
*  @discussion Use this class to monitor Ads related Engine notifications. Implement the VirtuosoAdsManagerNotificationDelegate and register it using  VirtuosoAdsNotificationsManager to receive Notifications.
*/
@interface VirtuosoAdsNotificationsManager : NSObject

/*!
*  @abstract Delegate callback
*/
@property (nonatomic, strong, readonly)id<VirtuosoAdsManagerNotificationDelegate> _Nonnull delegate;

/*!
*  @abstract Operation queue upon which the callbacks will happen
*/
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull notifyQueue;

/*!
*  @abstract Asset ID that will be used to filter delegate callbacks. Nil to skip filtering.
*/
@property (atomic, copy)NSString* _Nullable assetID;

/*!
*  @abstract Creates an instance
*
*  @param delegate Delegate that will be called
*
*  @return Instance of this component, nil on failure.
*
*/
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoAdsManagerNotificationDelegate> _Nonnull)delegate;

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
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoAdsManagerNotificationDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;

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
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoAdsManagerNotificationDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue assetID:(NSString* _Nullable)assetID;

/*!
 *  @abstract Unregister event listener
 *  @discussion Unregister event listener will stop posting notifcations to the delegate.
*/
-(void)unregister;

@end

#endif /* VirtuoslAdsNotificationManager_h */
