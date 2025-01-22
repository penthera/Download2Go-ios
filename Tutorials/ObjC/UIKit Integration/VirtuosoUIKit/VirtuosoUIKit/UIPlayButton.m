//
//  UIPlayButton.m
//  VirtuosoUIKit
//

#import "UIPlayButton.h"

@interface UIPlayButton()<VirtuosoDownloadEngineNotificationsDelegate>
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

@implementation UIPlayButton

- (void)setEnabled:(BOOL)enabled
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [super setEnabled:enabled];
        
        UIColor* enabledColor = self.enabledColor;
        if( enabledColor == nil )
            enabledColor = [UIColor darkGrayColor];
        UIColor* disabledColor = self.disabledColor;
        if( disabledColor == nil )
            disabledColor = [UIColor lightGrayColor];

        [self setBackgroundColor:(enabled ? enabledColor : disabledColor)];
    }];
}

- (void)setAsset:(VirtuosoAsset *)asset
{
    Boolean isSameAsset = [_asset.assetID isEqualToString:asset.assetID];
    _asset = asset;
    if( _asset )
    {
        self.enabled = false;
        [VirtuosoAsset isPlayable:_asset callback:^(Boolean isPlayable) {
            self.enabled = isPlayable;
        }];
        
        if( !isSameAsset )
        {
            self.notificationManager = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self
                                                                                                    queue:[NSOperationQueue mainQueue]
                                                                                                  assetID:_asset.assetID];
        }
    }
    else
    {
        self.enabled = false;
        self.notificationManager = nil;
    }
}

#pragma mark VirtuosoDownloadEngineNotificationsDelegate handlers

- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset *)asset
{
    _asset = asset;
    [VirtuosoAsset isPlayable:_asset callback:^(Boolean isPlayable) {
        self.enabled = isPlayable;
    }];
}

-(void)downloadEngineDeletedAssetId:(NSString* _Nonnull)assetID
{
    if( [self.asset.assetID isEqualToString:assetID] )
    {
        self.asset = nil;
    }
}

@end
