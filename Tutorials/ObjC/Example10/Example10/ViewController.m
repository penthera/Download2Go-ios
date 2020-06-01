//
//  ViewController.m
//  Example10
//
//  Created by Penthera on 1/31/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "ViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "DemoPlayerViewController.h"

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialzied, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* backplaneUrl = @"replace_with_your_backplane_url";
static NSString* publicKey = @"replace_with_your_public_key";
static NSString* privateKey = @"replace_with_your_private_key";

@interface ViewController () <VirtuosoDownloadEngineNotificationsDelegate>
//
// MARK: Instance data
//
@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) NSError* error;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *fastPlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *statusProgressBar;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Important:
    // The download engine runs async in background. We can receive status updates by implementing
    // the VirtuosoDownloadEngineNotificationsDelegate methods. As processing progresses, our delegate
    // will receive callbacks allowing us to refresh the UI.
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
    
    self.statusLabel.text = @"Starting Engine...";

    //
    // Enable the Engine
    VirtuosoDownloadEngine.instance.enabled = TRUE;
    
    // Backplane permissions require a unique user-id for the full range of captabilities support to work
    // Production code that needs this will need a unique customer ID.
    // For demonstation purposes only, we use the device name
    NSString* userName = UIDevice.currentDevice.name;
    
    //
    // Create the engine configuration
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
             [self setEnabledAppearance:self.fastPlayBtn enabled:YES];
         }];
    }
}

- (IBAction)fastPlayBtnClicked:(UIButton *)sender
{
    // block reentrancy while we create the asset
 
    [self setEnabledAppearance:self.fastPlayBtn enabled:NO];
    
    // This button does double duty
    
    if (self.exampleAsset && self.exampleAsset.fastPlayReady) {
        // Asset has already been queued for FastPlay and is ready for playback
        
        [self fastPlayAsset:self.exampleAsset];
    }
    else {
        // Queue asset for FastPlay.  When enough of the asset has been processed playblack
        // will automatically begin
        
        if ( kVDE_ReachableViaWiFi != [VirtuosoDownloadEngine.instance currentNetworkStatus] ) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Unreachable" message:@"Demo requires WiFi" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:TRUE completion:nil];
            return;
        }
        
        // Important:
        // AssetID should be unique across your video catalog
        NSString* myAssetID = @"tears-of-steel-asset-1";
        
        // Important:
        // Create asset configuration object
        VirtuosoAssetConfig* config = [[VirtuosoAssetConfig alloc]initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/tears/index.m3u8"
                                                                      assetID:myAssetID
                                                                  description:@"Tears of Steel"
                                                                         type:kVDE_AssetTypeHLS];
        
        if (!config)
        {
            NSLog(@"create config failed");
            [self setEnabledAppearance:self.fastPlayBtn enabled:YES];
            return;
        }
        
        // FastPlay specific configuration flags
        
        // Skip automatic download
        
        config.autoAddToQueue = false;
        
        // Enable FastPlay
        
        config.fastPlayEnabled = true;
            
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            // Important:
            // Creates the Asset and automatically begins parsing and downloading
            // Status messages are provided via VirtuosoDownloadEngineNotificationsDelegate methods.
            
            [VirtuosoAsset assetWithConfig:config];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshView];
                self.statusLabel.text = @"Preparing for FastPlay...";
            });
            
        });
    }
}

//
// MARK: Internal implementation
//

