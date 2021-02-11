//
//  ViewBridge.m
//  Example10
//
//  Created by Penthera on 4/01/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import "ViewBridge.h"

#import "DemoPlayerViewController.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialized, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------

static NSString* backplaneUrl = @"replace_with_your_backplane_url";                                         // <-- change this
static NSString* publicKey = @"replace_with_your_public_key";   // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";  // <-- change this

@interface ViewBridge ()

//
// MARK: Instance data
//

@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) NSError* error;

@property (nonatomic, copy)NSString* statusText;

@property (nonatomic, assign) BOOL fastPlayButtonDisabled;
@property (nonatomic, assign) BOOL deleteButtonDisabled;
@property (nonatomic, assign) BOOL downloadProgressBarVisible;

@property (nonatomic, assign)double downloadProgress;

@end

@implementation ViewBridge
{
  bool _engineStarted;
  
  NSOperationQueue* _queue;
}

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    _engineStarted = false;
    
    _queue = [NSOperationQueue new];
    
    self.fastPlayButtonDisabled = NO;
    self.deleteButtonDisabled = YES;
  }
  
  return self;
}

//
// MARK: RCTBridgeModule overrides - suppresses warning when module implements init
//

// We're not doing any rendering...

+(BOOL)requiresMainQueueSetup
{
  return NO;
}

//
// MARK: RCTBridgeModule - Methods available to React Native via Javascript
//

RCT_EXPORT_MODULE(Example10_Controller);

RCT_EXPORT_METHOD(startEngine)
{
  NSLog(@"startEngine bridge method invoked");
  
  if (!_engineStarted)
  {
    self.statusText = @"Starting Engine...";
    
    [self sendRefreshViewEvent];
    
    NSLog(@"Engine starting");
    
    // Important:
    // The download engine runs async in background. We can receive status updates by implementing
    // the VirtuosoDownloadEngineNotificationsDelegate methods. As processing progresses, our delegate
    // will receive callbacks allowing us to refresh the UI.
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
    
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
                                                                           message:@"Please contact support@penthera.com to setup the backplaneUrl, publicKey, and privateKey"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                exit(0);
            }];
            [alert addAction:ok];
          
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
          
            [rootViewController presentViewController:alert animated:TRUE completion:nil];
        });
      
        return;
    }
    
    //
    // Start the Engine
    // This method will execute async, the callback will happen on the main-thread.
    [VirtuosoDownloadEngine.instance startup:config startupCallback:^(kVDE_EngineStartupCode status) {
        if (status == kVDE_EngineStartupSuccess) {
            NSLog(@"Startup succeeded.");
            self->_engineStarted = true;
        } else {
            NSLog(@"Startup encountered error.");
        }
    }];
  }
  else
  {
    // Typically startEngine should only be called once, but if UI changes are made during
    // development and hot loaded it will be invoked again.
    
    [self loadEngineData];
  }
}

RCT_EXPORT_METHOD(fastPlay)
{
  NSLog(@"fastPlay bridge method invoked");
  
  if (_engineStarted)
  {
    // block reentrancy while we create the asset
    
    self.fastPlayButtonDisabled = YES;
    
    [self sendRefreshViewEvent];
        
    // This button does double duty
    
    if (self.exampleAsset && self.exampleAsset.fastPlayReady) {
        // Asset has already been queued for FastPlay and is ready for playback
        
        [self fastPlayAsset];
    }
    else {
      if ( kVDE_ReachableViaWiFi != [VirtuosoDownloadEngine.instance currentNetworkStatus] ) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Unreachable" message:@"Demo requires WiFi" preferredStyle:UIAlertControllerStyleAlert];
      
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
      
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
      
        [rootViewController presentViewController:alert animated:TRUE completion:nil];
      
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
          
        self.fastPlayButtonDisabled = NO;
           
        [self sendRefreshViewEvent];
        
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
          
            self.statusText = @"Preparing for FastPlay...";
          
            [self sendRefreshViewEvent];
        });
      });
    }
  }
}

RCT_EXPORT_METHOD(deleteDownload)
{
  NSLog(@"deleteDownload bridge method invoked");
  
  if (self.exampleAsset)
  {
    self.statusText = [NSString stringWithFormat:@"Deleting Asset:%@", self.exampleAsset];
    
    [self sendRefreshViewEvent];
    
    [self.exampleAsset deleteAssetOnComplete:^
     {
        self.statusText = @"Deleted.";
        self.fastPlayButtonDisabled = NO;
        self.downloadProgressBarVisible = NO;
        [self loadEngineData];
     }];
  }
}

//
// MARK: RCTEventEmitter - Array of Javascript events available to Native
//

static NSString* const REFRESH_VIEW_EVENT = @"refreshView";

-(NSArray<NSString *> *)supportedEvents
{
  return @[REFRESH_VIEW_EVENT];
}

//
// MARK: Internal helper methods
//
 
