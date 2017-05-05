/*!
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  The VirtuosoClientEngineDemo project has been provided as an example application
 *  that uses the Virtuoso Download SDK.  It is provided as-is with no warranties whatsoever,
 *  expressed or implied.  This project provides a working example and shows ONE possible
 *  use of the SDK for a end-to-end video download process.  Other configurations
 *  are possible.  Please contact Penthera support if you have any questions.  We
 *  are here to help!
 *
 *  @copyright (c) 2017 Penthera Inc. All Rights Reserved.
 *
 */

#import "ViewController.h"
#import "SettingsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AddNewItemViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "AppDelegate.h"
#import <VirtuosoClientSubscriptionManager/VirtuosoSubscriptionManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "VirtuosoMoviePlayerViewController.h"
#import "UIAlertView+MKBlockAdditions.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

static Boolean hasStartedUp = NO;
static NSDate* startDownloadTime;

// Private test method.  DO NOT make this part of the public release!!
@interface VirtuosoClientHTTPServer()
-(id)initWithAsset:(VirtuosoAsset*)asset withOpenInterface:(Boolean)open;
@end

// Private test method.  DO NOT make this part of the public release!
@interface VirtuosoSettings()
- (void)setMaxBackgroundDownloadTime:(NSTimeInterval)time;
@end

typedef void(^UIActionSheetCompleteBlock)(UIActionSheet* actionSheet, NSInteger buttonIndex);

@interface ViewController () <UIAlertViewDelegate,UIActionSheetDelegate>

@property (nonatomic,assign) NSTimeInterval secondsAtPlaybackStart;
@property (nonatomic,strong) VirtuosoAsset* playingAsset;
@property (nonatomic,copy) UIActionSheetCompleteBlock actionSheetCompleteBlock;

@property (nonatomic,strong) UIViewController* player;
@property (nonatomic,strong) VirtuosoClientHTTPServer* playerProxy;

@property (nonatomic,strong) NSMutableArray* pendingAssets;
@property (nonatomic,strong) NSMutableArray* completedAssets;

@end

@implementation ViewController

@synthesize tableView = _tableView;

- (void)dealloc
{
}

- (void)reloadTable
{
    if( [[VirtuosoDownloadEngine instance]started] )
    {
        self.pendingAssets = [[VirtuosoAsset pendingAssetsWithAvailabilityFilter:NO]mutableCopy];
        self.completedAssets = [[VirtuosoAsset completedAssetsWithAvailabilityFilter:NO]mutableCopy];
    }
    else
    {
        self.pendingAssets = nil;
        self.completedAssets = nil;
    }
    [self.tableView reloadData];
}

/*
 *  This method is called upon receipt of kDownloadEngineStatusDidChangeNotification and when the Engine
 *  is first started up or when the view reappears.
 */
- (void)updateStatusLabel
{
    /*
     * The current status is not documented as having performance concerns, so we can assume it's
     * fast to access.  Just grab the latest status and display it in the toolbar status label.
     */
    VirtuosoDownloadEngine* engine = [VirtuosoDownloadEngine instance];
    kVDE_DownloadEngineStatus status = engine.status;
    
    switch (status) {
        case kVDE_Blocked:
            statusLabel.text = @"Blocked";
            break;
            
        case kVDE_Idle:
            statusLabel.text = @"Idle";
            break;
            
        case kVDE_Errors:
            statusLabel.text = @"Halted For Download Errors";
            break;
            
        case kVDE_Disabled:
            statusLabel.text = @"Disabled";
            break;
            
        case kVDE_Downloading:
            statusLabel.text = @"Downloading";
            break;
            
        default:
            break;
    }
}

/*
 *  This method is called upon receipt of all download-related notifications.
 */
