//
//  ViewController.m
//  Example16
//
//  Created by Penthera on 10/8/20.
//

#import "ViewController.h"
#import "StreamAssuredPlayer.h"

#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialized, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* backplaneUrl = @"https://qa.penthera.com"; // <-- change this
static NSString* publicKey = @"c9adba5e6ceeed7d7a5bfc9ac24197971bbb4b2c34813dd5c674061a961a899e";       // <-- change this
static NSString* privateKey = @"41cc269275e04dcb4f2527b0af6e0ea11d227319fa743e4364255d07d7ed2830";     // <-- change this

@interface ViewController ()

#pragma mark - Instance data

@property (nonatomic, strong) NSArray<NSDictionary<NSString*, NSString*>*>* manifestURLs;

@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;

#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet UIPickerView *manifestPickerView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.manifestPickerView.delegate = self;
    self.manifestPickerView.dataSource = self;
    
    [self loadManifestURLs];    
    
    [self.manifestPickerView selectRow:0 inComponent:0 animated:YES];
    
    self.urlLabel.text = [self.manifestURLs[0] objectForKey:@"url"];
    
    // download engine update listener
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
        
    // Enable the engine
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
    
    // We'll use a notification to kick off our player in order to give the StreamAssured Manager
    // time to start up.
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playStreamAssuredNotification:) name:@"Tutorial_PlayStreamAssured" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Picker View

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < self.manifestURLs.count)
    {
        self.urlLabel.text = [self.manifestURLs[row] objectForKey:@"url"];
        
        return [self.manifestURLs[row] objectForKey:@"name"];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row < self.manifestURLs.count)
    {
        self.urlLabel.text = [self.manifestURLs[row] objectForKey:@"url"];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel* updatedView = ((UILabel*)view);
    
    if (!updatedView)
    {
        updatedView = [[UILabel alloc] init];
    
        updatedView.font = [UIFont systemFontOfSize:12.0];
        
        updatedView.textAlignment = NSTextAlignmentCenter;
    }
    
    updatedView.text =  [self.manifestURLs[row] objectForKey:@"name"];
    
    return updatedView;
}


#pragma mark - Picker View Data Source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.manifestURLs.count;
}

#pragma mark - Actions

- (IBAction)playURL:(id)sender {
    
    [NSNotificationCenter.defaultCenter postNotificationName:@"Tutorial_PlayStreamAssured" object:self.urlLabel.text];
}

#pragma mark - Local methods

-(void)loadManifestURLs
{
    if (!self.manifestURLs)
    {
        // NOTE: A random collection of assets to test and play around with.  This list of assets will probably
        //       need to be updated or removed completely before this tutorial goes into production.
        
        self.manifestURLs = @[@{@"name":@"How To Train Your Dragon HLS Relative URLs", @"url":@"http://hls-vbcp.s3.amazonaws.com/httyd_rel.m3u8"},
                              @{@"name":@"Iron Man 2 HLS Relative URLs", @"url":@"http://hls-vbcp.s3.amazonaws.com/im2_rel.m3u8"},
                              @{@"name":@"True Blood HLS Encrypted Absolute URLs", @"url":@"http://hls-vbcp.s3.amazonaws.com/tb_enc.m3u8"},
                              @{@"name":@"Basic CC Test", @"url":@"http://hls-vbcp.s3.amazonaws.com/cc_test/a.m3u8"},
                              @{@"name":@"CBS Codec+IFrames (Dolby Digital Audio ac3)", @"url":@"http://hls-vbcp.s3.amazonaws.com/cbs/multi-codec-test/Manifest-CnC.m3u8"},
                              @{@"name":@"Chappie HD (361 Seg)", @"url":@"http://hls-vbcp.s3.amazonaws.com/chappie/chappie_twenty_sec/prog_index.m3u8"},
                              @{@"name":@"Kung Fu Dragon 512 Kbps (5177 Seg)", @"url":@"http://hls-vbcp.s3.amazonaws.com/dragon_one_sec/prog_index.m3u8"},
                              @{@"name":@"Lady Frankenstein 128 Kbps (503 Seg)", @"url":@"http://hls-vbcp.s3.amazonaws.com/frankenstein_ten_sec/prog_index.m3u8"}];
    }
}

-(void)playStreamAssuredNotification:(NSNotification*)notice
{
    NSString* manifestURL = notice.object;

    if (manifestURL && [manifestURL isKindOfClass:[NSString class]])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self playStreamAssured:manifestURL];
        });
    }
}

-(void)playStreamAssured:(NSString*)manifestURL
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    StreamAssuredPlayer* view  = [sb instantiateViewControllerWithIdentifier:@"StreamAssuredPlayer"];

    view.manifestURL = manifestURL;

    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY

// ------------------------------------------------------------------------------------------------------------
//  Called whenever the Engine starts downloading a VirtuosoAsset object.
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    return;
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports progress for a VirtuosoAsset object
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset * _Nonnull)asset
{
    return;
}

// ------------------------------------------------------------------------------------------------------------
// Called when an asset is being processed after background transfer
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset
{
    return;
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports a VirtuosoAsset as complete
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    return;
}

// ------------------------------------------------------------------------------------------------------------
// Called when Engine start is complete
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineStartupComplete:(Boolean)succeeded {
    NSLog(@"Download Engine Startup Completed: %@", succeeded ? @"Yes" : @"No");
}

@end
