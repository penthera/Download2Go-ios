//
//  StreamAssuredStatusDelegate.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 8/17/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#ifndef VirtuosoStreamAssuredStatusDelegate_h
#define VirtuosoStreamAssuredStatusDelegate_h

#import <Foundation/Foundation.h>

/*!
*  @discussion VideoStreamInfo provides status information regarding  StreamAssured download and playback of Video stream segments.
*/
@interface StreamAssuredStatusInfoVideoStream : NSObject

/*!
*  @abstract Number of segments total
*/
@property (nonatomic, assign)NSInteger itemCount;

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

-(instancetype)initWithBitrate:(long long)bitrate codecs:(NSString*)codec resolution:(NSString*)resolution itemCount:(NSInteger)itemCount downloadCount:(NSInteger)downloadCount;

@end

/*!
*  @discussion AudioStreamInfo provides status information regarding  StreamAssured download and playback of Audio stream segments.
*/
@interface StreamAssuredStatusInfoAudioStream : NSObject

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
*  @discussion StreamAssuredSubtitleStreamInfo provides status information regarding  StreamAssured download and playback of subtitle stream segments.
*/
@interface StreamAssuredStatusInfoSubtitleStream : NSObject

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
*  @discussion StreamAssuredStatusInfo provides status information regarding  StreamAssured download and playback.
*/
@interface StreamAssuredStatusInfo : NSObject

/*!
*  @abstract Array of StreamAssuredStatusInfoVideoStream containing status for each video stream
*/
@property (nonatomic, strong)NSArray<StreamAssuredStatusInfoVideoStream*>* videoStreams;

/*!
*  @abstract Array of StreamAssuredStatusInfoAudioStream containing status for each audio stream
*/
@property (nonatomic, strong)NSArray<StreamAssuredStatusInfoAudioStream*>* audioStreams;

/*!
*  @abstract Array of StreamAssuredStatusInfoSubtitleStream containing status for each subtitle stream
*/
@property (nonatomic, strong)NSArray<StreamAssuredStatusInfoSubtitleStream*>* subtitles;

/*!
*  @abstract Current download Mbps
*/
@property (atomic, assign)double currentMbps;

/*!
*  @abstract Indicates whether download has completed (true), or not (false).
*/
@property (atomic, assign)BOOL isComplete;


-(instancetype)initWithVideoStreams:(NSArray<StreamAssuredStatusInfoVideoStream*>*)videoStreams
                       audioStreams:(NSArray<StreamAssuredStatusInfoAudioStream*>*)audioStreams
                    subtitleStreams:(NSArray<StreamAssuredStatusInfoSubtitleStream*>*)subtitleSteams;

@end


/*!
*  @discussion Stream Assured delegate used to notify progress state changes
*/
@protocol StreamAssuredStatusDelegate <NSObject>

/*!
*  @abstract Bitrate changed
*
*  @discussion This method is invoked to report bitrate change and progress
 *
*  @param statusInfo StreamAssuredStatusInfo
 *
*/
-(void)bitrateChangeReported:(StreamAssuredStatusInfo*)statusInfo;

/*!
*  @abstract Bitrate download progress reported
*
*  @discussion This method is invoked to report download progress..
 *
*  @param statusInfo StreamAssuredStatusInfo
 *
*/
-(void)progressReported:(StreamAssuredStatusInfo*)statusInfo;

@end

#endif /* VirtuosoStreamAssuredStatusDelegate_h */
