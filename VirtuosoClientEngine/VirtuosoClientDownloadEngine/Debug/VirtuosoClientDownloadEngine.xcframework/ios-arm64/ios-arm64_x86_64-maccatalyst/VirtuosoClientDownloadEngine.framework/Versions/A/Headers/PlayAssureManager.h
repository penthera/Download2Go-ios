//
//  PlayAssureManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 7/20/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/PlayAssureConfig.h>

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@class StreamItemParameters;
@class StreamItem;
@class PlayAssureABPlayerViewController;

extern NSString* NotificationAVPlayer_Paused;
extern NSString* NotificationAVPlayer_Resumed;

/*!
*  @typedef NetworkCheckCallback
*
*  @discussion Callback for isNetworkReady
*
*  @param success True indicates network is ready.
*/
typedef void(^NetworkCheckCallback)(Boolean success);

/*!
*  @abstract Manages PlayAssure playback.
*
*  @discussion Manages stream assured playback by proxying streaming requests and downloading content in-advance of need and caching it locally.
*
* @see PlayAssureConfig
*/
@interface PlayAssureManager : NSObject

/*!
*  @abstract URL that Player should use to stream
*
*  @discussion PlayAssure will proxy all streaming playback. This property provides the URL the Player should use to start playback. If PlayAssure is not handling playback during A/B testing, the streamingURL returned will be the same streamingURL provided in the initWithManifestURL initializer.
*/
@property (nonatomic, copy, readonly)NSString* _Nonnull streamingURL;

/*!
*  @abstract Configures the various options for PlayAssure playback.
*
*  @discussion Create an instance of this object and provide it when initializing PlayAssureManager.
*/
@property (nonatomic, strong, readonly)PlayAssureConfig* config;

/*!
*  @abstract Verify network is connected and internet is fully reachable.
*
*  @discussion This method will ping the internet to ensure it's reachable. Because this requires a background state transition, the call is will return immediately and the callback will be invoked async on the callers thread.
 *
*  @param callback This callback will be invoked with a Boolean stattus indicating whether internet was reachable (true).
 *
*/
+(void)isNetworkReady:(NetworkCheckCallback _Nonnull)callback;

/*!
*  @abstract Creates new instance of PlayAssureManager
*
*  @discussion Creates an instance of the PlayAssureManager using the specified configuration. This will cause the PlayAssureManager to immediately begin downloading and parsing the requried manifests.
 *
*  @param streamingURL Manifest to stream
 *
*  @param config PlayAssureConfig used to configure PlayAssure
 *
*  @param error Returns NSError should the initializer fail
*
*  @return A new PlayAssureManager object, or nil if an error occurred.
*/
-(instancetype)initWithManifestURL:(NSString*)streamingURL config:(PlayAssureConfig* _Nonnull)config  error:(NSError**)error;

/*!
*  @abstract Shutdown and stop Stream Assured playback.
*
*  @discussion Shutdown and stop Stream Assured playback.
 *
*/
-(void)shutdown;

/*!
*  @abstract Flag indicating Stream Assured has downloaded all segments necessary for a complete playback session.
*
*  @discussion  Flag indicating Stream Assured has downloaded all segments necessary for a complete playback session.
*
* @return Boolean indicating download has completed.
 *
*/
-(Boolean)isComplete;

/*!
*  @abstract Adds a text layer displaying PlayAssure status.
*
*  @discussion Adds a text layer displaying PlayAssure status to the provided view (normally a AVPlayerView).  The text will be centered within the view.
*
*  @param view UIView to add status layer.
*
*  @param prefix Text to prepend to status string.
*/
-(void)addStatusLayerToView:(UIView*)view withPrefix:(nullable NSString*)prefix;

/*!
*  @abstract Transition Status Layer to new size.
*
*  @discussion Call when mode transitions between portrait/landscape.
*
*  @param size New size.
*/
-(void)transitionStatusLayerToSize:(CGSize)size;

/*!
*  @abstract Adds a UIView as a subivew displaying PlayAssure cache progress.
*
*  @discussion Adds a subview displaying PlayAssure cache progress  to the provided view (normally a AVPlayerView).  The subview will be centered within the view.
*
*  @param view UIView to add cache progress subview.
*/
-(void)addCacheProgressLayerToView:(UIView*)view;

/*!
*  @abstract Transition cache progress view to new size.
*
*  @discussion Call when mode transitions between portrait/landscape.
*
*  @param size New size.
*/
-(void)transitionCacheProgressLayerToSize:(CGSize)size;

/*!
*  @abstract Methods for A/B playback testing.
*
*  @discussion Methods for A/B playback testing.
*/

/*!
*  @abstract Percentage of A/B playback sessions that will use PlayAssure.
*
*  @discussion Percentage of A/B playback sessions that will use PlayAssure represented by a value in interval (0.0, 1.0).  A value of 1.0 indicates all sessions will use PlayAssure, 0.0 no sessions will use PlayAssure, etc.
*
*/
+(double)ABPlaybackPercentage;

/*!
*  @abstract Randomized method for A/B testing indicating whether PlayAssure or streaming playback should be used .
*
*  @discussion For A/B testing use this method to determine whether a PlayAssure or streaming session should be started.  The value is determined randomly, using the ABPlaybackPercentage. This method is not idempotent.  If you need to reference the value, save the state locally.
*
* @return Boolean indicating a PlayAssure session should be started.
*
*/
+(Boolean)usePlayAssurePlaybackForABTesting;

/*!
*  @abstract Convenience method that provides a basic playback controller for A/B testing.
*
* @discussion Convenience method that provides a basic playback controller, generating a playback event.  The controller will either present a controller for a PlayAssure controller or streaming session based on the randomized usePlayAssurePlaybackForABTesting method.
*
* @param url Manifest to stream
*
* @param targetBitrate If using PlayAssure Backstop mode, the target bitrate. Pass -1 otherwise.
*
* @param displayStatus Flag indicating whether a playback status message should be superimposed on the video during playback.
*
* @param videoDescription Description of video that will be displayed as part of the playback status message.
*
* @return UIViewController for streaming playback.
*/
+(PlayAssureABPlayerViewController*)PlayAssureABPlayerViewControllerForURL:(NSString*)url
                                                             targetBitrate:(long long)targetBitrate
                                                             displayStatus:(Boolean)displayStatus
                                                          videoDescription:(NSString*)videoDescription;

/*!
*  @abstract Flag indicating whether PlayAssure is actively running for this session.
*
*  @discussion For A/B testing, this flag indicates whether playback is via PlayAssure (true) or straight streaming (false). If PlayAssure is not handling playback during A/B testing, the streamingURL returned will be the same streamingURL provided in the initWithManifestURL initializer.
*/
@property (nonatomic, readonly)Boolean playAssureSession;

@end

NS_ASSUME_NONNULL_END
