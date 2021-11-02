//
//  PlayAssureStatusDelegate.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 8/17/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#ifndef VirtuosoPlayAssureStatusDelegate_h
#define VirtuosoPlayAssureStatusDelegate_h

#import <Foundation/Foundation.h>

/*!
*  @discussion PlayAssureStatusInfoVideoStream provides status information regarding  PlayAssure download and playback of Video stream segments.
*/
@interface PlayAssureStatusInfoVideoStream : NSObject

/*!
*  @abstract Number of segments total
*/
@property (nonatomic, assign)NSInteger itemCount;

/*!
*  @abstract Number of segments requested
*/
@property (nonatomic, assign)NSInteger requestedCount;

/*!
*  @abstract Number of segments downloaded
*/
@property (nonatomic, assign)NSInteger downloadCount;

/*!
*  @abstract Bitrate for the stream
*/
@property (nonatomic, assign)long long bitrate;

/*!
*  @abstract Codecs for the stream
*/
@property (nonatomic, copy)NSString* codecs;

/*!
*  @abstract resolution of the stream example: "800x400"
*/
@property (nonatomic, copy)NSString* resolution;

/*!
*  @abstract Whether the stream at this bitrate is being targeted
*/
@property (nonatomic, assign)Boolean targeted;

/*!
*  @abstract Whether the stream at this bitrate is currently being throttled
*/
@property (nonatomic, assign)Boolean currentlyThrottled;


-(instancetype)initWithBitrate:(long long)bitrate
                        codecs:(NSString*)codec
                    resolution:(NSString*)resolution
                     itemCount:(NSInteger)itemCount
                requestedCount:(NSInteger)requestedCount
                 downloadCount:(NSInteger)downloadCount
                      targeted:(Boolean)targeted
            currentlyThrottled:(Boolean)currentlyThrottled;

@end

/*!
*  @discussion AudioStreamInfo provides status information regarding  PlayAssure download and playback of Audio stream segments.
*/
@interface PlayAssureStatusInfoAudioStream : NSObject

/*!
*  @abstract Number of segments total
*/
@property (nonatomic, assign)NSInteger itemCount;

/*!
*  @abstract Number of segments downloaded
*/
@property (nonatomic, assign)NSInteger downloadCount;

/*!
*  @abstract Language for this audio stream
*/
@property (nonatomic, copy)NSString* language;

-(instancetype)initWithLanguage:(NSString*)language itemCount:(NSInteger)itemCount downloadCount:(NSInteger)downloadCount;

@end

/*!
*  @discussion PlayAssureSubtitleStreamInfo provides status information regarding  PlayAssure download and playback of subtitle stream segments.
*/
@interface PlayAssureStatusInfoSubtitleStream : NSObject

/*!
*  @abstract Number of segments total
*/
@property (nonatomic, assign)NSInteger itemCount;

/*!
*  @abstract Number of segments downloaded
*/
@property (nonatomic, assign)NSInteger downloadCount;

/*!
*  @abstract Language for this subtitle stream
*/
@property (nonatomic, copy)NSString* language;

-(instancetype)initWithLanguage:(NSString*)language itemCount:(NSInteger)itemCount downloadCount:(NSInteger)downloadCount;

@end


/*!
*  @discussion PlayAssureStatusInfo provides status information regarding  PlayAssure download and playback.
*/
@interface PlayAssureStatusInfo : NSObject

/*!
*  @abstract Array of PlayAssureStatusInfoVideoStream containing status for each video stream
*/
@property (nonatomic, strong)NSArray<PlayAssureStatusInfoVideoStream*>* videoStreams;

/*!
*  @abstract Array of PlayAssureStatusInfoAudioStream containing status for each audio stream
*/
@property (nonatomic, strong)NSArray<PlayAssureStatusInfoAudioStream*>* audioStreams;

/*!
*  @abstract Array of PlayAssureStatusInfoSubtitleStream containing status for each subtitle stream
*/
@property (nonatomic, strong)NSArray<PlayAssureStatusInfoSubtitleStream*>* subtitles;

/*!
*  @abstract Current download Mbps
*/
@property (atomic, assign)double currentMbps;

/*!
*  @abstract Indicates whether download has completed (true), or not (false).
*/
@property (atomic, assign)BOOL isComplete;


-(instancetype)initWithVideoStreams:(NSArray<PlayAssureStatusInfoVideoStream*>*)videoStreams
                       audioStreams:(NSArray<PlayAssureStatusInfoAudioStream*>*)audioStreams
                    subtitleStreams:(NSArray<PlayAssureStatusInfoSubtitleStream*>*)subtitleSteams;

@end


/*!
*  @discussion Stream Assured delegate used to notify progress state changes. Methods of this delegate wil be invoked from background threads. If you need to update UI make sure to dispatch to MainThread.
*/
@protocol PlayAssureStatusDelegate <NSObject>

@optional
/*!
*  @abstract Bitrate changed
*
*  @discussion This method is invoked to report bitrate change and progress. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param statusInfo PlayAssureStatusInfo
 *
*/
-(void)bitrateChangeReported:(PlayAssureStatusInfo*)statusInfo;

/*!
*  @abstract Bitrate download progress reported
*
*  @discussion This method is invoked to report download progress.. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param statusInfo PlayAssureStatusInfo
 *
*/
-(void)progressReported:(PlayAssureStatusInfo*)statusInfo;

/*!
*  @abstract Report network failure during playback
*
*  @discussion This callback indicates PlayAssured is now disabled and playback will be attempted via conventional streaming because the current network connection is too slow. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param error NSError indicating cause of failure. See SAM_Error
 *
*/
-(void)reportNetworkFail:(NSError*)error;

/*!
*  @abstract Report unrecoverable parsing failure during playback
*
*  @discussion Report unrecoverable parsing failure during playback. PlayAssured can not continue because the HLS Manifest was invalid. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param error NSError indicating cause of failure. See SAM_Error
 *
*/
-(void)reportParsingFail:(NSError*)error;

/*!
*  @abstract Report parsing succeeded
*
*  @discussion Report parsing succeeded. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
*/
-(void)reportParsingSuccess;


/*!
*  @abstract Report playback failure
*
*  @discussion This callback indicates PlayAssured is unable to conventionally streaming because the current network connection is too slow. Customer layer code should terminate playback in response to this callback as Streaming will not continue. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param error NSError indicating cause of failure. See SAM_Error
 *
*/
-(void)reportPlaybackFail:(NSError*)error;

/*!
*  @abstract Network reachability changed
*
*  @discussion This method is invoked to report network reachability changes. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param reachable True indicates network is reachable
 *
*/
-(void)networkReachabilityChanged:(Boolean)reachable;

/*!
*  @abstract This method is will be invoked anytime playback throttling state changes
*
*  @discussion This method is invoked anytime playback throttling state changes. This method will be invoked from a background thread. If you need to update UI make sure you dispatch to MainThread.
 *
*  @param throttled True indicates playback has been throttled
 *
*/
-(void)reportPlaybackThrottled:(Boolean)throttled;


@end

#endif /* VirtuosoPlayAssureStatusDelegate_h */
