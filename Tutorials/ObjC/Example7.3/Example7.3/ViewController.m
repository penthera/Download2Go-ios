//
//  ViewController.m
//  Example7.3
//
//  Created by Penthera on 3/3/21.
//

#import "ViewController.h"
#import "DemoPlayerViewController.h"
#import "PlaylistViewController.h"

static NSString* PlaylistName = @"TESTQUEUE-8";


// ---------------------------------------------------------------------------------------------------------
// IMPORTANT:
// The following three values must be initialzied, please contact support@penthera.com to obtain these keys
// ---------------------------------------------------------------------------------------------------------
static NSString* backplaneUrl = @"replace_with_your_backplane_url";                                         // <-- change this
static NSString* publicKey = @"replace_with_your_public_key";   // <-- change this
static NSString* privateKey = @"replace_with_your_private_key";  // <-- change this

@interface ViewController () <VirtuosoDownloadEngineNotificationsDelegate>

//
// MARK: Instance data
//
@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong)NSMutableArray* assets;
@property (nonatomic, strong)VirtuosoPlaylist* playlist;
@property (nonatomic, strong)NSOperationQueue* loadQueue;
@property (nonatomic, assign)Boolean assetsDeleted;
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

    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc]initWithTitle:@"Reset"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(resetClicked)];
    
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc]initWithTitle:@"Add"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(addClicked)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;

    self.loadQueue = [NSOperationQueue new];
    self.loadQueue.maxConcurrentOperationCount = 1;
    self.loadQueue.qualityOfService = NSQualityOfServiceUtility;
    
    self.assets = [NSMutableArray new];
    [self startup];
}

//
// MARK: TableView Delegate and Data
//
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assets.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    
    VirtuosoAsset* asset = [self.assets objectAtIndex:indexPath.row];
    cell.textLabel.text = asset.assetID;
    
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;

    NSMutableString* sb = [NSMutableString new];
    if (asset.fastPlayEnabled)
    {
        [sb appendString:@"FastPlay Enabled\n"];
    }
    if (asset.fastPlayReady)
    {
        [sb appendString:@"FastPlay Ready\n"];
    }
    cell.detailTextLabel.text = sb;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VirtuosoAsset* asset = [self.assets objectAtIndex:indexPath.row];
    
    if (asset)
    {
        [self playAsset:asset];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

//
// MARK: Internal methods
//

-(void)startup
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearData];
        
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
                [self createInitialAsset];
            } else {
                NSLog(@"Startup encountered error.");
            }
        }];
    });
}

-(void)resetClicked
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshView];
        });
    });
}

-(void)addClicked
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlaylistViewController* view = [storyboard instantiateViewControllerWithIdentifier:@"PlaylistViewController"];
    view.playlist = [VirtuosoPlaylist find:PlaylistName];
    [self.navigationController pushViewController:view animated:true];
    
}

-(void)clearData
{
    NSAssert(![NSThread isMainThread], @"This method should not be called on MainThread");
    
    // Blow away existing Playlist, this needs to happen
    // before we remove the assets.
    [VirtuosoPlaylist clear:PlaylistName];
    
    self.playlist = nil;

    // Remove all assets
    self.assetsDeleted = false;
    [VirtuosoAsset deleteAll];
    
    // Wait for delete to complete
    while(!self.assetsDeleted)
    {
        [NSThread sleepForTimeInterval:1];
    }
    
    // Create demo Playlist
    if (![self initializeData]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Initialization error"
                                                                           message:@"Check logs for reason."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                return;
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:TRUE completion:nil];

        });

        return;
    }
    // create initial asset
    if (VirtuosoDownloadEngine.instance.started) {
        [self createInitialAsset];
    }
    [self loadData];
}

-(void)refreshView
{
    if (self.playlist.items.count < 6)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addClicked)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc]initWithTitle:@"Browse"
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(addClicked)];
    }
}

-(Boolean)initializeData
{
    NSError* error = nil;
    
    VirtuosoPlaylistConfig* playlistConfig = [[VirtuosoPlaylistConfig alloc]initWithName:PlaylistName
                                                                            playlistType:kVDE_PlaylistType_FastPlay
                                                                                   error:&error];
    if (error)
    {
        VLog(kVL_LogError, @"Failed to create PlaylistConfig. Error: %@", error.localizedDescription);
        return false;
    }
    
    // Create Playlist
    NSArray* assets = @[@"SERIES-8-EPISODE-1",
                        @"SERIES-8-EPISODE-2",
                        @"SERIES-8-EPISODE-3",
                        @"SERIES-8-EPISODE-4",
                        @"SERIES-8-EPISODE-5",
                        @"SERIES-8-EPISODE-6"];
    
    
    error = nil;
    self.playlist = [VirtuosoPlaylist create:playlistConfig withAssets:assets error:&error];
    if (error)
    {
        VLog(kVL_LogError, @"Failed to create Playlist. Error: %@", error.localizedDescription);
        return false;
    }
    
    [self loadData];
    return TRUE;
}

