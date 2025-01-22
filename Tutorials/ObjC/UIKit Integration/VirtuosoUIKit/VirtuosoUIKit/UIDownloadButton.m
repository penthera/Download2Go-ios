//
//  UIDownloadButton.m
//  VirtuosoUIKit
//

#import "UIDownloadButton.h"

@interface UIDownloadButton()<VirtuosoDownloadEngineNotificationsDelegate>
{
}

/*!
 *  @abstract Central class for monitoring SDK-related events
 *
 *  @discussion The VirtuosoDownloadEngineNotificationManager is the central SDK class for monitoring changes under the hood.
 *              It only registers for events used by its assigned delegate and automatically cleans up during its normal lifecycle.
 */
@property (nonatomic,strong) VirtuosoDownloadEngineNotificationManager* notificationManager;

// Background queue for creating the asset from
@property (nonatomic,strong) NSOperationQueue* queue;

@end

@implementation UIDownloadButton

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
    [self addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.queue = [[NSOperationQueue alloc]init];
}

#pragma mark Implementation

- (void)buttonTapped:(UIButton*)sender
{
    // None of this works if nobody is around to provide assets.
    if( self.delegate == nil || ![self.delegate respondsToSelector:@selector(startAssetDownload)] )
    {
        NSLog(@"ERROR: UIDownloadButton requires a UIDownloadButtonDelegate!");
        return;
    }
    
    if( self.asset == nil )
    {
        // Do this on a background thread so the SDK's core operations won't block UI.
        [self.queue addOperationWithBlock:^{
            self.asset = [self.delegate startAssetDownload];
        }];
    }
    else
    {
        self.enabled = false;
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Video?"
                                                                       message:@"Are you sure you want to delete this download?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.enabled = true;
        }];
        [alert addAction:cancel];
        
        UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.asset deleteAssetOnComplete:^
             {
                self.enabled = true;
                if( [self.delegate respondsToSelector:@selector(assetDeleted)] )
                {
                    [self.delegate assetDeleted];
                }
            }];
        }];
        [alert addAction:delete];
        
        // Get the parent view controller so we can display the popup
        UIViewController* vc = (UIViewController*)self.nextResponder;
        while( vc != nil )
        {
            if( [vc isKindOfClass:[UIViewController class]] )
                break;
            vc = (UIViewController*)vc.nextResponder;
        }
        
        [vc presentViewController:alert animated:YES completion:nil];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    // All UI operations go on main queue
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

- (void)updateLabel
{
    // All UI operations go on main queue
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setTitle:[self titleLableForAssetStatus] forState:UIControlStateNormal];
    }];
}

- (void)setAsset:(VirtuosoAsset *)asset
{
    Boolean isSameAsset = [_asset.assetID isEqualToString:asset.assetID];
    _asset = asset;
    [self updateLabel];
    if( _asset == nil )
    {
        self.notificationManager = nil;
    }
    else
    {
        if( !isSameAsset )
        {
            self.notificationManager = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self
                                                                                                    queue:[NSOperationQueue mainQueue]
                                                                                                  assetID:_asset.assetID];
        }
    }
}

- (NSString*)titleLableForAssetStatus
{
    if( _asset == nil )
        return @"Download";
    
    switch(_asset.status)
    {
        case kVDE_DownloadActive:
            return @"Downloading";
            break;
        case kVDE_DownloadExpired:
            return @"Download";
            break;
        case kVDE_DownloadPending:
            return @"Paused";
            break;
        case kVDE_DownloadComplete:
            return @"Delete";
            break;
        case kVDE_DownloadProcessing:
            return @"Downloading";
            break;
        case kVDE_DeleteInProcess:
            return @"Download";
            break;
        case kVDE_DownloadInitializing:
            return @"Downloading";
            break;
        case kVDE_DownloadAdExpired:
            return @"Ads Required";
            break;
        case kVDE_DownloadNotAvailable:
            return @"Not Available";
            break;
        case kVDE_DownloadConsistencyScan:
            return @"Downloading";
            break;
        case kVDE_DownloadPendingOnPermission:
            return @"Waiting";
            break;
        default:
            return [self titleForState:UIControlStateNormal];
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
    if( [_asset.assetID isEqualToString:assetID] )
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
    [_asset refreshOnComplete:^{
        [self updateLabel];
    }];
}

-(void)downloadEngineInternalQueueUpdate
{
    [_asset refreshOnComplete:^{
        [self updateLabel];
    }];
}

-(void)downloadEngineDidEncounterWarningForAsset:(VirtuosoAsset* _Nonnull)asset virtuosoError:(NSError* _Nullable)error
{
    _asset = asset;
    [self updateLabel];
}

-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset virtuosoError:(VirtuosoError *)error task:(NSURLSessionTask *)task data:(NSData *)data statusCode:(NSNumber *)statusCode
{
    _asset = asset;
    [self updateLabel];
}

-(void)permissionGrantedForAsset:(VirtuosoAsset* _Nonnull)asset  requestDate:(NSDate* _Nonnull)date
{
    _asset = asset;
    [self updateLabel];
}

-(void)permissionDeniedForAsset:(VirtuosoAsset* _Nonnull)asset requestDate:(NSDate* _Nonnull)date withReason:(kVBP_StatusCode)reason
{
    _asset = asset;
    [self updateLabel];
}

@end