- (void)updateStorageLabels
{
    /*
     *  This is called fairly frequently, and since we're querying on overall file storage
     *  statistics, that might take a short while, so we'll pass off the method calls and
     *  calculations to a background thread and then update the UI in the main thread.  These
     *  methods won't take a great deal of time, but due to the frequency of the calls we are
     *  making in THIS example, doing it this way prevents choppiness in the UI.
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        long long used = [VirtuosoAsset storageUsed]/1024/1024;
        NSString* kbps = [[VirtuosoDownloadEngine instance] downloadBandwidthString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            usedStorageLabel.text = [NSString stringWithFormat:@"%qi MB",used];
            self.navigationItem.title = kbps;
        });
    });
}

/*
 * Called for every Engine status change, received by kDownloadEngineStatusDidChangeNotification
 *
 * In this example, we show a notice when the Engine gets halted due to errors or when downloading
 * is blocked due to an environmental limit.
 */
- (void)postAlertForStatus:(kVDE_DownloadEngineStatus)status
{
    switch (status) {
        case kVDE_Idle:
            
            break;
            
        case kVDE_Errors:
        {
            [[[UIAlertView alloc]initWithTitle:@"Download Errors"
                                       message:@"Too many errors were encountered while attempting to download the files in the queue.  This usually indicates an issue with the remote server configuration or with the file metadata provided during creation of the download request."
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil]show];
        }
            break;
            
        case kVDE_Blocked:
        {
            NSString* conditions = @"";
            VirtuosoDownloadEngine* engine = [VirtuosoDownloadEngine instance];
            
            // We're not really "blocked" if there's nothing in the queue to download.
            // No point in notifying the user of it.
            if( engine.assetsInQueue.count == 0 )
                break;
            
            NSMutableArray* _conditions = [NSMutableArray array];
            
            if( ![engine networkStatusOK] )
            {
                [_conditions addObject:@"Network Not Reachable"];
            }
            
            if( ![engine diskStatusOK] )
            {
                [_conditions addObject:@"Disk Limits Reached"];
            }
            
            if( ![engine queueStatusOK] )
            {
                [_conditions addObject:@"Download Limit Reached"];
            }
            
            conditions = [_conditions componentsJoinedByString:@", "];
            
            [[[UIAlertView alloc]initWithTitle:@"Download Blocked"
                                       message:[NSString stringWithFormat:@"Downloads are currently blocked due to the following environmental conditions: %@",conditions]
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil]show];
            UILocalNotification* notice = [[UILocalNotification alloc]init];
            notice.alertBody = [NSString stringWithFormat:@"Downloads blocked: %@",conditions];
            notice.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
            break;
            
        case kVDE_Disabled:
            
            break;
            
        case kVDE_Downloading:
            
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     *  The SDK uses the NSNotificationCenter design paradigm.  In our load method, we'll register for any Engine notices
     *  we need to react to.
     */
    
    /*
     *  We need to track play start and play stop manually, since the SDK can't reliably detect it.  To detect play stop, we'll link into the
     *  MPMoviePlayerController events
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackStateDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      MPMoviePlayerController* mp = (MPMoviePlayerController*)note.object;
                                                      
                                                      NSTimeInterval secondsSince = [[NSDate date]timeIntervalSince1970]-self.secondsAtPlaybackStart;
                                                      //NSLog(@"Detected time shift: %f",secondsSince);
                                                      
                                                      // When the user taps Done, we get a paused event immediately followed by a stop event.
                                                      // We don't want to log a double-stop event in the Backplane events, so we'll filter
                                                      // out events that happen in quick succession.  In production code, there may be a better
                                                      // way to do this, but this is a demo app, so we'll do it the "quick" way.
                                                      if( (self.secondsAtPlaybackStart != -1 && secondsSince <= 0.2) || self.playingAsset == nil )
                                                          return;
                                                      
                                                      switch( mp.playbackState )
                                                      {
                                                          case MPMoviePlaybackStateStopped:
                                                              [VirtuosoLogger logPlaybackStoppedForAsset:self.playingAsset withSecondsSinceLastStart:secondsSince];
                                                              self.secondsAtPlaybackStart = [[NSDate date]timeIntervalSince1970];
                                                              break;
                                                              
                                                          case MPMoviePlaybackStatePlaying:
                                                              [VirtuosoLogger logPlaybackStartedForAsset:self.playingAsset];
                                                              self.secondsAtPlaybackStart = [[NSDate date]timeIntervalSince1970];
                                                              break;
                                                              
                                                          case MPMoviePlaybackStatePaused:
                                                              [VirtuosoLogger logPlaybackStoppedForAsset:self.playingAsset withSecondsSinceLastStart:secondsSince];
                                                              self.secondsAtPlaybackStart = [[NSDate date]timeIntervalSince1970];
                                                              break;
                                                              
                                                          case MPMoviePlaybackStateInterrupted:
                                                              [VirtuosoLogger logPlaybackStoppedForAsset:self.playingAsset withSecondsSinceLastStart:secondsSince];
                                                              self.secondsAtPlaybackStart = [[NSDate date]timeIntervalSince1970];
                                                              break;
                                                              
                                                          default:
                                                              break;
                                                      }
                                                  }];
    
    /*
     *  If the movie player exits in the middle of watching an ad, then we need to cancel the monitor.  Also, use this to fire session cleanup.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kMoviePlayerDidExitNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      // Calling these when they weren't started via the group play method does nothing,
                                                      // so it's safe to just call these here and let the SDK do what it needs to.
                                                      [self.playingAsset stoppedPlaying];
                                                      self.playingAsset = nil;
                                                  }];
    /*
     *  Application just entered foreground.  Just refresh the UI.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateStatusLabel];
                                                      [self updateStorageLabels];
                                                      [self reloadTable];
                                                      [self viewWillAppear:YES];
                                                      [self viewDidAppear:YES];
                                                  }];
    
    /*
     *  Called whenever the Backplane finishes syncing.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneSyncResultNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                           // If the backplane had forced delete items, then we need to reload data.
                                                           [self reloadTable];
                                                       }];
    
    /*
     *  Called whenever the Backplane deletes assets
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneAssetDeletedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                           // If the backplane had forced delete items, then we need to reload data.
                                                           [self reloadTable];
                                                       }];
    
    /*
     *  Called whenever the Engine status changes
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineStatusDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      kVDE_DownloadEngineStatus status = [[note.userInfo objectForKey:kDownloadEngineStatusDidChangeNotificationStatusKey]intValue];
                                                      NSLog(@"Download engine status changed: %i",(int)status);
                                                      [self updateStatusLabel];
                                                      [self updateStorageLabels];
                                                      
                                                      [self postAlertForStatus:status];
                                                  }];
    
    /*
     *  Called whenever the Engine starts downloading a VirtuosoAsset object.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidStartDownloadingAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      NSLog(@"Download engine started downloading asset: %@",asset.description);
                                                      startDownloadTime = [NSDate date];
                                                      
                                                      [self updateRowForAsset:asset];
                                                      [self updateStorageLabels];
                                                      
                                                      // In this demo, we fire off local notices so the Caller can see what's going on in the background if the application
                                                      // has been backgrounded.  These notices are not shown while the application is in the foreground.  This is for informational
                                                      // and test purposes only.
                                                      UILocalNotification* notice = [[UILocalNotification alloc]init];
                                                      notice.alertBody = [NSString stringWithFormat:@"Download engine reported asset downloading(%@)",asset!=nil?asset.description:@"None"];
                                                      notice.soundName = UILocalNotificationDefaultSoundName;
                                                      [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
                                                      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
                                                  }];
    
    /*
     *  Called whenever the Engine reports progress for a VirtuosoAsset object
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineProgressUpdatedForAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      
                                                      NSLog(@"Download engine reported download progress for asset: %f",asset.fractionComplete);
                                                      [self updateRowForAsset:asset];
                                                      [self updateStorageLabels];
                                                  }];
    
    /*
     *  Called when an asset is being processed after background transfer
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineProgressUpdatedForAssetProcessingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Download engine reported background file processing update for asset(%@).",[[note.userInfo objectForKey:kDownloadEngineNotificationAssetKey]description]);
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      
                                                      [self updateRowForAsset:asset];
                                                      [self updateStorageLabels];
                                                  }];
    
    /*
     *  Called when internal logic changes queue order.  All we need to do is refresh the tables.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineInternalQueueUpdateNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Download engine reported queue update.");
                                                      [self reloadTable];
                                                      [self updateStorageLabels];
                                                  }];
    
    /*
     *  Called whenever the Engine reports a VirtuosoAsset as complete
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidFinishDownloadingAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      NSLog(@"Download engine reported download complete: %@",asset.description);
                                                      
                                                      NSTimeInterval totalSeconds = fabs([startDownloadTime timeIntervalSinceNow]);
                                                      
                                                      [self updateStorageLabels];
                                                      [self reloadTable];
                                                      
                                                      // In this demo, we fire off local notices so the Caller can see what's going on in the background if the application
                                                      // has been backgrounded.  These notices are not shown while the application is in the foreground.  This is for informational
                                                      // and test purposes only.
                                                      if( [[UIApplication sharedApplication]applicationState] == UIApplicationStateActive )
                                                      {
                                                          
                                                          [[[UIAlertView alloc]initWithTitle:@"Download Finished"
                                                                                     message:[NSString stringWithFormat:@"Download engine reported asset complete (%@) and downloaded in %0.02f seconds.",asset!=nil?asset.description:@"None",totalSeconds]
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil]show];
                                                      }
                                                      else
                                                      {
                                                          UILocalNotification* notice = [[UILocalNotification alloc]init];
                                                          notice.alertBody = [NSString stringWithFormat:@"Download engine reported asset complete (%@) and downloaded in %0.02f seconds.",asset!=nil?asset.description:@"None",totalSeconds];
                                                          notice.soundName = UILocalNotificationDefaultSoundName;
                                                          [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
                                                          [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
                                                      }
                                                  }];
    
    /*
     *  Called whenever the Engine encounters a recoverable issue.  These are events that MAY be of concern to the Caller, but the Engine will continue
     *  the download process without intervention.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidEncounterWarningNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSError* error = [note.userInfo objectForKey:kDownloadEngineNotificationErrorKey];
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      
                                                      NSLog(@"Download engine encountered warning (%@) downloading asset (%@)",[error localizedDescription],asset.description);
                                                  }];
    
    /*
     *  Called whenever the Engine encounters an error that it cannot recover from.  This type of error will cause the engine to retry download of the file.  If too many
     *  errors are encountered, the Engine will move on to the next item in the queue.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidEncounterErrorNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSError* error = [note.userInfo objectForKey:kDownloadEngineNotificationErrorKey];
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      NSLog(@"Download error in asset(%@): %@",asset.description,[error localizedDescription]);
                                                      [self reloadTable];
                                                      
                                                  }];
    
    /*
     *  Called some period of time after the main application has been put into the background by the User.  Depending on application configuration, the Engine will keep the
     *  app alive in the background for some period of time in order to continue active downloads.  Once the Engine cannot keep the application alive any longer, due to iOS
     *  constraints, the Engine will pause downloads and allow the application to be put to sleep.  Before going to sleep, this notification is called to allow the Caller
     *  to take potential action if downloads were still pending at this point.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineIsEnteringBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSArray* continuingFiles = [note.userInfo objectForKey:kDownloadEngineNotificationContinuingAssetsKey];
                                                      NSArray* pausingFiles = [note.userInfo objectForKey:kDownloadEngineNotificationPausingAssetsKey];
                                                      
                                                      if( continuingFiles.count > 0 )
                                                      {
                                                          NSLog(@"Download engine reported app entering background and continuing download for assets in background: %@",continuingFiles);
                                                      }
                                                      if( pausingFiles.count > 0 )
                                                      {
                                                          NSLog(@"Download engine reported app entering background and pausing download for assets: %@",pausingFiles);
                                                      }
                                                      
                                                      if( continuingFiles.count == 0 && pausingFiles.count == 0 )
                                                      {
                                                          NSLog(@"Download engine reported app entering background and all downloads complete.");
                                                      }
                                                      
                                                      // In this demo, we fire off local notices so the Caller can see what's going on in the background if the application
                                                      // has been backgrounded.  These notices are not shown while the application is in the foreground.  This is for informational
                                                      // and test purposes only.
                                                      UILocalNotification* notice = [[UILocalNotification alloc]init];
                                                      notice.alertBody = [NSString stringWithFormat:@"Download engine reported sleep.  Pausing Assets(%lu) Continuing Assets(%lu)",(unsigned long)pausingFiles.count,(unsigned long)continuingFiles.count];
                                                      notice.soundName = UILocalNotificationDefaultSoundName;
                                                      [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
                                                      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
                                                  }];
    
    /*
     *  The Backplane issued a remote kill request.  The SDK will have reverted back to an uninitialized state and we must call the startup method again.  In this demo,
     *  we query the User for the Group and User to use, so we're going to revert ourselves back to startup state and ask for those values again, before calling startup.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneRemoteKillNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      hasStartedUp = NO;
                                                      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TestHarnessUserGroup"];
                                                      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TestHarnessUserName"];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                      
                                                      Boolean appActive = ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive);
                                                      [self.navigationController popToRootViewControllerAnimated:appActive];
                                                      
                                                      // Only do this if we're in the foreground.  If we pop alert views to login again while
                                                      // app is in background, all hell breaks loose.
                                                      if( appActive )
                                                      {
                                                          [self viewWillAppear:NO];
                                                          [self viewDidAppear:NO];
                                                      }
                                                  }];
    
    /*
     * When the Backplane notifies us that our device was unregistered, treat it like a remote wipe request.  The unregister action will already have cleared
     * out all the SDK state, so we just need to reset and ask for credentials again.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneDidUnregisterDeviceNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      hasStartedUp = NO;
                                                      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TestHarnessUserGroup"];
                                                      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TestHarnessUserName"];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                      
                                                      Boolean appActive = ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive);
                                                      [self.navigationController popToRootViewControllerAnimated:appActive];
                                                      
                                                      // Only do this if we're in the foreground.  If we pop alert views to login again while
                                                      // app is in background, all hell breaks loose.
                                                      if( appActive )
                                                      {
                                                          [self viewWillAppear:NO];
                                                          [self viewDidAppear:NO];
                                                      }
                                                  }];
    
    
    /*
     *  The Subscription Manager may auto-delete assets that exceed the maximum items per feed.  If you are maintaining your own metadata and
     *  are linking the VirtuosoAsset UUID values to your own metadata, then you should update your bookeeping here.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kSubscriptionManagerAssetDeletedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSArray* deletedAssetUUIDs = [note.userInfo objectForKey:kSubscriptionManagerNotificationVirtuosoAssetUUIDsKey];
                                                      
                                                      // If linking UUID to local metadata, delete the asset in our own bookeeping here.
                                                      NSLog(@"Detected deletion of subscription-based assets with UUIDs: %@",deletedAssetUUIDs);
                                                      
                                                      [self reloadTable];
                                                  }];
    
    /*
     *  When the Subscription Manager adds new assets, we need to refresh the views, so the new assets get shown
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kSubscriptionManagerAssetAddedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadTable];
                                                  }];
    
    /*
     *  Handle the data store upgrade path.  In this demo app, we'll just show a modal spinner to let us know what's going on.
     */
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidBeginDataStoreUpgradeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidFinishDataStoreUpgradeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                      [self reloadTable];
                                                  }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(doEdit:)];
    editButton = self.navigationItem.leftBarButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(doStart:)];
    startButton = self.navigationItem.rightBarButtonItem;
    
    self.navigationItem.title = @"Virtuoso Harness";
    if( [self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)] )
        self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTable];
    
    self.playingAsset = nil;
}

