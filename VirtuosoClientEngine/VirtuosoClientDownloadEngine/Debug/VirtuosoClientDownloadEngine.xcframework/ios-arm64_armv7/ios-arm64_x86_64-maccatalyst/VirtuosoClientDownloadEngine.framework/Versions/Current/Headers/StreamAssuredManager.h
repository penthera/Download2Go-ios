//
//  StreamAssuredManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 7/20/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamAssuredConfig.h"

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@class StreamItemParameters;
@class StreamItem;

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
*  @typedef SAM_Error
*
*  @abstract Error codes returned by SAM
*/
typedef NS_ENUM(NSInteger, SAM_Error)
{
    /** Network error */
    SAM_Error_Network,
    
    /** Invalid parameter error */
    SAM_Error_ParameterError,
    
    /** WebProxy startup failed */
    SAM_Error_WebProxyStartFailure,
    
    /** Manifest parsing failed */
    SAM_Error_ManifestParsingFailure,
    
    /** Sub-Manifest parsing failed */
    SAM_Error_SubManifestParsingFailure,
        
    /** Not authenticated. */
    SAM_Error_NotAuthenticated,

    /** Playback failure error */
    SAM_Error_PlaybackFailure,

};

/*!
*  @abstract Manages StreamAssured playback.
*
*  @discussion Manages stream assured playback by proxying streaming requests and downloading content in-advance of need and caching it locally.
*
* @see StreamAssuredConfig
*/
@interface StreamAssuredManager : NSObject

/*!
*  @abstract URL that Player should use to stream
*
*  @discussion StreamAssured will proxy all streaming playback. This property provides the URL the Player should use to start playback
*/
@property (nonatomic, copy, readonly)NSString* _Nonnull streamingURL;

/*!
*  @abstract Configures the various options for StreamAssured playback.
*
*  @discussion Create an instance of this object and provide it when initializing StreamAssuredManager.
*/
@property (nonatomic, strong, readonly)StreamAssuredConfig* config;

/*!
 * @abstract: Verify network is connected and internet is fully reachable.
 *
 * @discussion: This method will ping the internet to ensure it's reachable. Because this requires a background state transition, the call is will return immeidately and the callback will be invoked async on the callers thread.
 *
 * @param callback This callback will be invoked with a Boolean stattus indicating whether internet was reachable (true).
 */

/*!
*  @abstract Verify network is connected.
*
*  @discussion This method will ping the internet to ensure it's reachable. The callback will indicate success by returning true in the callback.
 *
*  @param callback Callback invoked once internet status has been checked.
 *
*/

+(void)isNetworkReady:(NetworkCheckCallback _Nonnull)callback;

/*!
*  @abstract Creates new instance of StreamAssuredManager
*
*  @discussion Creates an instance of hte SAM using the specified configuration. This will cause the SAM to immediately begin downloading and parsing the requried manifests.
 *
*  @param streamingURL Manifest to stream
 *
*  @param config StreamAssuredConfig used to configure StreamAssured
 *
*  @param error Returns NSError should the initializer fail
*
*  @return A new StreamAssuredManager object, or nil if an error occurred.
*/
-(instancetype)initWithManifestURL:(NSString*)streamingURL config:(StreamAssuredConfig* _Nonnull)config  error:(NSError**)error;

/*!
*  @abstract Shutdown and stop Stream Assured playback.
*
*  @discussion Shutdown and stop Stream Assured playback.
 *
*/

-(void)shutdown;

-(Boolean)isComplete;

+(UIViewController*)playAssurePlayerViewContollerForURL:(NSString*)url;

@end

NS_ASSUME_NONNULL_END
