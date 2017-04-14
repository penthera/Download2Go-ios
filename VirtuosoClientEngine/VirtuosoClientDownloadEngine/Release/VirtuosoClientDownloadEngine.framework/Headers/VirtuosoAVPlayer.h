/*!
 *  @header VirtuosoAVPlayer
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
 */

#import <AVFoundation/AVFoundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>

/*!
 *  @abstract A subclass of AVPlayer that is directly integrated with the Virtuoso SDK via the
 *            VirtuosoPlayer protocol.
 *
 *  @discussion The VirtuosoAVPlayer class is the lowest-level video player class available in the SDK.
 *              You can use VirtuosoAVPlayer as a drop-in replacement for AVPlayer in any custom player code
 *              you are currently using, or to build up your own player from scratch.  VirtuosoAVPlayer
 *              currently supports MP4, HLS, and MPEG-DASH assets, and is directly compatible with FairPlay
 *              and Widevine DRM platforms.  Other DRM systems, such as Adobe Primetime or Microsoft PlayReady
 *              are also supported, but require additional integration.
 *
 *  @warning You must set both the contentURL and the asset properties of this class with appropriate values
 *           before presenting the player for playback.
 */
@interface VirtuosoAVPlayer : AVPlayer<VirtuosoPlayer>

/*!
 *  @abstract The remote URL for the manifest file you wish to play
 */
@property (nonatomic, copy, nullable) NSURL *contentURL;

/*!
 *  @abstract The VirtuosoAsset object representing the video to be played
 *
 *  @warning This property must be set prior to the presentation of the player.
 */
@property (nonatomic, strong, nullable) VirtuosoAsset* asset;

/*!
 *  @abstract Prepares the player to play
 *
 *  @discussion Calling this method is optional.  If you do not call this method, it will automatically be
 *              called when you start playback.
 */
- (void)prepareToPlay;

/*!
 *  @abstract Must be called when playback permanently stops (E.G. when the view controller exits)
 *
 *  @discussion If you are not using this class directly, and are instead using the VirtuosoPlayerView or
 *              VirtuosoPlayerViewController, you do not need to call this method.
 */
- (void)cleanup;

@end
