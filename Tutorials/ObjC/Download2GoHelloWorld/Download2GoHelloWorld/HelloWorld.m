//
//  ViewController.m
//  Download2GoHelloWorld-Objc
//
// This source file contains a very basic example showing how to use the Virtuoso Download Engine.
// Pay close attention to code comments marked IMPORTANT
//

@import VirtuosoUIKit;
@import VirtuosoClientDownloadEngine;

#import "HelloWorld.h"
#import "DemoPlayerViewController.h"

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialized, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* publicKey = @"replace_with_your_public_key";        // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";      // <-- change this

@interface HelloWorld () <UIDownloadButtonDelegate>

//
// MARK: Instance data
//
@property (nonatomic, strong) NSString *exampleAssetID;
@property (nonatomic, strong) VirtuosoAsset *exampleAsset;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UIAssetStatusLabel  *statusLabel;
@property (weak, nonatomic) IBOutlet UIDownloadButton    *downloadBtn;
@property (weak, nonatomic) IBOutlet UIPlayButton        *playBtn;
@property (weak, nonatomic) IBOutlet UIAssetProgressView *statusProgressBar;

@end

@implementation HelloWorld

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable the buttons until we've started up and have restored
    // any download state from previous launches.
    self.downloadBtn.enabled = false;
    self.playBtn.enabled = false;
    
    // Set the download button delegate
    self.downloadBtn.delegate = self;
    
    self.statusLabel.text = @"Starting Engine...";
    
    // Important:
    // AssetID should be unique for each asset across your video catalog
    self.exampleAssetID = @"tears-of-steel-asset-1";
    
    // Backplane permissions require a unique user ID to properly function.
    // Production code that needs user-device tracking or download permissions
    // will need a unique customer ID. For demonstation purposes only, we use
    // the device name here.
    NSString* userName = UIDevice.currentDevice.name;
    
    //
    // Create the engine confuration
    VirtuosoEngineConfig* config = [[VirtuosoEngineConfig alloc]initWithUser:userName
                                                                   publicKey:publicKey
                                                                  privateKey:privateKey];
    
    if (!config)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Setup Required"
                                                                       message:@"Please contact support@penthera.com to setup the backplaneUrl, publicKey, and privateKey"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:TRUE completion:nil];
        return;
    }
    
    //
    // Start the Engine
    // This method will execute async, the callback will happen on the main-thread.
    [VirtuosoDownloadEngine.instance startup:config startupCallback:^(kVDE_EngineStartupCode status) {

        if (status == kVDE_EngineStartupSuccess) {

            NSLog(@"Startup succeeded.");
            self.statusLabel.text = @"Ready to download";

            // Load existing asset if we already created one in a previous run. Do this in the background to
            // prevent blocking UI
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                self.exampleAsset = [VirtuosoAsset assetWithAssetID:self.exampleAssetID availabilityFilter:NO];
            });
            
            // The download button, as configured, handles both starting a download
            // and deleting the existing download.  Whatever the state of the process,
            // once the engine has started, it's safe to enable it.
            self.downloadBtn.enabled = true;

        } else {
            NSLog(@"Startup encountered error.");
        }
    }];
}

// MARK: Click Handlers

- (IBAction)playBtnClicked:(UIButton *)sender
{
    // Microsoft Smooth Streaming (HSS) requires a proprietary player and
    // is not within scope of this demo.  Ignore it here.
    if( _exampleAsset.type != kVDE_AssetTypeHSS )
    {
        UIViewController* player = [DemoPlayerViewController new];
        
        // Play the asset using the downloaded (local) data.
        [_exampleAsset playUsingPlaybackType:kVDE_AssetPlaybackTypeLocal
                           andPlayer:(id<VirtuosoPlayer>)player
                           onSuccess:^ {
                               // Present the player
                               [self presentViewController:player animated:YES completion:nil];
                           }
                              onFail:^ {
                                  self.exampleAsset = nil;
                                  NSLog(@"Can't play video!");
                              }];
    }
}

- (VirtuosoAsset*)startAssetDownload
{
    // NOTE: This delegate handler will be called on a background thread.
    
    // If we don't already have an asset, then create one and download it. Otherwise, return the asset we already have.
    if( self.exampleAsset == nil )
    {
        // Important:
        // Create asset configuration object
        VirtuosoAssetConfig* assetConfig = [[VirtuosoAssetConfig alloc]initWithURL:@"https://virtuoso-demo-content.s3.amazonaws.com/tears/index.m3u8"
                                                                           assetID:self.exampleAssetID
                                                                       description:@"Tears of Steel"
                                                                              type:kVDE_AssetTypeHLS];
        if (!assetConfig)
        {
            NSLog(@"create config failed");
            return nil;
        }
        
        // Automatically adds to queue.
        VirtuosoAsset* asset = [VirtuosoAsset assetWithConfig:assetConfig];
        self.exampleAsset = asset;
    }

    return self.exampleAsset;
}

- (void)assetDeleted
{
    self.statusLabel.text = @"Deleted";
    
    // Clear the asset (thus clearing it from all UI elements) so we're ready to download again.
    self.exampleAsset = nil;
}

// Convenience method to hook up and reset the asset with the UI elements properly.
- (void)setExampleAsset:(VirtuosoAsset *)exampleAsset
{
    _exampleAsset = exampleAsset;
    self.downloadBtn.asset = self.exampleAsset;
    self.statusProgressBar.asset = self.exampleAsset;
    self.playBtn.asset = self.exampleAsset;
    self.statusLabel.asset = self.exampleAsset;
}

@end
