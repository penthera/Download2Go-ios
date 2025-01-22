//
//  UIPlayButton.h
//  VirtuosoUIKit
//

#import <UIKit/UIKit.h>
@import VirtuosoClientDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract A basic play button
 *
 *  @discussion This class monitors an assigned asset and enables itself when the
 *              asset is playable.  The actual process of playback is left to the enclosing
 *              application, as the actual player class and other UI details will likely
 *              need custom setup.
 */
@interface UIPlayButton : UIButton

/*!
 *  @abstract The monitored VirtuosoAsset
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;

/*!
 *  @abstract The background color to display when the button is enabled
 */
@property (nonatomic,strong) UIColor* enabledColor;

/*!
 *  @abstract The background color to display when the button is disabled
 */
@property (nonatomic,strong) UIColor* disabledColor;

@end

NS_ASSUME_NONNULL_END
