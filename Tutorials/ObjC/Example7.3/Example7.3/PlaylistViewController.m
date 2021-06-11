//
//  PlaylistViewController.m
//  Example7
//
//  Created by Penthera on 3/3/21.
//

#import "PlaylistViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

@interface PlaylistViewController () <VirtuosoDownloadEngineNotificationsDelegate>

@property (nonatomic, strong)VirtuosoDownloadEngineNotificationManager* notificationManager;


@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;

    self.notificationManager = [[VirtuosoDownloadEngineNotificationManager alloc]initWithDelegate:self];
    [self refreshView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlist.items.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;

    VirtuosoPlaylistItem* item = [self.playlist.items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.assetID;
    NSMutableString* sb = [NSMutableString new];
    
    [sb appendFormat:@"Status: %@\n", [VirtuosoPlaylistItem statusAsString:item.itemState]];
    
    if (item.downloadComplete)
    {
        [sb appendFormat:@"Downloaded: yes %@\n", [formatter stringFromDate:item.downloadComplete]];
    }
    else
    {
        [sb appendString:@"Downloaded: no:\n"];
    }
    if (item.playbackDate)
    {
        [sb appendFormat:@"Playback: yes %@\n", [formatter stringFromDate:item.playbackDate]];
    }
    else
    {
        [sb appendString:@"Playback: no:\n"];
    }

    [sb appendFormat:@"Expired: %@\n", item.expired ? @"yes" : @"no"];
    [sb appendFormat:@"Pending Now: %@\n", item.pending ? @"yes" : @"no"];
    
    cell.detailTextLabel.text = sb;
    
    return cell;
}

-(void)addClicked
{
    VirtuosoPlaylist* playlist = self.playlist;
    
    if (!playlist) return;
    
    if (playlist.items.count >= 2 && playlist.items.count < 6)
    {
        NSString* episode = [NSString stringWithFormat:@"SERIES-8-EPISODE-%@", @(playlist.items.count + 1)];
        if ([playlist contains:episode])
        {
            return;
        }
        
        NSError* error = nil;
        [playlist append:[NSArray arrayWithObject:episode] error:&error];
        if (error)
        {
            VLog(kVL_LogError, "Error while appending to playlist: %@  error: %@",
                 playlist.name,
                 error.localizedDescription);
        }
        
        [self refreshView];
    }
}

-(void)refreshView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        VirtuosoPlaylist*  playlist = [VirtuosoPlaylist find:self.playlist.name];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playlist = playlist;
            [self.tableView reloadData];

            if (self.playlist.items.count < 6)
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addClicked)];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
            }
        });
    });
}


- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset * _Nonnull)asset {
    [self refreshView];
}

- (void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset * _Nonnull)asset {
    [self refreshView];
}

- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset * _Nonnull)asset {
    [self refreshView];
}

- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset {
    [self refreshView];
}

-(void)playlistChange:(VirtuosoPlaylist *)playlist
{
    [self refreshView];
}

@end
