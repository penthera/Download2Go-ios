//
//  UIAncillaryImageView.h
//  VirtuosoUIKit
//

#import <UIKit/UIKit.h>
@import VirtuosoClientDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

@interface UIAncillaryImageView : UIImageView

/*!
 *  @abstract The monitored VirtuosoAsset
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;

/*!
 *  @abstract The ancillary tag to pull the image from.  This class will do nothing if the
 *            ancillary defined by this tag is not an image renderable by UIImageView
 */
@property (nonatomic,strong,nullable) NSString* ancillaryTag;

@end

NS_ASSUME_NONNULL_END
