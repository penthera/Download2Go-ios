/*!
 *  @header VirtuosoPlayerView
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
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>

@class VirtuosoPlayerView;

/*!
 *  @discussion If you are using VirtuosoPlayerView directly, then you will need to configure
 *              a delegate to handle playback events.  If you are using VirtuosoPlayerViewController,
 *              then the delegate calls are handled internally.
 */
@protocol VirtuosoPlayerViewDelegate <NSObject>
@optional

/*!
 *  @abstract Called when the player has reached the end of the video.
 *
 *  @param view The VirtuosoPlayerView object that finished playing
 */
-(void)playerFinishedPlayback:(nonnull VirtuosoPlayerView*)view;

/*!
 *  @abstract Called when the user taps the done button.
 *
 *  @param view The VirtuosoPlayerView object requesting to finish
 */
-(void)playerDoneButtonClicked:(nonnull VirtuosoPlayerView*)view;

@end


/*!
 *  @abstract A convenience UIView subclass that includes a VirtuosoAVPlayer, a basic user interface, and implements
 *            the VirtuosoPlayer protocol.
 *
 *  @discussion VirtuosoPlayerView can be used as a fully functional player view or as a starting point for your
 *              own custom user interface.
 *
 *              If you use VirtuosoPlayerView for playback, you do not need to manually call the VirtuosoLogger's
 *              logPlaybackStart or logPlaybackStopped methods.  VirtuosoPlayerView will automatically record these
 *              events for you.
 */
@interface VirtuosoPlayerView : UIView<VirtuosoPlayer>

/**---------------------------------------------------------------------------------------
 * @name Playback
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Begins or resumes video playback
 */
-(void)play;

/*!
 *  @abstract Pauses video playback
 */
-(void)pause;

/*!
 *  @abstract The local or remote location of the video to play.
 */
@property (nonatomic, copy, nullable) NSURL *contentURL;

/*!
 *  @abstract The VirtuosoAsset object representing the video to play.
 */
@property (nonatomic, strong, nullable) VirtuosoAsset* asset;

/*!
 *  @abstract A Boolean value that indicates whether the player allows switching to external playback mode.
 */
@property (nonatomic, assign) BOOL allowsExternalPlayback;


/**---------------------------------------------------------------------------------------
 * @name State Management
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Must be called when playback permanently stops (E.G. when the view controller exits)
 *
 *  @discussion If you are not using this class directly, and are instead using
 *              VirtuosoPlayerViewController, you do not need to call this method.
 */
- (void)cleanup;

/*!
 *  @abstract Notifies the container that the size of its view is about to change.
 *
 *  @discussion UIKit calls this method on a view controller before changing the size of a presented view controller’s view.
 *               You should override this method in your own view controller and use it to perform additional tasks related to
 *               the size change. At a minimum, you must call this method to allow VirtuosoPlayerView to properly resize its user
 *               interface.
 *
 *               If you override this method in your custom view controllers, always call super at some point in your implementation
 *               so that UIKit can forward the size change message appropriately.
 *
 *  @param size The new size for the container's view
 *
 *  @param coordinator The transition coordinator object managing the size change. You can use this object to animate your changes
 *                     or get information about the transition that is in progress.
 */
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0);;


/*!
 *  @abstract An object that implements the VirtuosoPlayerViewDelegate protocol.
 */
@property (nonatomic, weak, nullable) id <VirtuosoPlayerViewDelegate> delegate;

/*!
 *  @abstract You may use access to the AVPlayer object to perform custom player actions, such as modifying the
 *            playback rate or seeking to a particular time in the playback stream.
 */
@property (nonatomic, readonly, nullable) AVPlayer *player;

/*!
 *  @abstract Whether the player is currently playing
 */
@property (nonatomic, readonly) BOOL isPlaying;

/*!
 *  @abstract Convenience method to set/return the current player progress as a value from 0.0 - 1.0 inclusive.
 */
@property (nonatomic, assign) double currentProgress;

/*!
 *  @abstract Convenience method to return the current playback position, in seconds.
 */
@property (nonatomic, readonly) NSTimeInterval currentPlaybackPosition;

/*!
 *  @abstract Convenience method to return the total duration of the loaded video, in seconds.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

/*!
 *  @abstract Convenience method to return the playback time remaining, in seconds.
 */
@property (nonatomic, readonly) NSTimeInterval playbackTimeRemaining;

/**---------------------------------------------------------------------------------------
 * @name User Interface
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Whether the built-in player user interface is displayed.
 */
@property (nonatomic, assign) BOOL playerControlsHidden;

/*!
 *  @abstract Button shown in the center of the screen, allowing the user to pause/resume playback
 */
@property (nonatomic, readonly, nonnull) UIButton *playPauseButton;

/*!
 *  @abstract Slider shown in the top HUD overlay, allowing the user to see playback progress and scrub
 *            to a particular location in the video.
 */
@property (nonatomic, readonly, nonnull) UISlider *progressBar;

/*!
 *  @abstract Label shown to the left of the progress bar to indicate the current playback position
 */
@property (nonatomic, readonly, nonnull) UILabel *playBackTime;

/*!
 *  @abstract Label shown to the right of the progress bar to indicate how much time is left for playback
 */
@property (nonatomic, readonly, nonnull) UILabel *playBackTotalTime;

/*!
 *  @abstract Button shown in the top HUD overlay, allowing the user to select audio language options
 */
@property (nonatomic, readonly, nonnull) UIButton *languageSelectionButton;

/*!
 *  @abstract Button shown in the top HUD overlay, allowing the user to select subtitle language options
 */
@property (nonatomic, readonly, nonnull) UIButton *ccSelectionButton;

/**---------------------------------------------------------------------------------------
 * @name Alternative Language Options
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Convenience interface used to retrieve the available audio and subtitle track options.
 *
 *  @discussion This method returns the available media selection options (languages) for either audio or subtitle tracks.
 *              Only AVMediaCharacteristicAudible and AVMediaCharacteristicLegible are valid inputs.  Specifying any other
 *              media characteristic will return null.
 *
 *  @param characteristic Either AVMediaCharacteristicAudible or AVMediaCharacteristicLegible
 *
 *  @return An NSArray containing the available media selection options for the given characteristic
 */
- (nullable NSArray<AVMediaSelectionOption*>*)mediaOptionsForMediaCharacteristic:(nonnull AVMediaCharacteristic)characteristic;

/*!
 *  @abstract Convenience interface used to set a particular audio/subtitle language option in the player.
 *
 *  @discussion Only AVMediaCharacteristicAudible and AVMediaCharacteristicLegible are valid inputs.  Specifying any other
 *              media characteristic will have no effect.
 *
 *  @param characteristic Either AVMediaCharacteristicAudible or AVMediaCharacteristicLegible
 *
 *  @param option One of the options returned from mediaOptionsForMediaCharacteristic:
 */
- (void)setMediaSelectionOption:(nullable AVMediaSelectionOption*)option forMediaCharacteristic:(nonnull AVMediaCharacteristic)characteristic;

@end
