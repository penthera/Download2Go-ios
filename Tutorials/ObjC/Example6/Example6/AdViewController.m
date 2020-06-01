//
//  ViewController.m
//  Download2GoHelloWorld-Objc
//
//  Created by Penthera on 11/27/18.
//  Copyright © 2018 penthera. All rights reserved.
//
// This source file contains a very basic example showing how to use the Virtuoso Download Engine.
// Pay close attention to code comments marked IMPORTANT
//

#import "AdViewController.h"
#import "DemoPlayerViewController.h"

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialzied, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* backplaneUrl = @"replace_with_your_backplane_url";
static NSString* publicKey = @"replace_with_your_public_key";
static NSString* privateKey = @"replace_with_your_private_key";

// Note:
// The following Ads URL is rate-limited, you may see Ads download failures
static NSString* adsUrl = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=";

@interface AdViewController ()

//
// MARK: Instance data
//
@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) VirtuosoAdsNotificationsManager* adsNotifications;
@property (nonatomic, strong) NSError* error;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *statusProgressBar;

@end

@implementation AdViewController

//
// MARK: Lifecycle methods
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // download engine update listener
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
    
    // Ads processing update listener
    self.adsNotifications = [[VirtuosoAdsNotificationsManager alloc]initWithDelegate:self];
    
    self.statusLabel.text = @"Starting Engine...";
    
    //
    // Enable the Engine
    VirtuosoDownloadEngine.instance.enabled = TRUE;
    
    // Backplane permissions require a unique user-id for the full range of captabilities support to work
    // Production code that needs this will need a unique customer ID.
    // For demonstation purposes only, we use the device name
    NSString* userName = UIDevice.currentDevice.name;
    
    //
    // Create the engine confuration
    VirtuosoEngineConfig* config = [[VirtuosoEngineConfig alloc]initWithUser:userName
                                                                backplaneUrl:backplaneUrl
                                                                   publicKey:publicKey
                                                                  privateKey:privateKey];
    if (!config)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Setup Required"
                                                                           message:@"Please contact support@penthera.com to setup the backplaneUrl, pulicKey, and privateKey"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                exit(0);
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:TRUE completion:nil];

        });
        return;
    }

    //
    // Start the Engine
    // This method will execute async, the callback will happen on the main-thread.
    [VirtuosoDownloadEngine.instance startup:config startupCallback:^(kVDE_EngineStartupCode status) {
        if (status == kVDE_EngineStartupSuccess) {
            NSLog(@"Startup succeeded.");
        } else {
            NSLog(@"Startup encountered error.");
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// MARK: Click Handlers

- (IBAction)deleteClicked:(UIButton *)sender
{
    sender.enabled = FALSE;  // block reentry
    if (self.exampleAsset)
    {
        self.statusLabel.text = [NSString stringWithFormat:@"Deleting Asset:%@", self.exampleAsset];
        [self.exampleAsset deleteAssetOnComplete:^
         {
             self.statusLabel.text = @"Deleted.";
             [self loadEngineData];
         }];
    }
}

- (IBAction)playBtnClicked:(UIButton *)sender
{
    if (self.exampleAsset)
    {
        [self playAsset:self.exampleAsset];
    }
}

- (IBAction)downloadBtnClicked:(UIButton *)sender
{
    sender.enabled = NO; // block reentrancy while we create the asset
    
    if ( kVDE_ReachableViaWiFi != [VirtuosoDownloadEngine.instance currentNetworkStatus] ) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Unreachable" message:@"Demo requires WiFi" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            sender.enabled = YES;
        }]];
         [self presentViewController:alert animated:TRUE completion:nil];
         return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Important: AssetID should be unique across your video catalog
        NSString* myAssetID = @"tears-of-steel-asset-1";
        
        // Create asset configuration object
        VirtuosoAssetConfig* config = [[VirtuosoAssetConfig alloc]initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/tears/index.m3u8"
                                                                      assetID:myAssetID
                                                                  description:@"Tears of Steel" type:kVDE_AssetTypeHLS];
        if (!config)
        {
            NSLog(@"create config failed");
            sender.enabled = YES;
            return;
        }
        
        // Create ClientAds Provider for Google ads.
        config.adsProvider = [[VirtuosoGoogleAdsClientProvider alloc] initWithRefreshUrl:adsUrl];

        [VirtuosoAsset assetWithConfig:config];
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            [self refreshView];
        });
        
    });
}

