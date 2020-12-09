//
//  HelloWorld.m
//  Download2GoHelloWorld
//
//  Created by Mark S. Lee on 1/22/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import "HelloWorld.h"

#import "DemoPlayerViewController.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

typedef NS_ENUM(NSInteger, ApplicationStatus) {
  Unknown = 0,
  EngineStarting = 1,
  EngineFailure = 2,
  QueryEngineData = 3,
  ReadyToDownloadAsset = 4,
  DownloadingAsset = 5,
  ReadyToPlayAsset = 6,
  DeletingAsset = 7
};

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialized, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------

static NSString* backplaneUrl = @"replace_with_your_backplane_url";                                         // <-- change this
static NSString* publicKey = @"replace_with_your_public_key";   // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";  // <-- change this

@interface HelloWorld ()

//
// MARK: Instance data
//

@property (nonatomic,strong) VirtuosoAsset *exampleAsset;
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) NSError* error;

@end

@implementation HelloWorld
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

RCT_EXPORT_MODULE(HelloWorldController);

RCT_EXPORT_METHOD(startEngine)
{
  NSLog(@"startEngine bridge method invoked");
  
  if (!_engineStarted)
  {
    [self refreshView:EngineStarting asset:nil];
    
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
                                                                           message:@"Please contact support@penthera.com to setup the backplaneUrl, pulicKey, and privateKey"
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
    // Passing nil will result in the callback happening NSOperationQueue.mainQueue (main thread).
    [VirtuosoDownloadEngine.instance startup:config startupCallback:^(kVDE_EngineStartupCode status) {
        if (status == kVDE_EngineStartupSuccess) {
            NSLog(@"Startup succeeded.");
            self->_engineStarted = true;
            [self refreshView:ReadyToDownloadAsset asset:nil];
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

RCT_EXPORT_METHOD(download)
{
  NSLog(@"download bridge method invoked");
  
  if (_engineStarted)
  {
    if ( kVDE_ReachableViaWiFi != [VirtuosoDownloadEngine.instance currentNetworkStatus] ) {
      UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Unreachable" message:@"Demo requires WiFi" preferredStyle:UIAlertControllerStyleAlert];
      
      [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
      
      UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
      
      [rootViewController presentViewController:alert animated:TRUE completion:nil];
      
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
        return;
      }
      
      // Important:
      // Creates the Asset and automatically begins parsing and downloading
      // Status messages are provided via VirtuosoDownloadEngineNotificationsDelegate methods.
      [VirtuosoAsset assetWithConfig:config];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshView:DownloadingAsset asset:nil];
      });
    });
  }
}

RCT_EXPORT_METHOD(playDownload)
{
  // This must run on main thread
  
  NSLog(@"playDownload bridge method invoked");
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    [VirtuosoAsset isPlayable: self.exampleAsset callback:^(Boolean playable) {
      {
        if (playable)
        {
          if (self.exampleAsset.type != kVDE_AssetTypeHSS)
          {
            UIViewController* player = [DemoPlayerViewController new];
            
            [self.exampleAsset playUsingPlaybackType:kVDE_AssetPlaybackTypeLocal
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
      }
    }];
  });
}

RCT_EXPORT_METHOD(deleteDownload)
{
  NSLog(@"deleteDownload bridge method invoked");
  
  if (self.exampleAsset)
  {
    [self refreshView:DeletingAsset asset:nil];
    [self.exampleAsset deleteAssetOnComplete:^
     {
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

-(void) refreshView:(ApplicationStatus) status asset:(VirtuosoAsset*) asset
{
  // Bindings to the Javascript control states.  They need to match the references in App.js
  
  static const NSString* STATUS_TEXT_STATE = @"statusText";
  static const NSString* DOWNLOAD_BUTTON_STATE = @"downloadButtonDisabled";
  static const NSString* PLAY_BUTTON_STATE = @"playButtonDisabled";
  static const NSString* DELETE_BUTTON_STATE = @"deleteButtonDisabled";
  static const NSString* DOWNLOAD_PROGRESS_BAR_VISIBLE_STATE = @"downloadProgressBarVisible";
  static const NSString* DOWNLOAD_PROGRESS_STATE = @"downloadProgress";
  
  NSString* statusText = nil;
  
  BOOL downloadButtonDisabled = YES;
  BOOL playButtonDisabled = YES;
  BOOL deleteButtonDisabled = YES;
  BOOL downloadProgressBarVisible = NO;
  
  double downloadProgress = 0.0;
  
  if (status == QueryEngineData)
  {
    if (nil == asset) {
      if([[VirtuosoDownloadEngine instance]started]){
        status = ReadyToDownloadAsset;
      }
      else{
        status = EngineFailure;
      }
    }
    else
    {
      if (asset.status == kVDE_DownloadComplete)
      {
        status = ReadyToPlayAsset;
      }
      else
      {
        status = DownloadingAsset;
      }
    }
  }
  
  switch (status)
  {
    case Unknown:
      statusText = @"Unknown Engine Status";
      break;
    case QueryEngineData:
      // Preprocessed above...
      break;
    case EngineStarting:
      statusText = @"Engine Starting...";
      break;
    case EngineFailure:
      statusText = @"Engine Failed to Start";
      break;
    case ReadyToDownloadAsset:
      statusText = @"Engine Started. Ready to Download";
      downloadButtonDisabled = NO;
      break;
    case DownloadingAsset:
      statusText = [self downloadProgress:status asset:asset];
      deleteButtonDisabled = NO;
      downloadProgressBarVisible = YES;
      downloadProgress = asset.fractionComplete;
      break;
    case ReadyToPlayAsset:
      statusText = @"Ready to Play";
      playButtonDisabled = NO;
      deleteButtonDisabled = NO;
      break;
    case DeletingAsset:
      statusText = @"Deleting Download...";
      downloadButtonDisabled = NO;
      break;
  }
  
  [self sendEventWithName:REFRESH_VIEW_EVENT
                     body:@{
                       STATUS_TEXT_STATE: (statusText),
                       DOWNLOAD_BUTTON_STATE : @(downloadButtonDisabled),
                       PLAY_BUTTON_STATE : @(playButtonDisabled),
                       DELETE_BUTTON_STATE : @(deleteButtonDisabled),
                       DOWNLOAD_PROGRESS_BAR_VISIBLE_STATE: @(downloadProgressBarVisible),
                       DOWNLOAD_PROGRESS_STATE: @(downloadProgress)
                     }];
}

-(NSString*)downloadProgress:(ApplicationStatus) status asset:(VirtuosoAsset*) asset
{
  NSString* progress = nil;
  
  if (nil != asset)
  {
    double fractionComplete = asset.fractionComplete;
    
    if (asset.status != kVDE_DownloadComplete && asset.status != kVDE_DownloadProcessing)
    {
      NSString* statusMessage = (asset.status == kVDE_DownloadInitializing) ? NSLocalizedString(@"Initializing: ", @"") : @"";
      NSString* errorMessage = (asset.downloadRetryCount > 0)? [NSString stringWithFormat:@" (Errors: %i)",asset.downloadRetryCount] : @"";
      
      progress = [NSString stringWithFormat:@"%@%0.02f%% (%qi MB)%@", statusMessage, fractionComplete*100.0, asset.currentSize/1024/1024, errorMessage];
    }
    else if (asset.status == kVDE_DownloadComplete)
    {
      progress = [NSString stringWithFormat:@"%0.02f%% (%qi MB)",fractionComplete*100.0,asset.currentSize/1024/1024];
    }
  }
  else
  {
    progress = @"Downloading...";
  }
  
  return progress;
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
        
        [self refreshView:QueryEngineData asset:self.exampleAsset];
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
  [self refreshView:DownloadingAsset asset:asset];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports progress for a VirtuosoAsset object
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset * _Nonnull)asset
{
  [self refreshView:DownloadingAsset asset:asset];
}

// ------------------------------------------------------------------------------------------------------------
// Called when an asset is being processed after background transfer
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset
{
  [self refreshView:DownloadingAsset asset:asset];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports a VirtuosoAsset as complete
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
  [self refreshView:ReadyToPlayAsset asset:asset];
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
  [self refreshView:DownloadingAsset asset:asset];
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


