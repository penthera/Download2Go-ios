//
//  UIAssetStatusLabel.h
//  VirtuosoUIKit
//

#import <UIKit/UIKit.h>
@import VirtuosoClientDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

@interface UIAssetStatusLabel : UILabel

/*!
 *  @abstract The monitored VirtuosoAsset
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;

@end

NS_ASSUME_NONNULL_END
