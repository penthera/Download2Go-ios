//
//  PlayAssureConfig.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 7/21/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/PlayAssureStatusDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/*!
*  @abstract Configures PlayAssure playback
*  @discussion Provides configuration options for PlayAssure playback.
*
*  @see PlayAssureManager
*
*/
@interface PlayAssureConfig : NSObject

/*!
* @abstract Headroom value, expressed in MB. Default value is 1024 MB (1 GB).
*
* @discussion Headroom is the amount of free space a PlayAssure session must preserve on disk, expressed in MB.
*                      For instance, if headroom is 1GB and the device has 1.2GB free disk space, PlayAssure will  begin playback
*                      of a 150MB asset, but it will NOT begin playback of a 500MB asset.
*/

@property (nonatomic, assign)NSInteger headroom;

/*!
*  @abstract Number of segments per stream we should attempt to read-ahead during cache processing for the stream. Default is 5000.
*/
@property (nonatomic, assign)NSInteger lookAheadSegmentCount;

/*!
*  @abstract The number of segments per stream that must be downloaded before PlayAssure starts caching via reading-ahead for the stream. Default is 10.
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
*  @abstract If the player receives a request for a video segment at a higher quality than one currently on disk, this flag determines whether to persist the higher quality segment to disk and remove the lower quality segment.  If not set (default), the segment request is passed through to the player with an in-memory buffer and its contents are not saved to disk. If no segment exists on disk, it will always be persisted, regardless of this setting.
*/
@property (nonatomic, assign)Boolean cacheHigherPlayerRequests;

/*!
*  @abstract Bandwidth required for the PlayAssure Manager to continue reading-ahead processing. The default value of -1 indicates the bitrate of the currently playing video stream will be used.
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
*  @abstract Delegate that will be called as the PlayAssure Manager streams content.
*/
@property (nonatomic, weak)id <PlayAssureStatusDelegate> _Nullable delegate;

/*!
*  @abstract Target bitrate PlayAssure should try and maintain.
*  @discussion A value of - 1 will let the player the choose the the value automatically. 0 will select and lowest bitrate.  Any other value PlayAssure will pick the closest available bitrate.
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
*  @param delegate Delegate that will be invoked by PlayAssure.
*
*  @return Instance
*/
-(instancetype)initWithDelegate:(id <PlayAssureStatusDelegate> _Nullable)delegate;

/*!
*  @abstract Creates an instance
*
*  @param targetBitrate Bitrate PlayAssure will try to maintain.
*
*  @param delegate Delegate that will be invoked by PlayAssure.
*
*  @return Instance
*/
-(instancetype)initWithTargetBitrate:(long long)targetBitrate andDelegate:(id <PlayAssureStatusDelegate> _Nullable)delegate;

@end

NS_ASSUME_NONNULL_END