-(void)createInitialAsset
{
    VirtuosoAssetConfig* config = [[VirtuosoAssetConfig alloc]initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep1/index.m3u8"
                                                                  assetID:@"SERIES-8-EPISODE-1"
                                                              description:@"Sample Description"
                                                                     type:kVDE_AssetTypeHLS];
    if (!config) {
        NSLog(@"VirtuosoAssetConfig create failed.");
        return;
    }
    
    // Configure asset for FastPlay
    config.fastPlayEnabled = true;
    config.offlinePlayEnabled = false;
    config.autoAddToQueue = false;
    
    // Create the asset
    [VirtuosoAsset assetWithConfig:config];
}


- (void)playAsset:(VirtuosoAsset*)asset
{
    [VirtuosoAsset isPlayable:asset callback:^(Boolean playable) {
        if( playable )
        {
            if( asset.type != kVDE_AssetTypeHSS )
            {
                UIViewController* player = [DemoPlayerViewController new];
                
                //
                // Playback FastPlay
                //
                [asset playUsingPlaybackType:kVDE_AssetPlaybackTypeFastPlay
                                   andPlayer:(id<VirtuosoPlayer>)player
                                   onSuccess:^ {
                                       // Present the player
                                       [self presentViewController:player animated:YES completion:nil];
                                   }
                                      onFail:^ {
                                          NSLog(@"Can't play video!");
                                      }];
            }
        }
    }];
}

-(void)loadData
{
    [self.loadQueue addOperationWithBlock:^{
        [self internalLoadData];
    }];
}

- (void)internalLoadData
{
    //
    // Invoked on background thread to prevent blocking UI updates
    //
    if( [[VirtuosoDownloadEngine instance]started] )
    {
        NSArray* assets = [VirtuosoAsset assetsWithAvailabilityFilter:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.assets removeAllObjects];
            [self.assets addObjectsFromArray:assets];
            [self.assets sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                VirtuosoAsset* asset1 = (VirtuosoAsset*)obj1;
                VirtuosoAsset* asset2 = (VirtuosoAsset*)obj2;
                return [asset1.assetID compare:asset2.assetID];
            }];
            
            [self.tableView reloadData];
            [self refreshView];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // Try again in 5 seconds
            [self loadData];
        });
    }
}

//
// MARK: VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY
//

// ------------------------------------------------------------------------------------------------------------
//  Called whenever the Engine starts downloading a VirtuosoAsset object.
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self loadData];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports progress for a VirtuosoAsset object
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self loadData];
}

// ------------------------------------------------------------------------------------------------------------
// Called when an asset is being processed after background transfer
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self loadData];
}

// ------------------------------------------------------------------------------------------------------------
// Called whenever the Engine reports a VirtuosoAsset as complete
// ------------------------------------------------------------------------------------------------------------
- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self loadData];
}

- (void)downloadEngineDidEncounterErrorForAsset:(VirtuosoAsset *)asset error:(NSError *)error task:(NSURLSessionTask *)task data:(NSData *)data statusCode:(NSNumber *)statusCode
{
    [self loadData];
}

- (void)downloadEngineInternalQueueUpdate {
    [self loadData];
}

// ------------------------------------------------------------------------------------------------------------
// Called when Engine start is complete
// ------------------------------------------------------------------------------------------------------------
-(void)downloadEngineStartupComplete:(Boolean)succeeded
{
    [self loadData];
}

-(void)downloadEngineAssetsDeleted:(NSArray<NSString *> *)deletedAssetIDs
{
    [self loadData];
}

-(void)downloadEngineAllAssetsDeleted
{
    self.assetsDeleted = true;
    [self loadData];
}

-(void)downloadEngineDeletedAssetId:(NSString *)assetID
{
    [self loadData];
}

-(void)playlistChange:(VirtuosoPlaylist *)playlist
{
    [self loadData];
}

-(void)downloadEngineFastPlayAssetReady:(VirtuosoAsset *)asset {
    [self loadData];
}
@end
