/*!
 *  @header Virtuoso Client HTTP Server
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

#ifndef VCLIENT_HTTP_SERVER
#define VCLIENT_HTTP_SERVER

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+HLS.h>

/*!
 *  @abstract A proxy layer that sits between the video player and a Virtuoso-managed (video) asset
 *
 *  @discussion A localhost HTTP proxy server that enables transparent playback of downloaded video within
 *              Apple or 3rd party video players.
 *
 *              This class abstracts the location and download state of the video from the video player.
 *              In the case of HLS video, for example, this class will generate an "on the fly"
 *              HLS manifest that lists a localhost URL for each manifest URL.  The server receives each
 *              localhost request and then returns the local or remote data, as available.
 *
 *  @warning To use this class directly, you must retain the instantiated object within your code.
 *           If you release an instantiated proxy object, the proxy will immediately shut down 
 *           and become unavailable.
 */

@interface VirtuosoClientHTTPServer : NSObject
{
}

/*!
 *  @abstract Creates a local HTTP proxy on a random port using the specified asset
 *
 *  @discussion The proxy uses the local manifest, remote URL, and segment file root path from the provided
 *              VirtuosoAsset to construct a streaming URL for the video player.  Use this method,
 *              rather than the playback methods on the VirtuosoAsset, for more direct control of the
 *              proxy, which is especially useful for custom video players.
 *
 *  @param asset A VirtuosoAsset object to base streamed playback from.
 *               The server will use the internal data from the VirtuosoAsset
 *               to dynamically contruct the playback URL for the player.
 *
 *  @return A started (running) VirtuosoClientHTTPServer object.
 *          Returns nil if the VirtuosoAsset is outside its availability window, is expired,
 *          or if the VirtuosoDownloadEngine instance is outside its Backplane communications
 *          window. If this method returns nil, it also sends errors via NSNotificationCenter
 *          indicating the problem.
 */
-(nullable id)initWithAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Creates a local HTTP proxy on the specified port using the specified asset
 *
 *  @discussion The proxy uses the local manifest, remote URL, and segment file root path from the provided 
 *              VirtuosoAsset to construct a streaming URL for the video player.  Use this method,
 *              rather than the playback methods on the VirtuosoAsset, for more direct control of the
 *              proxy, which is especially useful for custom video players.
 *
 *  @param port The local port to open with the localhost server
 *
 *  @param asset A VirtuosoAsset object to base streamed playback from.
 *               The server will use the internal data from the VirtuosoAsset 
 *               to dynamically contruct the playback URL for the player.
 *
 *  @return A started (running) VirtuosoClientHTTPServer object.
 *          Returns nil if the VirtuosoAsset is outside its availability window, is expired, 
 *          or if the VirtuosoDownloadEngine instance is outside its Backplane communications 
 *          window. If this method returns nil, it also sends errors via NSNotificationCenter 
 *          indicating the problem.
 */
-(nullable id)initOnPort:(NSInteger)port withAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Shuts down a running proxy instance
 * 
 *  @discussion You can call the startup method to restart the proxy using the same settings.
 *
 */
-(void)shutdown;

/*!
 *  @abstract Restarts a previously shutdown proxy instance.  Does nothing if the receiver is already running.
 */
-(void)startup;

/*!
 *  @abstract Indicates whether the receiver is currently running.
 *
 */
@property (nonatomic,readonly) Boolean running;

/*!
 *  @abstract The dynamically-generated playback URL string. Pass this URL to a video player for playback
 *
 *  @discussion This URL will represent a streaming video URL of an appropriate protocol,
 *              based on the 'type' property of the provided VirtuosoAsset.
 *
 */
@property (nonatomic,readonly,nonnull) NSString* playbackURL;

@end

#endif
