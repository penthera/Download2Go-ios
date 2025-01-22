//
//  UIAncillaryImageView.m
//  VirtuosoUIKit
//
//  Created by Josh on 5/19/22.
//

#import "UIAncillaryImageView.h"

@interface UIAncillaryImageView() <VirtuosoDownloadEngineNotificationsDelegate>
{
}

/*!
 *  @abstract Central class for monitoring SDK-related events
 *
 *  @discussion The VirtuosoDownloadEngineNotificationManager is the central SDK class for monitoring changes under the hood.
 *              It only registers for events used by its assigned delegate and automatically cleans up during its normal lifecycle.
 */
@property (nonatomic,retain) VirtuosoDownloadEngineNotificationManager* notificationManager;

@end


@implementation UIAncillaryImageView

- (void)updateImageView
{
    // All UI operations go on the main thread.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if( self.ancillaryTag == nil )
        {
            self.image = nil;
            return;
        }
        
        // Do this bit on the background thread so we don't block UI while doing lookups
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray*  ancillaries = [self.asset findCompletedAncillariesWithTag:self.ancillaryTag];
            
            // Put the results back onto the main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!ancillaries || ancillaries.count < 1)
                {
                    self.image = nil;
                    return;
                }
                
                VirtuosoAncillaryFile* ancillary = ancillaries.firstObject;
                if( [ancillary isDownloaded] &&
                    (self.image == nil || self.image.hash != ancillary.image.hash) )
                {
                    self.image = ancillary.image;
                }
            }];
        });
    }];
}

- (void)setAsset:(VirtuosoAsset *)asset
{
    Boolean isSameAsset = [_asset.assetID isEqualToString:asset.assetID];
    _asset = asset;
    if( _asset )
    {
        if( !isSameAsset )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.image = nil;
            }];
            self.notificationManager = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self
                                                                                                    queue:[NSOperationQueue mainQueue]
                                                                                                  assetID:_asset.assetID];
        }
        
        [self updateImageView];
    }
    else
    {
        self.notificationManager = nil;
    }
}

#pragma mark VirtuosoDownloadEngineNotificationsDelegate handlers

-(void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self updateImageView];
}

-(void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self updateImageView];
}

-(void)downloadEngineDeletedAssetId:(NSString* _Nonnull)assetID
{
    if( [self.asset.assetID isEqualToString:assetID] )
    {
        self.asset = nil;
    }
}

-(void)downloadEngineAssetDidExpire:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self updateImageView];
}

@end
