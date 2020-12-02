//
//  VirtuosoEventHandler.h
//  VirtuosoClientDownloadEngine
//
//  Created by dev on 7/25/19.
//  Copyright © 2019 Penthera. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VirtuosoEventHandlerDelegate <NSObject>

- (Boolean)canProcessRemotePushNotice:(NSDictionary*)userInfo;
- (Boolean)processBackgroundSessionWake:(NSString*)identifier completionHandler:(void (^)(void))completionHandler;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (void)processRemotePushNotice:(NSDictionary*)userInfo withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)processFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
#else
- (void)processRemotePushNotice:(NSDictionary*)userInfo;
#endif
@end

/*!
*
*  @abstract Handles processing of various events including pushes, background wakes from downloading, etc.
*
*/
@interface VirtuosoEventHandler : NSObject

+ (void)registerHandler:(_Nonnull id<VirtuosoEventHandlerDelegate>)delegate  __attribute__((deprecated("method removed")));
+ (void)removeHandler:(_Nonnull id<VirtuosoEventHandlerDelegate>)delegate  __attribute__((deprecated("method removed")));

/**---------------------------------------------------------------------------------------
 * @name iOS Event Handling Methods
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Handles processing of background download session notices
 *
 *  @discussion Under iOS 7, apps may use the iOS background download APIs to download data without
 *              the app having to remain active. When the background download session completes, iOS wakes up
 *              the app via the application:handleEventsForBackgroundURLSession:completionHandler: method
 *              in the app delegate.  Virtuoso handles this event similarly to how it handles incoming push notices.
 *              You must invoke Virtuoso's processBackgroundSessionWake:completionHandler: method before
 *              taking any further actions.  If this method returns YES, then the wake was for Virtuoso.
 *              If this method returns NO, then the wake wasn't intended for Virtuoso; you need to handle it.
 *
 *  @param identifier The background session identifier the wake is for
 *  @param completionHandler The handler callback provided by the iOS7+ UIApplicationDelegate background session method
 *
 *  @return Whether Virtuoso handled the session wake
 */
+ (Boolean)processBackgroundSessionWake:(nonnull NSString*)identifier
                      completionHandler:(nonnull void (^)(void))completionHandler __attribute__((deprecated("method removed")));

/*!
 *  @abstract Handles remote push notices
 *
 *  @discussion The Backplane sends push notices to instruct Virtuoso to perform certain actions:
 *              delete an asset, enqueue an asset, etc. The Backplane sends these notices to Virtuoso by
 *              way of the enclosing app.
 *              Whenever the enclosing app receives a remote notice via any of the standard app delegate methods,
 *              it must call this method first, to let Virtuoso have a crack at it. If this method returns YES,
 *              that means Virtuoso handled the notice. If this method returns NO, then Virtuoso did not
 *              handle the push notice, and the enclosing app should handle it.
 *
 *  @param userInfo The userInfo dictionary provided by the remote push notice
 *  @param completionHandler The handler callback provided by the iOS 7+ UIApplicationDelegate remote push method
 *
 *  @return Whether Virtuoso handled the push notice
 */
+ (Boolean)processRemotePushNotice:(nonnull NSDictionary*)userInfo
             withCompletionHandler:(nullable void (^)(UIBackgroundFetchResult))completionHandler __attribute__((deprecated("method removed")));

/*!
 *  @abstract Handles background fetch
 *
 *  @discussion When the enclosing app enables the background fetch feature, Virtuoso can use those application
 *              wakes to perform standard maintenance tasks, such as posting log events to the Backplane.
 *
 *  @warning    Since several SDK entities may wish to perform work alongside the enclosing application itself,
 *              this method MUST NOT receive a reference to the completion handler provided by the OS.  Instead,
 *              the enclosing application should pass its own callback block and use that to properly call the OS
 *              completion handler at the appropriate time.  If you pass the OS completion handler to this method,
 *              the app may go to sleep unexpectedly.  Please reference the SdkDemo application for one example of
 *              how to properly implement this method.
 *
 *  @param completionHandler The handler callback provided by the iOS 7 UIApplicationDelegate remote push method
 */
+ (void)processFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler __attribute__((deprecated("method removed")));


@end

NS_ASSUME_NONNULL_END
