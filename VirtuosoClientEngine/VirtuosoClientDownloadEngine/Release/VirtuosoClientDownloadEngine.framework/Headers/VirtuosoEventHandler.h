/*!
 *  @header Virtuoso Event Handler
 *
 *  PENTHERA CONFIDENTIAL
 *
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  @copyright (c) 2016 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VEVENT_HANDLER
#define VEVENT_HANDLER

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


/*!
 *  @abstract Provides a common static interface for all Virtuoso modules to handle incoming app delegate events.
 *
 *  @discussion Virtuoso modules may handle a variety of event types that iOS normally routes to the Application
 *              Delegate.  These event types may include various kinds of push notices or NSURLSession notices.  
 *              To centralize responsibility and simplify code in the enclosing Application Delegate, 
 *              VirtuosoEventHandler provides a single point of entry for incoming event messages.  The 
 *              VirtuosoEventHandler will route the event within Virtuoso as-needed and will return whether
 *              or not the event was handled.  If the event was handled, you have no further responsibility.  
 *              If not, then Virtuoso took no action with it, and it is your responsibility to parse the 
 *              iOS-provided event data and take action.
 */
@interface VirtuosoEventHandler : NSObject

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

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
                      completionHandler:(nonnull void (^)())completionHandler;

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
             withCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;

/*!
 *  @abstract Handles background fetch
 *
 *  @discussion When the enclosing app enables the background fetch feature, Virtuoso can use those application
 *              wakes to perform standard maintenance tasks, such as posting log events to the Backplane or syncing
 *              with the subscription system.
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
+ (void)processFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;

#else

/**---------------------------------------------------------------------------------------
 * @name Mac Event Handling Methods
 *  ---------------------------------------------------------------------------------------
 */

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
 *
 *  @return Whether Virtuoso handled the push notice
 */
+ (Boolean)processRemotePushNotice:(nonnull NSDictionary*)userInfo;

#endif

@end

#endif
