//
//  StreamAssuredAVURLAsset.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 3/26/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract AVURLAsset wrapper for StreamAssured playback.
 *
 *  @discussion: Provides a mechanism for StreamAssured players to track player progress for analytic reporting.
 *
 *  StreamAssured players will use StreamAssuredAVURLAsset before playback starts, calling replaceCurrentItemWithPlayerItem with an AVPlayerItem constructed with a StreamAssuredAVURLAsset to start progress tracking.  If you invoke a new AVPlayer instance (after the player stalls, for example) you must use the same StreamAssuredAVURLAsset instance to properly continue player progress tracking.
 *
 *  IMPORTANT: StreamAssured players must call replaceCurrentItemWithPlayerItem with nil when playback stops.  Otherwise player progress analytics will not be triggered.
 */

@class StreamAssuredConfig;

@interface StreamAssuredAVURLAsset : AVURLAsset

/*!
 *  @abstract Creates new instance of StreamAssuredAVURLAsset
 *
 *  @discussion Creates an instance of a StreamAssuredAVURLAsset using the specified URL and StreamAssured configuration.  Retain this instance for future use if playback stalls and a new player instance is created.
 *
 *  @param URL The NSURL for playback.
 *
 *  @param config StreamAssuredConfig used to configure StreamAssured. Use the config property of the StreamAssuredManager.
 *
 *  @return A new StreamAssuredAVURLAsset object, or nil if an error occurred.
 */

-(instancetype)initWithURL:(NSURL*)URL config:(StreamAssuredConfig* _Nonnull)config;

@end

NS_ASSUME_NONNULL_END