/*
 * This method is called after the User has entered the Group and User ID to use for Backplane startup.  This method
 * initializes the Download Engine instance with appropriate values for future use.  This MUST be done prior to calling
 * any other SDK methods, or exceptions will be thrown.
 */
- (void)finishStartup
{
    // Retrieve the singleton Engine instance
    VirtuosoDownloadEngine* engine = [VirtuosoDownloadEngine instance];
    
    // Request a push token HERE, so we have a push token to register on the backplane with.
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    NSString* user = [[NSUserDefaults standardUserDefaults] objectForKey:@"TestHarnessUserName"];
    
    // Startup the Engine with the Penthera-provided Backplane instance URL and the User-entered credentials
    //
    // NOTE: The Caller MUST use an appropriate Penthera-provided Backplane instance.  The server used in this example
    //       is a demo server and no guarantees or warranties are made about quality of service or data integrity.  The server
    //       may be updated, have data deleted, or be taken down without notice.
    
#warning These settings are for a Penthera test configuration.  You must insert your OWN Penthera-provided secret and key here
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    [settings registerDefaults:@{@"BackplaneURL":@"https://demo.penthera.com",
                                 @"PrivateKey":#PRIVATE_KEY_HERE#,
                                 @"PublicKey":#PUBLIC_KEY_HERE#,
                                 @"MaxBackgroundDownload":@(0),
                                 @"UsePackager":@(YES)}];
    
    [VirtuosoSettings instance].useStreamPackagerForBackgroundDownloads = [[NSUserDefaults standardUserDefaults]boolForKey:@"UsePackager"];
    
    // For the purposes of this demo, we'll let the engine sync as often as possible.  For normal production clients, you should
    // probably leave this at the default of 15 minutes.
    [VirtuosoSettings instance].minimumBackplaneSyncInterval = kDownloadEngineSyncIntervalMinimum;
    
    // You should only uncomment and use this method if you need it.  There is a slight performance hit when using this method.
    /*
    [VirtuosoAsset setSegmentWillDownloadBlock:^NSString *(id<VirtuosoFileSegment> segment, VirtuosoAsset *parsedAsset) {
        if( [parsedAsset.assetID isEqualToString:@"ASSET_THAT_NEEDS_TOKEN"] )
        {
            if( segment.segmentType == kVF_SegmentTypeStreamEncryptionKey )
            {
                return [segment.segmentURL stringByAppendingString:@"?token=<TOKEN>"];
            }
        }
        return segment.segmentURL;
    }];
     */
    
    [engine startupWithBackplane:[settings objectForKey:@"BackplaneURL"]
                            user:user
                externalDeviceID:nil
                      privateKey:[settings objectForKey:@"PrivateKey"]
                       publicKey:[settings objectForKey:@"PublicKey"]];
    
    // Setup any client-side SSL certificates required
    if( [[NSUserDefaults standardUserDefaults] objectForKey:@"UseClientSSL"] == nil )
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UseClientSSL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if( [[NSUserDefaults standardUserDefaults] boolForKey:@"UseClientSSL"] )
    {
        [VirtuosoSettings instance].clientSSLCertificatePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
        [VirtuosoSettings instance].clientSSLCertificatePassword = @"p3nth3ra";
    }
    else
    {
        // Reset this just in case it was saved from some previous session.  Not strictly needed, but safer to be explicit.
        [VirtuosoSettings instance].clientSSLCertificatePath = nil;
        [VirtuosoSettings instance].clientSSLCertificatePassword = nil;
    }
    
    // This is done for testing ONLY and uses internal APIs.  Don't do it unless you know what you're doing.
    [[VirtuosoSettings instance] setMaxBackgroundDownloadTime:[[settings objectForKey:@"MaxBackgroundDownload"]doubleValue]];
    NSLog(@"Max background download time is: %f",[[settings objectForKey:@"MaxBackgroundDownload"]doubleValue]);
    
    // Set the master enable switch based on the last state.
    engine.enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"ClientEngineEnabledPreference"];
    if( engine.enabled )
    {
        startButton.title = @"Stop";
    }
    else
    {
        startButton.title = @"Start";
    }
    
    [self updateStatusLabel];
    [self updateStorageLabels];
    [self reloadTable];
    
    // In YOUR app, you may wish to register a custom data source.  For our demo purposes, the default is sufficient
    // Register our test data source, which always returns the dilbert episode for download.
    //[[VirtuosoSubscriptionManager instance] registerDataSource:[TestDataSource class]];
}

