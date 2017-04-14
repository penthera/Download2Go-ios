/*!
 *  @header VirtuosoPlayer
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

#ifndef VPLAYER
#define VPLAYER

@class VirtuosoAsset;

#import <Foundation/Foundation.h>

/*!
 *  @abstract Defines the minimum API required for basic playback of segmented (HLS, HSS, DASH, etc.) video
 *
 *  @discussion When calling the playUsingPlayer: method of an VirtuosoAsset, you must provide a player
 *              object that follows this protocol.  Virtuoso will automatically handle all playback-related setup,
 *              e.g. create/configure a VirtuosoClientHTTPServer instance. It's your responsibility to configure 
 *              the player and present it in the view hierarchy.
 */
@protocol VirtuosoPlayer <NSObject>

@required

/*!
 *  @abstract The remote URL for the manifest file to play
 */
@property (nonatomic, copy, nullable) NSURL *contentURL;

/*!
 *  @abstract The VirtuosoAsset object representing the video to be played
 */
@property (nonatomic, strong, nullable) VirtuosoAsset* asset;

@end

#endif