- (void)displayAsset:(VirtuosoAsset*)asset
{
    double fractionComplete = asset.fractionComplete;
    kVDE_DownloadStatusType status = asset.status;
    
    if (asset.fastPlayReady)
    {
        self.statusLabel.text = [NSString stringWithFormat:@"FastPlay ready at %0.02f%% complete (%qi MB)",fractionComplete*100.0,asset.currentSize/1024/1024];
        self.statusProgressBar.progress = fractionComplete;
    }
    else
    {
        if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
        {
            NSString* statusMessage = (asset.status == kVDE_DownloadInitializing) ? NSLocalizedString(@"Initializing: ", @"") : @"";
            NSString* errorMessage = (asset.downloadRetryCount > 0)? [NSString stringWithFormat:@" (Errors: %i)",asset.downloadRetryCount] : @"";
            
            self.statusLabel.text = [NSString stringWithFormat:@"%@%0.02f%% (%qi MB)%@", statusMessage, fractionComplete*100.0, asset.currentSize/1024/1024, errorMessage];
            self.statusProgressBar.progress = fractionComplete;
            [self.fastPlayBtn setEnabled:NO];
        }
        else if( status == kVDE_DownloadComplete )
        {
            self.statusLabel.text = [NSString stringWithFormat:@"%0.02f%% (%qi MB)",fractionComplete*100.0,asset.currentSize/1024/1024];
            self.statusProgressBar.progress = fractionComplete;
        }
    }
}

-(void)playAsset:(VirtuosoAsset*)asset
{
    [self playAsset:asset playbackType:kVDE_AssetPlaybackTypeLocal];
}

-(void)fastPlayAsset:(VirtuosoAsset*)asset
{
    [self playAsset:asset playbackType:kVDE_AssetPlaybackTypeFastPlay];
}

-(void)playAsset:(VirtuosoAsset*)asset playbackType:(kVDE_AssetPlaybackType)playbackType
{
    [self setEnabledAppearance:self.fastPlayBtn enabled:YES];
    
    [VirtuosoAsset isPlayable:asset callback:^(Boolean playable) {
        if( playable )
        {
            UIViewController* player = [DemoPlayerViewController new];
            self.exampleAsset = asset;
            
            [asset playUsingPlaybackType:playbackType
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
    }];

}

// ------------------------------------------------------------------------------------------------------------
// IMPORTANT:
// Loads data from the Download Engine.
// ------------------------------------------------------------------------------------------------------------
- (void)loadEngineData {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //
        // Important:
        // Invoked on background thread to prevent blocking UI updates
        //
        if( [[VirtuosoDownloadEngine instance]started] ) {
            NSArray* downloadComplete = [VirtuosoAsset completedAssetsWithAvailabilityFilter:NO];
            NSArray* downloadPending = [VirtuosoAsset pendingAssetsWithAvailabilityFilter:NO];
            
            //
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                self.error = nil;
                self.exampleAsset = nil;
                
                if ( nil != downloadComplete && downloadComplete.count > 0 )
                {
                    self.exampleAsset = (VirtuosoAsset *)downloadComplete.firstObject;
                }
                else if (nil != downloadPending && downloadPending.count > 0) {
                    self.exampleAsset = (VirtuosoAsset *)downloadPending.firstObject;
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
        
        self.statusLabel.text = @"Ready to start FastPlay";
        self.statusProgressBar.progress = 0;
        
        [self setEnabledAppearance:self.deleteBtn enabled:(nil != self.error ? TRUE : FALSE)];

        return;
    }
   
    self.statusLabel.text = (self.exampleAsset.fastPlayReady ? @"FastPlay ready" : @"Preparing for FastPlay...");
    
    [self setEnabledAppearance:self.deleteBtn enabled:YES];
    
    self.statusProgressBar.progress = self.exampleAsset.fractionComplete;
}

-(void)setEnabledAppearance:(UIControl*)control enabled:(Boolean)enabled
{
    [control setEnabled:enabled];
    [control setBackgroundColor:(enabled ? [UIColor blackColor] : [UIColor lightGrayColor])];
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
    [self refreshView];

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

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports a VirtuosoAsset is ready for FastPlay
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineFastPlayAssetReady:(VirtuosoAsset *)asset
{
    NSLog(@"FastPlay asset reported ready to play. Asset: %@", asset);    
    [self fastPlayAsset: asset];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine encounters an error
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset
                                         error:(NSError *)error
                                          task:(NSURLSessionTask *)task
                                          data:(NSData *)data
                                    statusCode:(NSNumber *)statusCode {
    
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

-(void)downloadEngineStartupComplete:(Boolean)succeeded {
    [self loadEngineData];
}

@end