//
// MARK: Internal implementation
//

- (void)displayAsset:(VirtuosoAsset*)asset
{
    double fractionComplete = asset.fractionComplete;
    kVDE_DownloadStatusType status = asset.status;
    if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
    {
        NSString* statusMessage = (asset.status == kVDE_DownloadInitializing) ? NSLocalizedString(@"Initializing: ", @"") : @"";
        NSString* errorsNessage = (asset.downloadRetryCount > 0)? [NSString stringWithFormat:@" (Errors: %i)",asset.downloadRetryCount] : @"";
        self.statusLabel.text = [NSString stringWithFormat:@"%@%0.02f%% (%qi MB)%@", statusMessage, fractionComplete*100.0, asset.currentSize/1024/1024, errorsNessage];
        self.statusProgressBar.progress = fractionComplete;
        [self.downloadBtn setEnabled:NO];
    }
    else if( status == kVDE_DownloadComplete )
    {
        self.statusLabel.text = [NSString stringWithFormat:@"%0.02f%% (%qi MB)",fractionComplete*100.0,asset.currentSize/1024/1024];
        self.statusProgressBar.progress = fractionComplete;
    }
}

- (void)playAsset:(VirtuosoAsset*)asset {
    [VirtuosoAsset isPlayable:asset callback:^(Boolean playable) {
        if( playable )
        {
            if( asset.type != kVDE_AssetTypeHSS )
            {
                UIViewController* player = [DemoPlayerViewController new];
                self.exampleAsset = asset;
                
                [asset playUsingPlaybackType:kVDE_AssetPlaybackTypeLocal
                                   andPlayer:(id<VirtuosoPlayer>)player
                                   onSuccess:^ {
                                       // Present the player
                                       [self presentViewController:player animated:YES completion:nil];
                                   }
                                      onFail:^ {
                                          self.exampleAsset = nil;
                                          self.error = nil;
                                          NSLog(@"Can't play video!");
                                      }];
            }
        }
    }];
}

// ------------------------------------------------------------------------------------------------------------
// IMPORTANT:
// Loads data from the Download Engine.
// ------------------------------------------------------------------------------------------------------------
- (void)loadEngineData {

    self.error = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //
        // Invoked on background thread to prevent blocking UI updates
        //
        if( [[VirtuosoDownloadEngine instance]started] ) {
            NSArray* downloadComplete = [VirtuosoAsset completedAssetsWithAvailabilityFilter:NO];
            NSArray* downloadPending = [VirtuosoAsset pendingAssetsWithAvailabilityFilter:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                // Switch back to MainThread to update UI
                //
                if ( nil != downloadComplete && downloadComplete.count > 0 )
                {
                    self.exampleAsset = (VirtuosoAsset *)downloadComplete.firstObject;
                }
                else if (nil != downloadPending && downloadPending.count > 0) {
                    self.exampleAsset = (VirtuosoAsset *)downloadPending.firstObject;
                }
                else
                {
                    self.exampleAsset = nil;
                }
                [self refreshView];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self loadEngineData];
            });

        }

    });
}


-(void)refreshView
{
    if (nil == self.exampleAsset) {
        
        self.statusLabel.text = @"Ready to download";
        self.statusProgressBar.progress = 0;
        
        [self setEnabledAppearance:self.downloadBtn enabled:YES];
        [self setEnabledAppearance:self.playBtn enabled:NO];
        [self setEnabledAppearance:self.deleteBtn enabled:(nil != self.error ? TRUE : FALSE)];
        
        return;
    }
    
    Boolean downloadInProcess = (self.exampleAsset.fractionComplete < 1) ? true : false;
    self.statusLabel.text = (downloadInProcess ? @"Downloading..." : @"Ready to play");
    
    [self setEnabledAppearance:self.deleteBtn enabled:YES];
    [self setEnabledAppearance:self.downloadBtn enabled:NO];
    self.statusProgressBar.progress = self.exampleAsset.fractionComplete;

    [VirtuosoAsset isPlayable:self.exampleAsset callback:^(Boolean playable) {
        [self setEnabledAppearance:self.playBtn enabled:playable];
    }];
}

