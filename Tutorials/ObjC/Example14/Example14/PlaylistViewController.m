//
//  PlaylistViewController.m
//  Example7
//
//  Created by Penthera on 7/15/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "PlaylistViewController.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.playlist.items.count)
    {
        return self.playlist.items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell" forIndexPath:indexPath];
    
    VirtuosoPlaylistItem* playlistItem = [self.playlist.items objectAtIndex:indexPath.row];
    cell.textLabel.text = playlistItem.assetID;
    
    NSMutableString* textDetail = [[NSMutableString alloc]init];
    [textDetail appendFormat:@"Status: %@\n", [VirtuosoPlaylistItem statusAsString:playlistItem.itemState]];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    if (playlistItem.downloadComplete)
    {
        [textDetail appendFormat:@"Download: yes %@\n", [dateFormatter stringFromDate:playlistItem.downloadComplete]];
    }
    else
    {
        [textDetail appendString:@"Download: no\n"];
    }
    
    [textDetail appendFormat:@"Deleted: %@\n", playlistItem.userDeleted ? @"yes" : @"no"];
    
    if (playlistItem.playbackDate)
    {
        [textDetail appendFormat:@"Playback: yes %@\n", [dateFormatter stringFromDate:playlistItem.playbackDate]];
    }
    else
    {
        [textDetail appendString:@"Playback: no\n"];
    }
    [textDetail appendFormat:@"Pending now: %@\n", playlistItem.pending ? @"yes" : @"no"];
    if (playlistItem.pendingDate)
    {
        [textDetail appendFormat:@"Last pending: %@\n", [dateFormatter stringFromDate:playlistItem.pendingDate]];
    }

    cell.detailTextLabel.text = textDetail;
    
    return cell;
}


@end
