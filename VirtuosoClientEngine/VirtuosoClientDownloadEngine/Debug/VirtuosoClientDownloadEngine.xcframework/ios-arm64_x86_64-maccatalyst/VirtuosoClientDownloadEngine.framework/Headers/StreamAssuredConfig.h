//
//  StreamAssuredConfig.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 7/21/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamAssuredStatusDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
*  @abstract Configures Stream Assured playback
*  @discussion Provides configuration options for StreamAssured playback.
*
*  @see StreamAssuredManager
*
*/
@interface StreamAssuredConfig : NSObject

/*!
*  @abstract Number of segments per stream we should attempt to read-ahead during cache processing for the stream. Default is 5000.
*/
@property (nonatomic, assign)NSInteger lookAheadSegmentCount;

/*!
*  @abstract The number of segments per stream that must be downloaded before SAM starts caching via reading-ahead for the stream. Default is 10.
*/
@property (nonatomic, assign)NSInteger minimumStartingIndex;

/*!
*  @abstract Maximum total number of segments for all video streams that will be downloaded to the cache. Default is INT_MAX.  Any value <= 0 will disable the lookahead cache.
*/
@property (nonatomic, assign)NSInteger lookAheadMaximumVideoSegmentDownloadCount;

/*!
*  @abstract When evaluating video segments for the read-ahead cache, the number of video quality levels below the requested level to consider before downloading. Default is 0.
*/
@property (nonatomic, assign)NSInteger lookAheadBackupVideoLevel;

/*!
*  @abstract When evaluating video segments requested by the player, the number of video quality levels below the requested level to consider before downloading. Default is 0.
*/
@property (nonatomic, assign)NSInteger playerBackupVideoLevel;

/*!
*  @abstract Reading-ahead starts by downloading segments from the current player position to the end of a video.  When set, this flag will also download segments from the beginning of the video to the current player postion.  Default is NO.
*/
@property (nonatomic, assign)Boolean lookAheadBehindPlayer;

/*!
*  @abstract Bandwidth required for SAM to continue reading-ahead whenever playback is throttled.  Generally values less than a bandiwdth of 10.0 Mbps will not have any affect as player requests will limit any reading-ahead. Default is 10.0 Mbps.
*/
@property (nonatomic, assign)double requiredCacheMbps;

/*!
*  @abstract Number of active web requests being serviced by the WebServer that can be active before we force a suspend on reading-ahead processing operation queues
*/
@property (nonatomic, assign)NSInteger minimumActiveRequestThreshold;

/*!
*  @abstract Number of seconds after which the WebServer is determined to be idle.
*/
@property (nonatomic, assign)NSTimeInterval minimumWebServerIdleThreshold;

/*!
*  @abstract Delegate that will be called as the SAM streams content.
*/
@property (nonatomic, weak)id <StreamAssuredStatusDelegate> _Nullable delegate;

/*!
*  @abstract Target bitrate SAM should try and maintain.
*  @discussion A value of - 1 will let the player the choose the the value automatically. 0 will select and lowest bitrate.  Any other value SAM will pick the closest available bitrate.
*/
@property (nonatomic,readonly)long long targetBitrate;

/*!
*  @abstract Current description of processing mode.  Values include Automatic, Progressive, and Backstop.
*/
@property (nonatomic, copy, readonly)NSString* mode;

/*!
*  @abstract Creates an instance
*
*  @return Instance
*/
-(instancetype)init;

/*!
*  @abstract Creates an instance
*
*  @param delegate Delegate that will be invoked by the SAM.
*
*  @return Instance
*/
-(instancetype)initWithDelegate:(id <StreamAssuredStatusDelegate> _Nullable)delegate;

/*!
*  @abstract Creates an instance
*
*  @param targetBitrate Bitrate SAM will try to maintain.
*
*  @param delegate Delegate that will be invoked by the SAM.
*
*  @return Instance
*/
-(instancetype)initWithTargetBitrate:(long long)targetBitrate andDelegate:(id <StreamAssuredStatusDelegate> _Nullable)delegate;

@end

NS_ASSUME_NONNULL_END