-(void)setEnabledAppearance:(UIControl*)control enabled:(Boolean)enabled
{
    [control setEnabled:enabled];
    [control setBackgroundColor:(enabled ? [UIColor blackColor] : [UIColor lightGrayColor])];
}

-(void)displayAdsStatus:(VirtuosoAsset*)asset error:(NSError*)error{
    if (error) {
        self.statusLabel.text = [NSString stringWithFormat:@"Ad status: %@ error: %@",
                                 [self adsStatusToString:asset.refreshAdsStatus],
                                 error.localizedDescription];
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"Ad status: %@", [self adsStatusToString:asset.refreshAdsStatus]];
    }
}

-(NSString*)adsStatusToString:(AssetAdStatus)status {
    switch(status) {
        case AssetAdStatus_Uninitialized:
            return @"Uninitialized";
        case AssetAdStatus_RefreshComplete:
            return @"Refresh complete";
        case AssetAdStatus_QueuedForRefresh:
            return @"Queued for refresh";
        case AssetAdStatus_RefreshInProcess:
            return @"Refresh in-process";
        case AssetAdStatus_RefreshCompleteWithErrors:
            return @"Refresh complete with errors";
            
            // Typical reason for this is Google Ads sample is rate limited
        case AssetAdStatus_RefreshFailure:
            return @"Refresh failure";
            
        default:
            return @"unknown";
    }
}

-(void)displayAdsTracking:(VirtuosoAsset*)asset url:(NSString*)url {
    self.statusLabel.text = [NSString stringWithFormat:@"Ad tracking url:%@", url];
}


//
// MARK: VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY
//

// ------------------------------------------------------------------------------------------------------------
//  Called whenever the Engine starts downloading a VirtuosoAsset object.
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self displayAsset:asset];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports progress for a VirtuosoAsset object
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset * _Nonnull)asset
{
    [VirtuosoAsset isPlayable:asset callback:^(Boolean playable) {
        if (playable)
        {
            self.exampleAsset = asset;
            [self refreshView];
        }
        [self displayAsset:asset];
    }];
}

// ------------------------------------------------------------------------------------------------------------
// Called when an asset is being processed after background transfer
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self displayAsset:asset];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports a VirtuosoAsset as complete
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self displayAsset:asset];
    [self refreshView];
    [self loadEngineData];
}

- (void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset error:(NSError *)error task:(NSURLSessionTask *)task data:(NSData *)data statusCode:(NSNumber *)statusCode
{
    self.error = error;
    [self displayAsset:asset];
    [self refreshView];
    [self loadEngineData];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever an asset is added to the Engine
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineInternalQueueUpdate {
    [self loadEngineData];
}

// ------------------------------------------------------------------------------------------------------------
// Called when Engine start is complete
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineStartupComplete:(Boolean)succeeded {
    [self loadEngineData];
}

//
// MARK: VirtuosoAdsManagerNotificationDelegate - required methods ONLY
//

- (void)adsRefreshFailure:(VirtuosoAsset * _Nonnull)asset error:(NSError * _Nullable)error {
    [self displayAdsStatus:asset error:error];
}

- (void)adsRefreshStatusUpdate:(VirtuosoAsset * _Nonnull)asset {
    [self displayAdsStatus:asset error:nil];
}

-(void)adsTrackingNotificationForAsset:(VirtuosoAsset *)asset url:(NSString *)url userInfo:(NSDictionary *)userInfo
{
    [self displayAdsTracking:asset url:url];
}


@end
