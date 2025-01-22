//
//  UIAssetProgressView.h
//  VirtuosoUIKit
//

#import <UIKit/UIKit.h>
@import VirtuosoClientDownloadEngine;

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract A basic download progress view
 *
 *  @discussion This class is a simple addition to UIProgressView that tracks the download progress of an asset.
 *              Once the asset property is set, the class handles everything else.  Subclasses can be used to
 *              add the proper UI/UX look-and-feel.
 */
@interface UIAssetProgressView : UIProgressView

/*!
 *  @abstract The VirtuosoAsset this UIProgressView will track
 *
 *  @discussion Generally, this property should be set during viewDidLoad (if the appropriate asset exists when
 *              the view loads) or when the asset is created at a later time.  Once set, this class automatically
 *              monitors the asset's download progress and reflects that progress as proper values in the
 *              progress property.
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;

@end

NS_ASSUME_NONNULL_END
