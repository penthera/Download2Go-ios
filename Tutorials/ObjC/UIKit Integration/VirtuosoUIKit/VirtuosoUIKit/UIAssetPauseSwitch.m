//
//  UIAssetPauseSwitch.m
//  VirtuosoUIKit
//
//  Created by Josh on 5/19/22.
//

#import "UIAssetPauseSwitch.h"

@interface UIAssetPauseSwitch() <VirtuosoDownloadEngineNotificationsDelegate>
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


@implementation UIAssetPauseSwitch

#pragma mark Init methods to auto-setup the button tapped handlers

- (id)init
{
    self = [super init];
    if( self ) {
        [self internalInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if( self ) {
        [self internalInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self ) {
        [self internalInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame primaryAction:(UIAction *)primaryAction
{
    self = [super initWithFrame:frame primaryAction:primaryAction];
    if( self ) {
        [self internalInit];
    }
    return self;
}

- (void)internalInit
{
    [self addTarget:self action:@selector(switchStateUpdated:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark Implementation

- (void)switchStateUpdated:(UISwitch*)sender
{
    if (nil == self.asset )
    {
        return;
    }
    
    // Important:
    // The following call will cause the Download engine to pause downloading this asset
    self.asset.isPaused = self.isOn;
    
    [self refreshView];
}

-(void)refreshView
{
    // Dispatch UI operations to the main queue.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (nil == self.asset) {
            [self setOn:false];
            self.enabled = false;
            return;
        }
        
        [self setOn:self.asset.isPaused];
        
        Boolean downloadInProcess = (self.asset.fractionComplete < 1) ? true : false;
        self.enabled = downloadInProcess;
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
            self.notificationManager = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self
                                                                                                    queue:[NSOperationQueue mainQueue]
                                                                                                  assetID:_asset.assetID];
        }
    }
    else
    {
        self.notificationManager = nil;
    }
    
    [self refreshView];
}

#pragma mark VirtuosoDownloadEngineNotificationsDelegate handlers

-(void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self refreshView];
}

-(void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self refreshView];
}

-(void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self refreshView];
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
    [self refreshView];
}

@end
