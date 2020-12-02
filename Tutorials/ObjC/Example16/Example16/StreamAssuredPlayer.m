//
//  StreamAssuredPlayer.m
//  VirtuosoClientEngineDemo
//
//  Created by dev on 7/24/20.
//

#import "StreamAssuredPlayer.h"
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

#import "MBProgressHUD.h"

static void *StreamAssurePlayerTimeControlStatusObservationContext = &StreamAssurePlayerTimeControlStatusObservationContext;

@interface StreamAssuredPlayer ()

@property (nonatomic, strong)AVPlayerViewController* playerVC;
@property (nonatomic, strong)StreamAssuredManager* sam;
@property (nonatomic, strong)MBProgressHUD* startupHUD;
@property (nonatomic, assign)Boolean started;
@property (atomic, assign)Boolean isStopped;
@property (atomic, assign)Boolean isRestartedPlayback;

@end

@implementation StreamAssuredPlayer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    // This button simply hides the back button which is defaulted for pushed views
    //
    UIBarButtonItem* hide =  [[UIBarButtonItem alloc]initWithTitle:@""
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(playStreamAssured)];

    self.navigationItem.leftBarButtonItem = hide;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.started)
    {
        [self stopPlayback];
    }
    else {
        [self playStreamAssured];
    }
}

// MARK: - Local methods

-(void)playStreamAssured
{
    if (self.playerVC)
    {
        return;
    }
    
    self.startupHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.startupHUD.labelText = @"Starting SAM";

    [StreamAssuredManager isNetworkReady:^(Boolean success) {
        
        [self.startupHUD hide:TRUE];
        self.startupHUD = nil;

        if (!success)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Unreachable" message:@"Unable to initialize SAM while Network is unreachable." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self stopPlayback];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:TRUE completion:nil];
            return;
        }
        
        NSError* error = nil;
        self.sam = [[StreamAssuredManager alloc]initWithManifestURL:self.manifestURL config:[StreamAssuredConfig new] error:&error];
        if (!self.sam)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"SAM Error" message:[NSString stringWithFormat:@"SAM Failed to initialize. %@ Check logs.", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self stopPlayback];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:TRUE completion:nil];
            return;
        }
        
        [self startPlayback];
        return;
    }];
    
}

-(void)stopPlayback
{
    [self.playerVC.player pause];
    
    @try
    {
        [self.playerVC.player removeObserver:self forKeyPath:@"timeControlStatus"];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Unexpected exception removing observer: %@", exception);
    }
    
    self.playerVC.player = nil;
    self.playerVC = nil;
    [self.sam shutdown];
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

-(void)startPlayback
{
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startPlayback];
        });
        return;
    }
    
    if (!self.playerVC) {
        //
        // Initial creation of the view
        //
        self.playerVC =  [[AVPlayerViewController alloc]init];
        self.playerVC.player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:self.sam.streamingURL]];
                
        [self.playerVC.player addObserver:self
                               forKeyPath:@"timeControlStatus"
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:StreamAssurePlayerTimeControlStatusObservationContext];
        
        [self presentViewController:self.playerVC  animated:TRUE completion:^{
            [self.playerVC.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                [self.playerVC.player play];
                self.started = true;
            }];
        }];
    }
    else
    {
        //
        // Refresh of the view following playback stall
        //
        
        @try
        {
            [self.playerVC.player removeObserver:self forKeyPath:@"timeControlStatus"];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Unexpected exception removing observer: %@", exception);
        }
                
        CMTime currentTime = self.playerVC.player.currentTime;
        
        self.playerVC.player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:self.sam.streamingURL]];
        
        [self.playerVC.player addObserver:self
                               forKeyPath:@"timeControlStatus"
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:StreamAssurePlayerTimeControlStatusObservationContext];
        
        [self.playerVC.player seekToTime:currentTime completionHandler:^(BOOL finished) {
            [self.playerVC.player play];
            self.started = true;
        }];
    }
    
    return;
}

-(void) restartPlayback
{
    __weak StreamAssuredPlayer* weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if (!weakSelf)
        {
            return;
        }
        
        if (weakSelf.isStopped)
        {
            return;
        }
        
        if (weakSelf.playerVC.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate)
        {
            if (weakSelf.isRestartedPlayback)
            {
                [weakSelf restartPlayback];
             
                return;
            }
            
            NSLog(@"Asset playback stalled. Waiting for Network connection to restart playback. manifestURL: %@", weakSelf.manifestURL);
            
            // Playback has stalled.
            // Restart playback once the network is ready.
            [StreamAssuredManager isNetworkReady:^(Boolean success) {
                if (success)
                {
                    weakSelf.isRestartedPlayback = true;
                    NSLog(@"Attempting playback restart following stalled playback. manifestURL: %@", self.manifestURL);
                    [weakSelf startPlayback]; // Attempt to play
                    [weakSelf restartPlayback];
                }
                else
                {
                    [weakSelf restartPlayback];
                }
            }];
        }
        else
        {
            if (weakSelf.isRestartedPlayback)
            {
                weakSelf.isRestartedPlayback = false;
            
                NSLog(@"Successfully restarted player following stall. manifestURL: %@", self.manifestURL);
            }
            else
            {
                NSLog(@"Restart requested, but player recovered without restarting. manifestURL: %@", self.manifestURL);
            }
        }
    });
}

#pragma mark - KVO to handle stalling

- (void)observeValueForKeyPath:(NSString *)path
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == StreamAssurePlayerTimeControlStatusObservationContext)
    {
        if ([path isEqualToString:@"timeControlStatus"])
        {
            AVPlayerTimeControlStatus timeControlStatus = (long)((AVPlayer*)object).timeControlStatus;
            
            NSLog(@"AVPlayer Time Control Status Update: %ld, SAM Player started: %d", (long)((AVPlayer*)object).timeControlStatus, (int)self.started);
            
            if (self.started && timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate)
            {
                [self restartPlayback];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

@end
