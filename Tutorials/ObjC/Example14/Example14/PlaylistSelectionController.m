//
//  PlaylistSelectionController.m
//  Example7
//
//  Created by Penthera on 7/15/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "PlaylistSelectionController.h"
#import "PlaylistViewController.h"

@interface PlaylistSelectionController ()

@property(nonatomic, strong) NSArray<VirtuosoPlaylist *>* playlists;

@end

@implementation PlaylistSelectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.playlists = [VirtuosoPlaylistManager.instance findAllItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.playlists)
    {
        return self.playlists.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell" forIndexPath:indexPath];
    
    VirtuosoPlaylist* playlist = self.playlists[indexPath.row];
    cell.textLabel.text = playlist.name;
    NSMutableString* detailText = [NSMutableString stringWithFormat:@"%lu items\n", (unsigned long)playlist.items.count];
    [detailText appendFormat:@"Status: %@\n", playlist.statusAsString];
    [detailText appendFormat:@"Playback required: %@\n", playlist.isPlaybackRequired ? @"yes" : @"no"];
    [detailText appendFormat:@"Pending count: %@\n", @(playlist.pendingCount)];
    [detailText appendFormat:@"Asset History considered: %@\n", playlist.isAssetHistoryConsidered ? @"yes" : @"no"];
    [detailText appendFormat:@"Search from beginning: %@\n", playlist.isSearchFromBeginningEnabled ? @"yes" : @"no"];
    
    cell.detailTextLabel.text = detailText;
    if (playlist.items.count > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PlaylistViewController* view = (PlaylistViewController*)segue.destinationViewController;
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    VirtuosoPlaylist* playlist = self.playlists[indexPath.row];
    view.playlist = playlist;
    
}

@end