/*
 *  Method called to query the User for the Backplane User ID to use.
 */
- (void)getUser
{
    [UIAlertView alertViewWithTitle:@"Virtuoso User Name?"
                            message:nil
                       textBoxQuery:@"User Name"
                        initialText:@""
                        secureEntry:NO
                       keyboardType:UIKeyboardTypeAlphabet
             autocapitalizationType:UITextAutocapitalizationTypeWords
                  cancelButtonTitle:nil
                  otherButtonTitles:@[@"OK"]
                          onDismiss:^(UIAlertView* alert, int buttonIndex)
     {
         NSString* user = [alert textFieldAtIndex:0].text;
         if( user != nil && [user stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 )
         {
             [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"TestHarnessUserName"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [self performSelector:@selector(finishStartup) withObject:nil afterDelay:0.5];
         }
         else
         {
             [self performSelector:@selector(getUser) withObject:nil afterDelay:0.5];
         }
     }
                           onCancel:^
     {
         
     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
     *  For the purposes of this demo, we're asking the User to enter the User ID.
     *
     *  While testing, the User ID can be any value you choose. The SDK and Backplane do not provide authentication.  A user that does not exist previously
     *  will be created on the Backplane.  It is expected that the Caller will have separate authentication performed via their own credentials and systems.
     */
    if( !hasStartedUp )
    {
        hasStartedUp = YES;
        if( [[NSUserDefaults standardUserDefaults] objectForKey:@"TestHarnessUserName"] == nil )
        {
            [self getUser];
        }
        else
        {
            [self finishStartup];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING!!");
}

/*
 *  Called when the User taps the Start/Stop button.  In this example, we retain state in the preferences
 *  to persist the Engine's enable state across application runs.
 */
- (void)doStart:(id)sender
{
    if( [startButton.title isEqualToString:@"Start"] )
    {
        startButton.title = @"Stop";
        [[VirtuosoDownloadEngine instance]setEnabled:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ClientEngineEnabledPreference"];
    }
    else
    {
        startButton.title = @"Start";
        [[VirtuosoDownloadEngine instance]setEnabled:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ClientEngineEnabledPreference"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doEdit:(id)sender
{
    self.tableView.editing = !self.tableView.editing;
    if( self.tableView.editing )
        editButton.title = @"Done";
    else
        editButton.title = @"Edit";
}

- (void)doSettings:(id)sender
{
    SettingsViewController* newView = [[SettingsViewController alloc]initWithNibName:@"SettingsView" bundle:nil];
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)displayAsset:(VirtuosoAsset*)asset inCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.textLabel.text = asset.description;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSDate* effectiveExpiry = asset.effectiveExpiryDate;
    
    // Only VirtuosoFile objects have detailed errors, since VirtuosoFileGroup objects have error status based on the summation
    // of their sub-files.  For convenience, information, and testing purposes, we'll go ahead and show the detailed error status
    // in the table, so Callers can see the Engine behavior based on file error state.
    NSString* errorAdd = @"";
    if( asset.downloadRetryCount > 0 )
    {
        errorAdd = [NSString stringWithFormat:@" (Errors: %i)",asset.downloadRetryCount];
    }
    
    // The Engine can handle downloads without knowing the expected size ahead of time.  How the asset's download status is reported changes
    // slightly if there is no expected size currently available.  To make sure we show data that makes sense based on the download status,
    // this example goes through several different options.  Depending on what you need to show in a production UI, this logic can be greatly
    // simplified.  As this is a demo intended to show utility of the SDK, Penthera has opted to show as much detail as possible to the User,
    // so the User can see what the SDK is doing in various asset configurations.
    double fractionComplete = asset.fractionComplete;
    kVDE_DownloadStatusType status = asset.status;
    
    if( asset.isExpired )
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Expired on %@",[df stringFromDate:effectiveExpiry]];
    }
    else if( indexPath.section == 0 && status == kVDE_DownloadNone )
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Deferred%@",errorAdd];
    }
    else if( fractionComplete == 0.0 && !asset.isExpired && status == kVDE_DownloadPending )
    {
        if( effectiveExpiry != nil )
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Waiting (Expires on %@)%@",[df stringFromDate:effectiveExpiry],errorAdd];
        }
        else
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Waiting%@",errorAdd];
        }
    }
    else if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
    {
        if( effectiveExpiry != nil )
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.02f%% (%qi MB) (Expires on %@)%@",fractionComplete*100.0,asset.currentSize/1024/1024,[df stringFromDate:effectiveExpiry],errorAdd];
        }
        else
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.02f%% (%qi MB)%@",fractionComplete*100.0,asset.currentSize/1024/1024,errorAdd];
        }
    }
    else
    {
        NSString* statusText = @"Complete";
        if( status == kVDE_DownloadProcessing )
        {
            statusText = @"Processing";
        }
        if( effectiveExpiry != nil )
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%qi MB) (Expires on: %@)",statusText,asset.currentSize/1024/1024,[df stringFromDate:effectiveExpiry]];
        }
        else
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%qi MB)",statusText,asset.currentSize/1024/1024];
        }
    }
}

