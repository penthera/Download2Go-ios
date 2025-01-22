//
//  ViewController.m
//  Example1.2
//
//  Created by Penthera on 7/18/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

@import VirtuosoUIKit;
@import VirtuosoClientDownloadEngine;

#import "ViewController.h"
#import "DemoPlayerViewController.h"

static NSString* TAG_MOVIE_POSTERS = @"movie-posters";

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following two values must be initialzied and the backplace URL in the "Info" File, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* publicKey = @"replace_with_your_public_key";        // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";      // <-- change this

@interface ViewController () <UIDownloadButtonDelegate>

//
// MARK: Instance data
//
@property (nonatomic, strong) NSString *exampleAssetID;
@property (nonatomic,strong) VirtuosoAsset *exampleAsset;

//
// MARK: Outlets
//
@property (weak, nonatomic) IBOutlet UIAssetStatusLabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIDownloadButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIPlayButton *playBtn;
@property (weak, nonatomic) IBOutlet UIAssetProgressView *statusProgressBar;
@property (weak, nonatomic) IBOutlet UIAssetPauseSwitch *pausingSwitch;
@property (weak, nonatomic) IBOutlet UIAncillaryImageView *ancillaryImage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.statusLabel.text = @"Starting Engine...";
    
    // Important:
    // AssetID should be unique for each asset across your video catalog
    self.exampleAssetID = @"tears-of-steel-asset-1";

    // Backplane permissions require a unique user-id for the full range of captabilities support to work
    // Production code that needs this will need a unique customer ID.
    // For demonstation purposes only, we use the device name
    NSString* userName = UIDevice.currentDevice.name;
    
    // Setup the UIAncillaryImageView with the tag we're going to use
    self.ancillaryImage.ancillaryTag = TAG_MOVIE_POSTERS;
    
    // Set the download button delegate so we can start downloads and react to deletions
    self.downloadBtn.delegate = self;
    
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
        if (status == kVDE_EngineStartupSuccess)
        {
            NSLog(@"Startup succeeded.");
            self.statusLabel.text = @"Ready to download";
            
            // Load existing asset if we already created one in a previous run.  This should be done on a
            // background thread to prevent UI blocking
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                self.exampleAsset = [VirtuosoAsset assetWithAssetID:self.exampleAssetID availabilityFilter:NO];
            });
            
            // The download button, as configured, handles both starting a download
            // and deleting the existing download.  Whatever the state of the process,
            // once the engine has started, it's safe to enable it.
            self.downloadBtn.enabled = true;
        }
        else
        {
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
                                  if( self.exampleAsset )
                                  {
                                      [self.exampleAsset deleteAssetOnComplete:^{
                                          self.exampleAsset = nil;
                                      }];
                                  }
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
        
        // Add an ancillary (in this case a poster image file) to the asset
        [self addAncillary:assetConfig];

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

// Convenience method to hook up and reset the asset with the UI elements properly.
- (void)setExampleAsset:(VirtuosoAsset *)exampleAsset
{
    _exampleAsset = exampleAsset;
    self.downloadBtn.asset = self.exampleAsset;
    self.statusProgressBar.asset = self.exampleAsset;
    self.playBtn.asset = self.exampleAsset;
    self.statusLabel.asset = self.exampleAsset;
    self.ancillaryImage.asset = self.exampleAsset;
    self.pausingSwitch.asset = self.exampleAsset;
}

@end
