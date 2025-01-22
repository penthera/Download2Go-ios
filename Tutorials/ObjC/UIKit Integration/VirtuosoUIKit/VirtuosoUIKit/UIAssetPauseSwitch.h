//
//  UIAssetPauseSwitch.h
//  VirtuosoUIKit
//

#import <UIKit/UIKit.h>
@import VirtuosoClientDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

@interface UIAssetPauseSwitch : UISwitch

/*!
 *  @abstract The monitored VirtuosoAsset
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;

@end

NS_ASSUME_NONNULL_END
