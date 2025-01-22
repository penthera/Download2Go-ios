//
//  UIDownloadButton.h
//  VirtuosoUIKit
//

#import <UIKit/UIKit.h>
@import VirtuosoClientDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

@protocol UIDownloadButtonDelegate<NSObject>

/*!
 *  @abstract Requests the delegate to create the desired VirtuosoAsset download.
 *
 *  @discussion When UIDownloadButton is clicked and it needs a new asset to download,
 *              it will ask the delegate to create an asset for that use.
 */
- (VirtuosoAsset*)startAssetDownload;

/*!
 *  @abstract Indicates this button's VirtuosoAsset was deleted by the user.
 *
 */
- (void)assetDeleted;

@end


/*!
 *  @abstract A basic download button
 *
 *  @discussion This class starts downloading an asset, if a download is not already assigned to it, or deletes the
 *              the asset assigned to it. It automatically handles enabling/disabling itself and updates to show a
 *              useful title based on the asset status.
 */
@interface UIDownloadButton : UIButton

/*!
 *  @abstract The managed VirtuosoAsset
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

/*!
 *  @abstract Override this method if you want to provide your own button title labels
 */
- (NSString*)titleLableForAssetStatus;

@property (nonatomic,strong) id<UIDownloadButtonDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
