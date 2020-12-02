//
//  WakeDelegate.m
//  Example14
//
//  Created by Penthera on 7/13/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "WakeDelegate.h"

static NSString* PLAYLIST_NAME = @"TEST_PLAYLIST";
static NSString* EPISODE_NAME = @"SEASON-1-EPISODE-2";


@implementation WakeDelegate

- (void)performRefresh
{
    NSLog(@"PerformRefresh: executing");
    
    VirtuosoPlaylist* playlist = [VirtuosoPlaylist findPlaylist:PLAYLIST_NAME];
    if (!playlist)
    {
        NSLog(@"PerformRefresh: Playlist %@ not found", PLAYLIST_NAME);
        return;
    }
    
    if ([playlist contains:EPISODE_NAME])
    {
        NSLog(@"PerformRefresh: Episode %@ already added to Playlist %@", EPISODE_NAME, PLAYLIST_NAME);
        return;

    }
    
    NSLog(@"PerformRefresh: Appending episode: %@ to playlist: %@", EPISODE_NAME, PLAYLIST_NAME);
    [playlist append:[NSArray arrayWithObject:EPISODE_NAME]];
}

@end
