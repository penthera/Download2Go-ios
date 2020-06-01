//
//  ViewController.m
//  Example11
//
//  Created by dev on 1/31/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "ViewController.h"

#import "DemoPlayerViewController.h"

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialzied, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* backplaneUrl = @"replace_with_your_backplane_url";
static NSString* publicKey = @"replace_with_your_public_key";
static NSString* privateKey = @"replace_with_your_private_key";

@interface ViewController ()

//
// MARK: Instance data
//
@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) VirtuosoBackplaneNotificationsManager* backplaneNotifications;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, assign) Boolean detectedDeviceUnregister;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *statusProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *assetName;

@end

@implementation ViewController

//
// MARK: Lifecycle methods
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // download engine update listener
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
    self.backplaneNotifications = [[VirtuosoBackplaneNotificationsManager alloc]initWithDelegate:self];
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
    // Start the Engine, this call only needs to happen one time.
    // This method will execute async, the callback will happen on the main-thread.
    [VirtuosoDownloadEngine.instance startup:config startupCallback:^(kVDE_EngineStartupCode status) {
        if (status != kVDE_EngineStartupSuccess)
        {
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Startup Error" message:[NSString stringWithFormat:@"Error starting the Engine. Status: %@", @(status)] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:TRUE completion:nil];
        }
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// MARK: Click Handlers
- (IBAction)unregisterClicked:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError* error = [self unregisterAllDevices];
        
        NSTimeInterval maximumWait = 30;
        NSTimeInterval sleepDuration = 1;
        while (!self.detectedDeviceUnregister && maximumWait > 0)
        {
            [NSThread sleepForTimeInterval:sleepDuration];
            maximumWait -= sleepDuration;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = nil;
            if (error)
            {
                 alert = [UIAlertController alertControllerWithTitle:@"Unregister Error" message:[NSString stringWithFormat:@"Error while unregistering devices. Error: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }]];
            }
            else if (maximumWait <= 0)
            {
                alert = [UIAlertController alertControllerWithTitle:@"Unregister Complete With Issues" message:@"All devices are unregistered but never detected device unregister notification. App will now exit." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    exit(0);
                }]];
            }
            else
            {
                alert = [UIAlertController alertControllerWithTitle:@"Unregister Complete" message:@"All devices are unregistered. App will now exit." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    exit(0);
                }]];
            }
            [self presentViewController:alert animated:TRUE completion:nil];
        });
    });
}

-(NSError*)unregisterAllDevices
{
    VirtuosoDevice* currentDevice = nil;
    
    NSError* error = nil;
    for (VirtuosoDevice* device in VirtuosoDownloadEngine.instance.devices)
    {
        if (device.isThisDevice)
        {
            currentDevice = device;
        }
        else
        {
            error = [self unregisterDeviceAndWait:device];
            if (error)
            {
                return error;
            }
        }
    }
    
    if (currentDevice)
    {
        error = [self unregisterDeviceAndWait:currentDevice];
    }
    
    return error;
}

-(NSError*)unregisterDeviceAndWait:(VirtuosoDevice*)device
{
    __block NSError* result = nil;
    if (!device)
    {
        NSLog(@"Parameter 'device' is required");
        return result;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [device unregisterOnComplete:^(Boolean success, NSError * _Nullable error) {
            result = error;
            if (success)
            {
                NSLog(@"unregister succeeded for device: %@", device.nickname);
            }
            else
            {
                NSLog(@"unregister failed for device: %@ error: %@", device.nickname, error);
            }
            dispatch_semaphore_signal(semaphore);
        }];
    });
    
    const int waitTimeInSeconds = 30;
    if( dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)waitTimeInSeconds * NSEC_PER_SEC)) != 0 )
    {
        NSLog(@"Timeout waiting for unregister device: %@", device.nickname);
        result = [NSError errorWithDomain:@"Virtuoso" code:kVDE_InternalError userInfo:@{NSLocalizedDescriptionKey: @"Timeout waiting for device delete to complete."}];
    }
    
    return result;
}



- (IBAction)deleteClicked:(UIButton *)sender
{
    sender.enabled = FALSE;  // block reentry
    if (self.exampleAsset)
    {
        [self.exampleAsset deleteAssetOnComplete:^
         {
             self.statusLabel.text = @"";
             self.statusProgressBar.progress = 0;
             // Give next smartdownload time to get started
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                 [self loadEngineData];
             });
             
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
        NSString* myAssetID = @"SEASON-1-EPISODE-1";
        
        // Create asset configuration object
        VirtuosoAssetConfig* config =
            [[VirtuosoAssetConfig alloc] initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep1/index.m3u8"
                                             assetID:myAssetID
                                         description:@"The Right Kite"
                                                type:kVDE_AssetTypeHLS];
        
        if (!config)
        {
            NSLog(@"create config failed");
            sender.enabled = YES;
            return;
        }

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
    self.assetName.text = [NSString stringWithFormat:@"Episode: %@", asset.description];
    
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
        }
        else {
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

- (void)downloadEngineInternalQueueUpdate {
    [self loadEngineData];
}

// ------------------------------------------------------------------------------------------------------------
// Called when Engine start is complete
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineStartupComplete:(Boolean)succeeded {
    [self loadEngineData];
}

// Device was unregistered
- (void)backplaneDidUnregisterDeviceWithStatus:(Boolean)success error:(NSError * _Nullable)error
{
    self.detectedDeviceUnregister = true;
}

// Device is about to start remote kill
- (void)backplaneStartingRemoteKill
{
    
}

// Device was remote killed happened
- (void)backplaneRemoteKill
{
    
}

// Device sync completed
- (void)backplaneSyncCompleteWithStatus:(Boolean)status error:(NSError * _Nullable)error
{
    
}


@end
