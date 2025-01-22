//
//  ViewController.m
//  Example12
//
//  Created by dev on 2/3/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "ViewController.h"

#import "DemoPlayerViewController.h"

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following two values must be initialzied and the backplace URL in the "Info" File, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* publicKey = @"replace_with_your_public_key";   // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";  // <-- change this

@interface ViewController ()

//
// MARK: Instance data
//
@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) VirtuosoError* error;
@property (nonatomic, assign)NSInteger downloadSelection;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *statusProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *assetName;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

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
    
    self.statusLabel.text = @"Starting Engine...";
    
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

- (IBAction)deleteClicked:(UIButton *)sender
{
    sender.enabled = FALSE;  // block reentry
    [self clearErrors];
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
    [self clearErrors];
    
    if ( kVDE_ReachableViaWiFi != [VirtuosoDownloadEngine.instance currentNetworkStatus] ) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Unreachable" message:@"Demo requires WiFi" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            sender.enabled = YES;
        }]];
         [self presentViewController:alert animated:TRUE completion:nil];
         return;
    }
    
    
    NSArray* invalidDownloads = [NSArray arrayWithObjects:@"https://hls-vbcp.s3.amazonaws.com/httyd_rel_response_error.m3u8",
                                 @"https://hls-vbcp.s3.amazonaws.com/normal/1200/im2_broken.m3u8",
                                 nil];
    
    NSString* downloadUrl = [invalidDownloads objectAtIndex:self.downloadSelection];
    self.downloadSelection += 1;
    if (self.downloadSelection >= invalidDownloads.count) {
        self.downloadSelection = 0;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // Create asset configuration object
        VirtuosoAssetConfig* config =
            [[VirtuosoAssetConfig alloc] initWithURL:downloadUrl
                                             assetID:[NSUUID UUID].UUIDString
                                         description:@"Test Video"
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

-(void)clearErrors
{
    self.errorLabel.text = @"";
    self.error = nil;
}

- (void)displayAsset:(VirtuosoAsset*)asset
{
    //self.assetName.text = asset.description;
    
    double fractionComplete = asset.fractionComplete;
    kVDE_DownloadStatusType status = asset.status;
    
    self.errorLabel.text = (self.error) ? self.error.localizedDescription : @"";
    
    if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
    {
        NSString* statusMessage = (asset.status == kVDE_DownloadInitializing) ? NSLocalizedString(@"Initializing: ", @"") : @"";
        
        self.statusLabel.text = [NSString stringWithFormat:@"%@%0.02f%% (%qi MB)", statusMessage, fractionComplete*100.0, asset.currentSize/1024/1024];
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
                                          [self clearErrors];
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
    self.statusLabel.text = @"";
    self.statusLabel.enabled = false;
    
    if (nil == self.exampleAsset) {
        
        if (!self.error) {
            self.statusLabel.text = @"Ready to download";
        }
        self.statusProgressBar.progress = 0;
        
        [self setEnabledAppearance:self.downloadBtn enabled:YES];
        [self setEnabledAppearance:self.playBtn enabled:NO];
        [self setEnabledAppearance:self.deleteBtn enabled:(nil != self.error ? TRUE : FALSE)];
        
        return;
    }
    
    Boolean downloadInProcess = (self.exampleAsset.fractionComplete < 1) ? true : false;
    
    if (!self.error) {
        self.statusLabel.text = (downloadInProcess ? @"Downloading..." : @"Ready to play");
    }
    
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

- (void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset virtuosoError:(VirtuosoError *)error task:(NSURLSessionTask *)task data:(NSData *)data statusCode:(NSNumber *)statusCode
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

@end