/*
 *  Method called to update the table row for a specific asset.  This method identifies which section and row
 *  the item is in and updates that cell with the most recent data from the asset.
 */
- (void)updateRowForAsset:(VirtuosoAsset*)asset
{
    NSInteger index = NSNotFound;
    NSInteger section = 0;
    Boolean inQueue = NO;
    
    @try
    {
        index = [self.pendingAssets indexOfObject:asset];
        if( index != NSNotFound )
        {
            section = 0;
            inQueue = (asset.status!=kVDE_DownloadNone);
        }
        else
        {
            index = [self.completedAssets indexOfObject:asset];
            inQueue = NO;
            section = 1;
        }
    }
    @catch (NSException *exception)
    {
        // Something's adjusted our bookkeeping while we were busy updating the UI, so now the arrays are in an invalid state.  Reload
        // the whole table from scratch.
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadTable];
        });
        return;
    }
    
    if( index != NSNotFound )
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:section];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if( cell )
        {
            [self displayAsset:asset inCell:cell atIndexPath:indexPath];
        }
    }
}

/*
 *  Called by tapping the Add button on the toolbar
 */
- (void)doAddVideo:(id)sender
{
    AddNewItemViewController* newView = [[AddNewItemViewController alloc]initWithNibName:@"AddNewItemViewController" bundle:nil];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:newView];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( self.actionSheetCompleteBlock != nil )
    {
        UIActionSheetCompleteBlock block = self.actionSheetCompleteBlock;
        self.actionSheetCompleteBlock = nil;
        block(actionSheet,buttonIndex);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*
     *  In this example, we're going to have two sections.  The first for assets that have finished downloading, and the
     *  second for assets that have completed downloading.
     */
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
        return @"Pending Assets";
    
    return @"Complete Assets";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( ![[VirtuosoDownloadEngine instance]started] )
        return 0;
    
    // This may happen when we first startup.  Need to prime the data.
    if( self.pendingAssets == nil || self.completedAssets == nil )
    {
        if( [[VirtuosoDownloadEngine instance]started] )
        {
            self.pendingAssets = [[VirtuosoAsset pendingAssetsWithAvailabilityFilter:NO]mutableCopy];
            self.completedAssets = [[VirtuosoAsset completedAssetsWithAvailabilityFilter:NO]mutableCopy];
        }
    }
    
    if( section == 0 )
    {
        return self.pendingAssets.count;
    }
    
    return self.completedAssets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( cell == nil )
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Go and get the asset.
    VirtuosoAsset* asset = nil;
    
    @try
    {
        if( indexPath.section == 0 )
        {
            asset = [self.pendingAssets objectAtIndex:indexPath.row];
        }
        else
        {
            asset = [self.completedAssets objectAtIndex:indexPath.row];
        }
    }
    @catch (NSException *exception)
    {
        // Something's adjusted our bookkeeping while we were busy updating the UI, so now the arrays are in an invalid state.  Reload
        // the whole table from scratch.
        asset = nil;
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadTable];
        });
        return cell;
    }
    
    [self displayAsset:asset inCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source, we only allow edits on section 0
        
        VirtuosoAsset* asset = nil;
        
        @try
        {
            if( indexPath.section == 0 )
            {
                asset = [self.pendingAssets objectAtIndex:indexPath.row];
            }
            else
            {
                asset = [self.completedAssets objectAtIndex:indexPath.row];
            }
        }
        @catch (NSException *exception)
        {
            [self reloadTable];
            [self updateStorageLabels];
            [self updateStatusLabel];
            return;
        }
        
        if( asset )
        {
            [asset deleteAssetOnComplete:^
             {
                 @try
                 {
                     if( indexPath.section == 0 )
                         [self.pendingAssets removeObjectAtIndex:indexPath.row];
                     else
                         [self.completedAssets removeObjectAtIndex:indexPath.row];
                     
                     [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                     [self updateStorageLabels];
                     [self updateStatusLabel];
                 }
                 @catch (NSException *exception)
                 {
                     [self reloadTable];
                     [self updateStorageLabels];
                     [self updateStatusLabel];
                 }
             }];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if( destinationIndexPath.section != 0 || sourceIndexPath.section != 0 )
    {
        [self reloadTable];
        return;
    }
    
    @try
    {
        
        VirtuosoAsset* asset = [self.pendingAssets objectAtIndex:sourceIndexPath.row];
        [self.pendingAssets removeObjectAtIndex:sourceIndexPath.row];
        [[VirtuosoDownloadEngine instance] moveAsset:asset inQueueToIndex:destinationIndexPath.row];
        [self.pendingAssets insertObject:asset atIndex:destinationIndexPath.row];
    }
    @catch (NSException *exception)
    {
        [self reloadTable];
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only permit movement of items in the queue.
    if( indexPath.section == 0 )
        return YES;
    
    return NO;
}

#pragma mark - Table view delegate

- (void)moviePlaybackProgress
{
}

- (void)playAsset:(VirtuosoAsset*)asset fromIndexPath:(NSIndexPath*)indexPath fromMainVid:(Boolean)fromMain
{
    if( [asset isPlayable] )
    {
        if( asset.type == kVDE_AssetTypeNonSegmented )
        {
            self.player = [VirtuosoMoviePlayerViewController playerForAssetType:asset.type];
            self.playingAsset = asset;
            self.secondsAtPlaybackStart = -1;
            
            [asset playUsingPlaybackType:kVDE_AssetPlaybackTypeLocal andPlayer:(id<VirtuosoPlayer>)self.player
             
                         onSuccess:^
             {
                 // Present the player
                 [self presentViewController:self.player animated:YES completion:nil];
                 
                 // We need to set the playback date here.  Don't log it.  We'll use the movie player controller events for that.
                 [asset setFirstPlayDateTime:[NSDate date]];
                 [asset save];
             }
             
                            onFail:^
             {
                 self.playingAsset = nil;
                 [self showErrorForAsset:asset atIndexPath:indexPath];
             }];
        }
        else if( (asset.type == kVDE_AssetTypeHLS && asset.assetProtectionType != kVDE_AssetProtectionTypeDrmCisco) ||
                 asset.type == kVDE_AssetTypeDASH )
        {
            [UIAlertView alertViewWithTitle:@"Play Video"
                                    message:@""
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@[@"Open Web Server",@"Play Locally"]
                                  onDismiss:^(UIAlertView* alert, int buttonIndex) {
                                      if( buttonIndex == 0 )
                                      {
                                          // We need to set the playback date here.  Don't log it.  We'll use the movie player controller events for that.
                                          [asset setFirstPlayDateTime:[NSDate date]];
                                          [asset save];
                                          
                                          self.secondsAtPlaybackStart = -1;
                                          self.playingAsset = asset;
                                          NSDate* startDate = [NSDate date];
                                          
                                          [VirtuosoLogger logPlaybackStartedForAsset:asset];
                                          
                                          self.playerProxy = [[VirtuosoClientHTTPServer alloc]initWithAsset:asset withOpenInterface:YES];
                                          
                                          NSString* playURL = self.playerProxy.playbackURL;
                                          NSString* myIP = [self getIPAddress:YES];
                                          playURL = [playURL stringByReplacingOccurrencesOfString:@"127.0.0.1" withString:myIP];
                                          
                                          NSLog(@"Proxy Playback URL: %@",playURL);
                                          [UIAlertView alertViewWithTitle:@"Asset Playback"
                                                                  message:[NSString stringWithFormat:@"Proxy will be open until you close this alert.  Playback URL: %@",playURL]
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil
                                                                onDismiss:^(UIAlertView* alert, int buttonIndex) {
                                                                    [VirtuosoLogger logPlaybackStoppedForAsset:asset withSecondsSinceLastStart:(long long)fabs([startDate timeIntervalSince1970])];
                                                                    [self.playerProxy shutdown];
                                                                    self.playerProxy = nil;
                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kMoviePlayerDidExitNotification object:nil];
                                                                } onCancel:^{
                                                                    [VirtuosoLogger logPlaybackStoppedForAsset:asset withSecondsSinceLastStart:(long long)fabs([startDate timeIntervalSince1970])];
                                                                    [self.playerProxy shutdown];
                                                                    self.playerProxy = nil;
                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kMoviePlayerDidExitNotification object:nil];
                                                                }];
                                      }
                                      else
                                      {
                                          self.player = [VirtuosoMoviePlayerViewController playerForAssetType:asset.type];
                                          self.secondsAtPlaybackStart = -1;
                                          self.playingAsset = asset;
                                          
                                          [asset playUsingPlaybackType:kVDE_AssetPlaybackTypeLocal andPlayer:(id<VirtuosoPlayer>)self.player
                                           
                                                       onSuccess:^
                                           {
                                               // Present the player
                                               [self presentViewController:self.player animated:YES completion:nil];
                                               
                                               [asset setFirstPlayDateTime:[NSDate date]];
                                               [asset save];
                                           }
                                           
                                                          onFail:^
                                           {
                                               self.playingAsset = nil;
                                               [self showErrorForAsset:asset atIndexPath:indexPath];
                                           }];
                                      }
                                  }
                                   onCancel:^{
                                       
                                   }];
        }
        else if( asset.type == kVDE_AssetTypeHLS && asset.assetProtectionType == kVDE_AssetProtectionTypeDrmCisco )
        {
            self.player = [VirtuosoMoviePlayerViewController playerForAssetType:asset.type];
            self.secondsAtPlaybackStart = -1;
            self.playingAsset = asset;
            
            [asset playUsingPlaybackType:kVDE_AssetPlaybackTypeLocal andPlayer:(id<VirtuosoPlayer>)self.player
             
                         onSuccess:^
             {
                 // Present the player
                 [self presentViewController:self.player animated:YES completion:nil];
                 
                 [asset setFirstPlayDateTime:[NSDate date]];
                 [asset save];
             }
             
                            onFail:^
             {
                 self.playingAsset = nil;
                 [self showErrorForAsset:asset atIndexPath:indexPath];
             }];
        }
        else if( asset.type == kVDE_AssetTypeHSS )
        {
            // We can't playback HSS in a native player, so we're just going to startup a proxy server for this and tell the
            // user what the playback URL is.  We're shortcutting a lot of capabiltiy here to "mock up" what would happen if
            // a native player existed.  You can use several online HSS players and the playback URL output in the popup to
            // test playback.
            
            // We need to set the playback date here.  Don't log it.  We'll use the movie player controller events for that.
            [asset setFirstPlayDateTime:[NSDate date]];
            [asset save];
            
            self.secondsAtPlaybackStart = -1;
            self.playingAsset = asset;
            NSDate* startDate = [NSDate date];
            
            [VirtuosoLogger logPlaybackStartedForAsset:asset];
            
            self.playerProxy = [[VirtuosoClientHTTPServer alloc]initWithAsset:asset withOpenInterface:YES];
            
            NSString* playURL = self.playerProxy.playbackURL;
            NSString* myIP = [self getIPAddress:YES];
            playURL = [playURL stringByReplacingOccurrencesOfString:@"127.0.0.1" withString:myIP];
            
            NSLog(@"Proxy Playback URL: %@",playURL);
            
            [UIAlertView alertViewWithTitle:@"HSS Playback"
                                    message:[NSString stringWithFormat:@"Proxy will be open until you close this alert.  Playback URL: %@",playURL]
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil
                                  onDismiss:^(UIAlertView* alert, int buttonIndex) {
                                      [VirtuosoLogger logPlaybackStoppedForAsset:asset withSecondsSinceLastStart:(long long)fabs([startDate timeIntervalSince1970])];
                                      [self.playerProxy shutdown];
                                      self.playerProxy = nil;
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kMoviePlayerDidExitNotification object:nil];
                                  } onCancel:^{
                                      [VirtuosoLogger logPlaybackStoppedForAsset:asset withSecondsSinceLastStart:(long long)fabs([startDate timeIntervalSince1970])];
                                      [self.playerProxy shutdown];
                                      self.playerProxy = nil;
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kMoviePlayerDidExitNotification object:nil];
                                  }];
        }
    }
    else
    {
        [self showErrorForAsset:asset atIndexPath:indexPath];
    }
}

