//
//  VirtuosoBackplaneNotificationsManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 11/8/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#ifndef VirtuosoBackplaneNotificationsManager_h
#define VirtuosoBackplaneNotificationsManager_h

/*!
*  @abstract Delegate interface for Backplane notifications
*/
@protocol VirtuosoBackplaneNotificationsDelegate <NSObject>

@required

/*!
*  @abstract Called when Backplane sync completes.
*
*  @param status Boolean (true) indicates success.
*
*  @param error NSError indciating the error
*
*/
-(void)backplaneSyncCompleteWithStatus:(Boolean)status error:(NSError* _Nullable)error;

/*!
*  @abstract Called when a Backplane requested remote kill has completed.
*
* @discussion  A remote kill will unregister the app from Penthera, and delete all assets that were created in Penthera.
*/
-(void)backplaneRemoteKill;

/*!
*  @abstract Called when a Backplane requested is about to start a remote kill.
*/
-(void)backplaneStartingRemoteKill;

/*!
*  @abstract Called when a Backplane requested unregistering the device.
 *
 * @param success Boolean (true) indicates success.
 *
 * @param error NSError if an error occured.
*/
-(void)backplaneDidUnregisterDeviceWithStatus:(Boolean)success error:(NSError* _Nullable)error;

@end


/*!
*  @abstract Listens to Backplane notications.
*/
@interface VirtuosoBackplaneNotificationsManager : NSObject

/*!
*  @abstract Delegate callback
*/
@property (nonatomic, strong, readonly)id<VirtuosoBackplaneNotificationsDelegate> _Nonnull delegate;

/*!
*  @abstract Operation queue upon which the callbacks will happen
*/
@property (nonatomic, strong, readonly)NSOperationQueue* _Nonnull processingQueue;

/*!
*  @abstract Creates an instance
*
*  @param delegate Delegate that will be called
*
*  @return Instance of this component, nil on failure.
*
*/
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoBackplaneNotificationsDelegate> _Nonnull)delegate;

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
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoBackplaneNotificationsDelegate> _Nonnull)delegate queue:(NSOperationQueue* _Nonnull)queue;

/*!
 *  @abstract Unregister event listener
 *  @discussion Unregister event listener will stop posting notifcations to the delegate.
*/
-(void)unregister;

@end

#endif /* VirtuosoBackplaneNotificationsManager_h */
