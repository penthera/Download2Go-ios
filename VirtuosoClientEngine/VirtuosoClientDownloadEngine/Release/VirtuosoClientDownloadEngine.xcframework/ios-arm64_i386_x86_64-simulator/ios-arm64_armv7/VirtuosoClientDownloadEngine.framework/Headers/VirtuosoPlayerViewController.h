/*!
 *  @header VirtuosoPlayerViewController
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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 */

#import <UIKit/UIKit.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayerView.h>

/*!
 *  @abstract A convenience UIViewController subclass that includes a VirtuosoPlayerView and implements
 *            the VirtuosoPlayer protocol.
 *
 *  @discussion VirtuosoPlayerViewController can be used as a fully functional player or as a starting point for your
 *              own custom user interface.
 *
 *              If you use VirtuosoPlayerViewController for playback, you do not need to manually call the VirtuosoLogger's
 *              logPlaybackStart or logPlaybackStopped methods.  VirtuosoPlayerViewController will automatically record these
 *              events for you.
 */
@interface VirtuosoPlayerViewController : UIViewController<VirtuosoPlayer>

/*!
 *  @abstract The local or remote location of the video to play.
 */
@property (nonatomic, copy, nullable) NSURL *contentURL;

/*!
 *  @abstract The VirtuosoAsset object representing the video to play.
 */
@property (nonatomic, strong, nullable) VirtuosoAsset* asset;

/*!
 *  @abstract The internal player view
 */
@property (nonatomic, readwrite, nonnull) VirtuosoPlayerView* playerView;

/*!
 *  @abstract A Boolean value that indicates whether the player allows switching to external playback mode.
 */
@property (nonatomic, assign) BOOL allowsExternalPlayback;

/*!
 *  @abstract Begins or resumes video playback
 */
- (void)play;

/*!
 *  @abstract Pauses video playback
 */
- (void)pause;

@end
