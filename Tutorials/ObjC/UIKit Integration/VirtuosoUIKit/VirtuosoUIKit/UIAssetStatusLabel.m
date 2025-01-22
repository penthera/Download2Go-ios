//
//  UIAssetStatusLabel.m
//  VirtuosoUIKit
//

#import "UIAssetStatusLabel.h"

@interface UIAssetStatusLabel()<VirtuosoDownloadEngineNotificationsDelegate>
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

@implementation UIAssetStatusLabel

- (void)updateLabel
{
    // All UI operations go on the main queue.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if( self.asset )
        {
            // Get asset properties on background thread to insure we get fresh values
            __block double fractionComplete;
            __block kVDE_DownloadStatusType status;
            __block int downloadRetryCount;
            __block long long currentSize;
            
            NSOperationQueue* bgQueue = [[NSOperationQueue alloc]init];
            [bgQueue addOperationWithBlock:^{
                fractionComplete = self.asset.fractionComplete;
                status = self.asset.status;
                downloadRetryCount = self.asset.downloadRetryCount;
                currentSize = self.asset.currentSize;
                
                [NSOperationQueue.mainQueue addOperationWithBlock:^{
                    if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
                    {
                        NSString* statusMessage = (status == kVDE_DownloadInitializing) ? NSLocalizedString(@"Initializing: ", @"") : @"";
                        NSString* errorsNessage = (downloadRetryCount > 0)? [NSString stringWithFormat:@" (Errors: %i)",downloadRetryCount] : @"";
                        self.text = [NSString stringWithFormat:@"%@%0.02f%% (%qi MB)%@", statusMessage, fractionComplete*100.0, currentSize/1024/1024, errorsNessage];
                    }
                    else if( status == kVDE_DownloadComplete )
                    {
                        self.text = [NSString stringWithFormat:@"Downloaded (%qi MB)",currentSize/1024/1024];
                    }
                }];
            }];
        }
        else
        {
            self.text = @"Ready To Download";
        }
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
        
        [self updateLabel];
    }
    else
    {
        self.notificationManager = nil;
    }
}

#pragma mark VirtuosoDownloadEngineNotificationsDelegate handlers

-(void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self updateLabel];
}

-(void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self updateLabel];
}

-(void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset* _Nonnull)asset
{
    _asset = asset;
    [self updateLabel];
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
    [self updateLabel];
}

-(void)downloadEngineStatusChange:(kVDE_DownloadEngineStatus)status statusInfo:(VirtuosoEngineStatusInfo* _Nonnull)statusInfo
{
    if( status == kVDE_Blocked )
    {
        if( ![statusInfo isNetworkOK] )
            self.text = @"Blocked On Network";
        
        else if( ![statusInfo isDiskOK] )
            self.text = @"Disk Full";
        
        else if( ![statusInfo isQueueOK] )
            self.text = @"Too Many Assets";
        
        else if( ![statusInfo isMemoryOK] )
            self.text = @"Waiting On Memory";
        
        else if( ![statusInfo isAccountOK] )
            self.text = @"No Permission";
        
        else if( ![statusInfo authenticationOK] )
            self.text = @"Not Authorized";
    }
    else if( status == kVDE_Errors )
    {
        self.text = @"Too Many Errors";
    }
    else if( status == kVDE_AuthenticationFailure )
    {
        self.text = @"Not Authorized";
    }
}

-(void)downloadEngineInternalQueueUpdate
{
    [self updateLabel];
}

-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset* _Nonnull)asset
                                 virtuosoError:(VirtuosoError* _Nullable)error
                                          task:(NSURLSessionTask* _Nullable)task
                                          data:(NSData* _Nullable)data
                                    statusCode:(NSNumber* _Nullable)statusCode
{
    _asset = asset;
    [self updateLabel];
}

@end
