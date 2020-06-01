//
//  ViewController.m
//  Example1.4
//
//  Created by dev on 7/23/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "ViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "DemoPlayerViewController.h"

static NSString* TAG_MOVIE_POSTERS = @"movie-posters";

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialzied, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* backplaneUrl = @"https://qa.penthera.com";                                         // <-- change this
static NSString* publicKey = @"c9adba5e6ceeed7d7a5bfc9ac24197971bbb4b2c34813dd5c674061a961a899e";   // <-- change this
static NSString* privateKey = @"41cc269275e04dcb4f2527b0af6e0ea11d227319fa743e4364255d07d7ed2830";  // <-- change this


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
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *statusProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *pausingLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pausingSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *ancillaryImage;

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

- (IBAction)pauseClicked:(id)sender
{
    if (nil == self.exampleAsset )
    {
        return;
    }
    
    // Important:
    // The following call will cause the Download engine to pause downloading this asset
    self.exampleAsset.isPaused = self.pausingSwitch.isOn;
    
    [self refreshView];
}

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
        NSString* myAssetID = @"tears-of-steel-asset-1";
        
        // Important:
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

        [self addAncillary:config];
        

        // Important:
        // Creates the Asset and automatically begins parsing and downloading
        // Status messages are provided via VirtuosoDownloadEngineNotificationsDelegate methods.
        [VirtuosoAsset assetWithConfig:config];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            [self refreshView];
        });
        
    });
}

// Sample method to show how you might add an ancillary file to the asset for download
// Ancilllary files are downloaded with the asset. In this example, we download a movie poster.
-(void)addAncillary:(VirtuosoAssetConfig*)config {
    
    // Important:
    // Create ancillary and specify a tag of "movie-posters"
    // The tag allows you to logically group a collection of related Ancillaries
    VirtuosoAncillaryFile* ancillary = [[VirtuosoAncillaryFile alloc] initWithDownloadUrl:@"https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Tos-poster.png/440px-Tos-poster.png" andTag:TAG_MOVIE_POSTERS];
    
    if (!ancillary) {
        return;
    }
    
    // Important:
    // Add array of ancillaries  to asset creation config
    config.ancillaries = [NSArray arrayWithObject:ancillary];
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
    
    [self displayAncillary:self.exampleAsset];
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

-(void)displayAncillary:(VirtuosoAsset*)asset {
    self.ancillaryImage.image = nil;
    
    NSArray*  ancillaries = [asset findCompletedAncillariesWithTag:TAG_MOVIE_POSTERS];
    if (!ancillaries || ancillaries.count < 1) {
        return;
    }
    
    VirtuosoAncillaryFile* ancillary = ancillaries.firstObject;
    if ([ancillary isDownloaded]) {
        self.ancillaryImage.image = ancillary.image;
    }
    
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
        
        self.statusLabel.text = @"Ready to download";
        self.statusProgressBar.progress = 0;
        
        [self setEnabledAppearance:self.downloadBtn enabled:YES];
        [self setEnabledAppearance:self.playBtn enabled:NO];
        [self setEnabledAppearance:self.deleteBtn enabled:(nil != self.error ? TRUE : FALSE)];
        
        self.pausingLabel.enabled = false;
        [self.pausingSwitch setOn:false];
        self.pausingSwitch.enabled = false;
        
        return;
    }
    
    [self displayAncillary:self.exampleAsset];
    
    [self.pausingSwitch setOn:self.exampleAsset.isPaused];
    
    Boolean downloadInProcess = (self.exampleAsset.fractionComplete < 1) ? true : false;
    self.pausingLabel.enabled = downloadInProcess;
    self.pausingSwitch.enabled = downloadInProcess;
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
