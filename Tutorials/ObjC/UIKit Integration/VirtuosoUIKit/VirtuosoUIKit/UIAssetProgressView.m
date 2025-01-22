//
//  UIAssetProgressView.m
//  VirtuosoUIKit
//

#import "UIAssetProgressView.h"

@interface UIAssetProgressView()<VirtuosoDownloadEngineNotificationsDelegate>

/*!
 *  @abstract Central class for monitoring SDK-related events
 *
 *  @discussion The VirtuosoDownloadEngineNotificationManager is the central SDK class for monitoring changes under the hood.
 *              It only registers for events used by its assigned delegate and automatically cleans up during its normal lifecycle.
 */
@property (nonatomic,retain) VirtuosoDownloadEngineNotificationManager* notificationManager;

@end

@implementation UIAssetProgressView

/*!
 *  @abstract Setter for the asset property
 *
 *  @discussion When the asset for this class is set, we hookup the notification manager and set the initial progress value.
 */
- (void)setAsset:(VirtuosoAsset *)asset
{
    // Check if we've just assigned the same asset we already had.  For efficiency's sake, we don't
    // want to hook everything up again if it's just an update.
    Boolean isSameAsset = [_asset.assetID isEqualToString:asset.assetID];
    _asset = asset;
    
    if( asset == nil )
    {
        // Clear out the notification manager so we stop monitoring the asset.
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            self.progress = 0.0;
        }];
        self.notificationManager = nil;
    }
    else
    {
        // If this is a new asset, setup the notification manager.
        if( !isSameAsset )
        {
            self.notificationManager = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self
                                                                                                    queue:[NSOperationQueue mainQueue]
                                                                                                  assetID:asset.assetID];
        }

        // We may not have been given the "latest" copy of the asset.  Assets are cached in the system and if the
        // asset handed to us here wasn't provided by the SDK itself, it may have an old cached progress value.
        // Refresh to get the latest and then set the initial value of our progress.
        [asset refreshOnComplete:^{
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                self.progress = asset.fractionComplete;
            }];
        }];
    }
}

#pragma mark VirtuosoDownloadEngineNotificationManagerDelegate Methods

- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset *)asset
{
    // The assets handed to us here are directly from the SDK, which means
    // they already have the most updated data in them.
    if( [asset.uuid isEqualToString:self.asset.uuid] )
    {
        _asset = asset;
        self.progress = asset.fractionComplete;
    }
}

- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset *)asset
{
    // The assets handed to us here are directly from the SDK, which means
    // they already have the most updated data in them.
    if( [asset.uuid isEqualToString:self.asset.uuid] )
    {
        _asset = asset;
        self.progress = asset.fractionComplete;
    }
}

-(void)downloadEngineDeletedAssetId:(NSString* _Nonnull)assetID
{
    if( [self.asset.assetID isEqualToString:assetID] )
    {
        self.asset = nil;
    }
}

@end
