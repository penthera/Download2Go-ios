//
//  ViewController.m
//  Example17
//
//  Created by Penthera on 10/8/21.
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
@property (nonatomic, strong) NSArray* bandwidths;
@property (nonatomic, assign) NSInteger bandwidthIndex;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *statusProgressBar;
@property (weak, nonatomic) IBOutlet UIPickerView *bandwidthPicker;

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

    // Set the rendition delegate
    
    [VirtuosoAsset setRenditionSelectionDelegate:self];
    
    // Bandwidths available for this asset
    
    self.bandwidths = @[@(258157) ,@(520929), @(831270), @(1144430), @(1558322), @(4149264), @(6214307), @(10285391)];
    
    self.bandwidthPicker.delegate = self;
    
    self.bandwidthIndex = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// MARK: UIPickerViewDataSource

// Number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.bandwidths.count;
}

// MARK: UIPickerViewDelegate

// The data to return for the row and component (column) that's being passed in
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    NSString* bandwidth = @"unknown";
    
    if (row >= 0 && row < self.bandwidths.count)
    {
        bandwidth = [NSString stringWithFormat:@"%d", [self.bandwidths[row] intValue]];
    }

    return bandwidth;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row >= 0 && row < self.bandwidths.count)
    {
        self.bandwidthIndex = row;
        
        [self refreshView];
    }
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
        // Important:
        // AssetID should be unique across your video catalog
        NSString* myAssetID = @"sintel-asset-1";
        
        // Important:
        // Create asset configuration object
        VirtuosoAssetConfig* config = [[VirtuosoAssetConfig alloc]initWithURL:@"https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
                                                                      assetID:myAssetID
                                                                  description:@"Sintel" type:kVDE_AssetTypeHLS];
        if (!config)
        {
            NSLog(@"create config failed");
            sender.enabled = YES;
            return;
        }

        // Set the userInfo dictionary to track which bandwidth was selected to download.
        //
        // The userInfo dictionary is accessible via the asset and the asset is passed as a parameter
        // to the rendition selection delegate.
        
        config.userInfo = @{@"bandwidth_requested": self.bandwidths[self.bandwidthIndex]};
                
        // Important:
        // Creates the Asset and automatically begins parsing and downloading
        // Status messages are provided via VirtuosoDownloadEngineNotificationsDelegate methods.
        self.exampleAsset =[VirtuosoAsset assetWithConfig:config];
        
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
        self.bandwidthPicker.userInteractionEnabled = NO;
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
                
                self.bandwidthIndex = 0;
                
                if (self.exampleAsset)
                {
                    // Reset our bandwidth picker
                    
                    // Unpack our userInfo dictionary on the asset to find the selected bandwidth.
                    
                    int bandwidthRequested = [[self.exampleAsset.userInfo objectForKey:@"bandwidth_requested"] intValue];
                    
                    if (bandwidthRequested)
                    {
                        for (int i = 0; i < self.bandwidths.count; i++)
                        {
                            if ([self.bandwidths[i] intValue] == bandwidthRequested)
                            {
                                self.bandwidthIndex = i;
                                
                                break;
                            }
                        }
                    }
                }
                
                [self.bandwidthPicker selectRow:self.bandwidthIndex inComponent:0 animated:NO];
                
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
        
        self.statusLabel.text = [NSString stringWithFormat:@"Ready to download (Bandwidth = %d)", [self.bandwidths[self.bandwidthIndex] intValue]];
        self.statusLabel.enabled = false;
        self.statusProgressBar.progress = 0;
        
        [self setEnabledAppearance:self.downloadBtn enabled:YES];
        self.bandwidthPicker.userInteractionEnabled = YES;
        [self setEnabledAppearance:self.playBtn enabled:NO];
        [self setEnabledAppearance:self.deleteBtn enabled:(nil != self.error ? TRUE : FALSE)];
        
        return;
    }

    Boolean downloadInProcess = (self.exampleAsset.fractionComplete < 1) ? true : false;
    
    self.statusLabel.text = (downloadInProcess ?
                             [NSString stringWithFormat:@"Downloading (Bandwidth = %d)...", [self.bandwidths[self.bandwidthIndex] intValue]]:
                             [NSString stringWithFormat:@"Ready to play (Bandwidth = %d)", [self.bandwidths[self.bandwidthIndex] intValue]]);
    
    [self setEnabledAppearance:self.deleteBtn enabled:YES];
    [self setEnabledAppearance:self.downloadBtn enabled:NO];
    self.bandwidthPicker.userInteractionEnabled = NO;
    
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
// Called whenever the Engine encounters an error
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset
                                 virtuosoError:(VirtuosoError *)error
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

//
// MARK: VirtuosoRenditionSelectionDelegate
//

- (VirtuosoVideoRendition*)selectRenditionFromAvailableRenditions:(NSArray<VirtuosoVideoRendition*>*)renditions forAsset:(VirtuosoAsset*)asset
{
    VirtuosoVideoRendition* selectedRendition = nil;
    
    // Unpack our userInfo dictionary on the asset to find the selected bandwidth.
    
    int bandwidthRequested = [[asset.userInfo objectForKey:@"bandwidth_requested"] intValue];
    
    if (bandwidthRequested)
    {
        for (VirtuosoVideoRendition* rendition in renditions)
        {
            // Prefer HLS average bandwidth over bandwidth (peak) if it is specified in the manifest
            
            if ((rendition.averageBandwidth && rendition.averageBandwidth == bandwidthRequested) ||
                rendition.bandwidth == bandwidthRequested)
            {
                selectedRendition = rendition;
                
                break;
            }
        }
    }
            
    return selectedRendition;
}

@end