-(void)refreshView
{
  if (nil == self.exampleAsset) {
    self.statusText = @"Ready to start FastPlay";
    self.downloadProgress = 0.0;
    self.deleteButtonDisabled  = (nil == self.error ? YES : NO);
  }
  else {
    self.statusText = (self.exampleAsset.fastPlayReady ? @"FastPlay ready" : @"Preparing for FastPlay...");
    
    self.deleteButtonDisabled = NO;
    
    self.downloadProgressBarVisible = YES;
    self.downloadProgress = self.exampleAsset.fractionComplete;
  }
}

- (void)displayAsset:(VirtuosoAsset*)asset
{
    double fractionComplete = asset.fractionComplete;
  
    kVDE_DownloadStatusType status = asset.status;
    
    if (asset.fastPlayReady)
    {
      self.statusText = [NSString stringWithFormat:@"FastPlay ready at %0.02f%% complete (%qi MB)",fractionComplete*100.0,asset.currentSize/1024/1024];
      self.downloadProgress = fractionComplete;
    }
    else
    {
        if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
        {
          NSString* statusMessage = (asset.status == kVDE_DownloadInitializing) ? NSLocalizedString(@"Initializing: ", @"") : @"";
          NSString* errorMessage = (asset.downloadRetryCount > 0)? [NSString stringWithFormat:@" (Errors: %i)",asset.downloadRetryCount] : @"";
            
          self.statusText = [NSString stringWithFormat:@"%@%0.02f%% (%qi MB)%@", statusMessage, fractionComplete*100.0, asset.currentSize/1024/1024, errorMessage];
          self.downloadProgress = fractionComplete;
          self.fastPlayButtonDisabled = YES;
        }
        else if( status == kVDE_DownloadComplete )
        {
            self.statusText = [NSString stringWithFormat:@"%0.02f%% (%qi MB)",fractionComplete*100.0,asset.currentSize/1024/1024];
            self.downloadProgress = fractionComplete;
        }
    }
}

-(void) sendRefreshViewEvent
{
  // Bindings to the Javascript control states.  They need to match the references in App.js
  
  static const NSString* STATUS_TEXT_STATE = @"statusText";
  static const NSString* FASTPLAY_BUTTON_STATE = @"fastPlayButtonDisabled";
  static const NSString* DELETE_BUTTON_STATE = @"deleteButtonDisabled";
  static const NSString* DOWNLOAD_PROGRESS_BAR_VISIBLE_STATE = @"downloadProgressBarVisible";
  static const NSString* DOWNLOAD_PROGRESS_STATE = @"downloadProgress";
   
  [self sendEventWithName:REFRESH_VIEW_EVENT
                     body:@{
                       STATUS_TEXT_STATE: (self.statusText),
                       FASTPLAY_BUTTON_STATE : @(self.fastPlayButtonDisabled),
                       DELETE_BUTTON_STATE : @(self.deleteButtonDisabled),
                       DOWNLOAD_PROGRESS_BAR_VISIBLE_STATE: @(self.downloadProgressBarVisible),
                       DOWNLOAD_PROGRESS_STATE: @(self.downloadProgress)
                     }];
}

-(void)playAsset
{
    [self playAssetWithPlaybackType:kVDE_AssetPlaybackTypeLocal];
}

-(void)fastPlayAsset
{
    [self playAssetWithPlaybackType:kVDE_AssetPlaybackTypeFastPlay];
}

- (void)playAssetWithPlaybackType:(kVDE_AssetPlaybackType)playbackType
{
  // This must run on main thread
   
  dispatch_async(dispatch_get_main_queue(), ^{
    
    self.fastPlayButtonDisabled = NO;
    
    [self sendRefreshViewEvent];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    [VirtuosoAsset isPlayable: self.exampleAsset callback:^(Boolean playable) {
      {
        if (playable)
        {
          UIViewController* player = [DemoPlayerViewController new];
          
          [self.exampleAsset playUsingPlaybackType:playbackType
                                         andPlayer:(id<VirtuosoPlayer>)player
                                         onSuccess:^ {
            // Present the player
            [rootViewController presentViewController:player animated:YES completion:nil];
          }
                                            onFail:^ {
            self.exampleAsset = nil;
            self.error = nil;
            NSLog(@"Can't play video!");
          }];
        }
      }
    }];
  });
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
        
        if (nil != self.exampleAsset) {
          [self displayAsset:self.exampleAsset];
        }
        
        [self sendRefreshViewEvent];
      });
    } else {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadEngineData];
      });
    }
  });
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
  [self sendRefreshViewEvent];
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
    [self sendRefreshViewEvent];
  }];
}

// ------------------------------------------------------------------------------------------------------------
// Called when an asset is being processed after background transfer
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset
{
  [self displayAsset:asset];
  [self refreshView];
  [self sendRefreshViewEvent];
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
  
  self.exampleAsset = asset;
    
  [self fastPlayAsset];
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

