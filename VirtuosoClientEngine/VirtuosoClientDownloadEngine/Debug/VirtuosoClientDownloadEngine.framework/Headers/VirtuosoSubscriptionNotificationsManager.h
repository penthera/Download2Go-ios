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

/*!
*  @abstract Delegate interface for Subscriptions notifications
*/
@protocol VirtuosoSubscriptionsManagerDelegate <NSObject>

@required

/*!
*  @abstract Subscription manager has deleted assets.
 *
 * @param assetIdentifiers Array of Asset.assetID's for the assets that have been deleted.
*/
-(void)subscriptionManagerAssetDelete:(NSArray<NSString*>* _Nonnull)assetIdentifiers;

/*!
*  @abstract Subscription manager has created assets.
 *
 * @param assets Array of VirtuosoAsset that have been created
*/
-(void)subscriptionManagerAddedAssets:(NSArray<VirtuosoAsset*>* _Nonnull)assets;

@end


/*!
*  @abstract Listens for Subscription related notifications.
*
*  @discussion Use this class to monitor Subscription related notitications. Implement the VirtuosoSubscriptionsManagerDelegate and register it using  VirtuosoSubscriptionNotificationsManager to receive Notifications.
*/
@interface VirtuosoSubscriptionNotificationsManager : NSObject


/*!
*  @abstract Operation queue upon which the callbacks will happen
*/
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull queue;

/*!
*  @abstract Delegate callback
*/
@property (nonatomic, strong, readonly)id<VirtuosoSubscriptionsManagerDelegate> _Nonnull delegate;


/*!
*  @abstract Creates an instance
*
*  @param delegate Delegate that will be called
*
*  @return Instance of this component, nil on failure.
*
*/
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoSubscriptionsManagerDelegate> _Nonnull)delegate;

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
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoSubscriptionsManagerDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;

@end

#endif /* VirtuosoNotificationManager_h */