- (void)showErrorForAsset:(VirtuosoAsset*)asset atIndexPath:(NSIndexPath*)indexPath
{
    if( asset.isExpired )
    {
        [self reloadTable];
        [[[UIAlertView alloc]initWithTitle:@"Expired Asset"
                                   message:@"The item you've selected has expired."
                                  delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    else if( !asset.isWithinViewingWindow )
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [[[UIAlertView alloc]initWithTitle:@"Not Available Yet"
                                   message:@"The item you've selected has not passed its publish time.  Please wait and try again later."
                                  delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Not Playable"
                                   message:@"The item you've selected is not playable."
                                  delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if( indexPath.section == 0 )
    {
        VirtuosoAsset* asset = [self.pendingAssets objectAtIndex:indexPath.row];
        Boolean inQueue = (asset.status != kVDE_DownloadNone);
        
        if( !inQueue )
        {
            // The item is deferred.  It may have been reset or it may have gotten synced in a subscription that doesn't allow
            // auto-delete.  Whatever the case, for the purposes of this demo, we won't permit playback (although we could).  Just
            // ask the user if they'd like to add the item to the download queue.
            UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Action"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Add To Download Queue", nil];
            self.actionSheetCompleteBlock = ^(UIActionSheet* actionSheet, NSInteger buttonIndex) {
                if( buttonIndex != actionSheet.cancelButtonIndex )
                    [[VirtuosoDownloadEngine instance] addToQueue:asset atIndex:NSUIntegerMax onComplete:nil];
            };
            [sheet showInView:self.view];
            return;
        }
        
        // Section 0 is for undownloaded assets.  In this demo, we dissallow progressive download-based playback of MP4 files, as
        // this is the most common use case.  If the asset is an HLS file group and has a manifest, then we can do direct
        // playback, regardless of the download state.  The SDK will automatically handle the manifest file and redirect the player
        // to locally downloaded asset where possible, seamlessly transitioning to remote online asset when needed.  We can't play
        // HSS streams using the native player.
        __weak ViewController* weakSelf = self;
        if( asset.type != kVDE_AssetTypeHSS && asset.assetProtectionType != kVDE_AssetProtectionTypeDrmCisco )
        {
            UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Action"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Play Video", @"Reset Errors", nil];
            self.actionSheetCompleteBlock = ^(UIActionSheet* actionSheet, NSInteger buttonIndex) {
                if( buttonIndex == actionSheet.cancelButtonIndex )
                    return;
                
                if( [[actionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:@"Play Video"] )
                {
                    [weakSelf playAsset:asset fromIndexPath:indexPath fromMainVid:NO];
                }
                else
                {
                    [asset clearRetryCountOnComplete:^{
                        
                    }];
                }
            };
            [sheet showInView:self.view];
        }
        else
        {
            UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Action"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Reset Errors", nil];
            self.actionSheetCompleteBlock = ^(UIActionSheet* actionSheet, NSInteger buttonIndex) {
                if( buttonIndex == actionSheet.cancelButtonIndex )
                    return;
                
                [asset clearRetryCountOnComplete:^{
                    
                }];
            };
            [sheet showInView:self.view];
        }
    }
    if( indexPath.section == 1 )
    {
        // Section 1 is for downloaded asset, so we should be able to playback everything, as long as the asset is not expired, is within the viewing window,
        // and the Backplane is not in a timed out state.
        VirtuosoAsset* asset = [self.completedAssets objectAtIndex:indexPath.row];
        [self playAsset:asset fromIndexPath:indexPath fromMainVid:NO];
    }
}

@end
