//
//  AdViewController.m
//  Example15
//
//  Created by Penthera on 07/20/20.
//  Copyright © 2020 penthera. All rights reserved.
//
// This source file contains a very basic example showing how to use the Virtuoso Download Engine.
// Pay close attention to code comments marked IMPORTANT
//

#import "AdViewController.h"
#import "BeaconsViewController.h"
#import "DemoPlayerViewController.h"

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following two values must be initialzied and the backplace URL in the "Info" File, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* publicKey = @"replace_with_your_public_key";   // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";  // <-- change this


// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// Use a valid Uplynk Preplay URL
// ---------------------------------------------------------------------------------------------------------

static NSString* preplayUrl = @"replace_with_your_preplay_url"; // <-- change this

@interface AdViewController ()

//
// MARK: Instance data
//
@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) VirtuosoAdsNotificationsManager* adsNotifications;
@property (nonatomic, strong) VirtuosoError* error;
@property (nonatomic, strong) NSMutableArray* beaconsReported;

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
    
    self.navigationItem.title = @"Verizon AVOD Tutorial";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Beacons" style:UIBarButtonItemStylePlain target:self action:@selector(beaconsClicked:)];
    
    // download engine update listener
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
    
    // Ads processing update listener
    self.adsNotifications = [[VirtuosoAdsNotificationsManager alloc]initWithDelegate:self];
    
    self.statusLabel.text = @"Starting Engine...";
    
    self.beaconsReported = [NSMutableArray new];
    
    // Backplane permissions require a unique user-id for the full range of captabilities support to work
    // Production code that needs this will need a unique customer ID.
    // For demonstation purposes only, we use the device name
    NSString* userName = UIDevice.currentDevice.name;
    
    //
    // Create the engine confuration
    VirtuosoEngineConfig* config = [[VirtuosoEngineConfig alloc]initWithUser:userName
                                                                   publicKey:publicKey
                                                                  privateKey:privateKey];
    if (!config)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Setup Required"
                                                                           message:@"Please contact support@penthera.com to setup the backplaneUrl, publicKey, and privateKey"
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToBeacons"])
    {
        BeaconsViewController* beaconsViewController = (BeaconsViewController*)segue.destinationViewController;
        
        [beaconsViewController setupBeacons:self.beaconsReported];
    }
}

//
// MARK: Click Handlers
//

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
        [self.beaconsReported removeAllObjects];
        
        NSLog(@"Resetting all beacons previously reported");
        
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
        NSString* myAssetID = @"masked-singer-asset-1";
        
        // Create asset configuration object
        VirtuosoAssetConfig* config = [[VirtuosoAssetConfig alloc]initWithURL:preplayUrl
                                                                      assetID:myAssetID
                                                                  description:@"Masked Singer"
                                                                        type:kVDE_AssetTypeHLS];
        if (!config)
        {
            NSLog(@"create config failed");
            sender.enabled = YES;
            return;
        }
        
        // Create ServerAds Provider for Verizon ads.
        config.adsProvider = [[VirtuosoVerizonAdsServerProvider alloc] initWithPreplayUrl:preplayUrl];

        [VirtuosoAsset assetWithConfig:config onReadyForDownload:nil onParseComplete:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            [self refreshView];
        });
        
    });
}

-(void)beaconsClicked:(id)sender
{
    [self performSegueWithIdentifier:@"SegueToBeacons" sender:self];
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
- (void)loadEngineData
{
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
                
                if (self.exampleAsset)
                {
                    NSLog(@"Ad status: %@", [self adsStatusToString:self.exampleAsset.refreshAdsStatus]);
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
        self.statusLabel.enabled = false;
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
        case AssetAdStatus_RefreshFailure:
            return @"Refresh failure";
        case AssetAdStatus_DownloadComplete:
            return @"Download complete";
        case AssetAdStatus_Playing:
            return @"Playing";
        default:
            return @"Unknown";
    }
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

- (void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset virtuosoError:(VirtuosoError *)error task:(NSURLSessionTask *)task data:(NSData *)data statusCode:(NSNumber *)statusCode
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
    [self refreshView];
    [self displayAdsStatus:asset error:nil];
}

-(void)adsTrackingNotificationForAsset:(VirtuosoAsset *)asset url:(NSString *)url httpResponseCode:(NSInteger)httpResponseCode userInfo:(NSDictionary *)userInfo
{
    if (userInfo)
    {
        // Record which beacons were reported.
        //
        // Note: Beacon notifications will not necessarily be received in the order they where dispatched
        //       as they are dependent on the HTTP requests.  You can verify the order of requests in the log.
        
        NSDictionary* logEventData = [userInfo objectForKey:@"logEventData"];
        
        if (logEventData)
        {
            NSMutableDictionary* beaconNotification = [[NSMutableDictionary alloc] initWithDictionary: @{@"url":url, @"httpResponseCode":@(httpResponseCode)}];
    
            [beaconNotification addEntriesFromDictionary:logEventData];
    
            [self.beaconsReported addObject:beaconNotification];
        }
    }
}

@end
