//
//  PlaylistDelegateProvider.m
//  Example7
//
//  Created by Penthera on 7/11/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "PlaylistDelegateProvider.h"

@implementation PlaylistDelegateProvider

/*
 * This method is called by PlaylistManager when it needs next item in a Playlist
 */
-(VirtuosoPlaylistDownloadAssetItem*)assetForAssetID:(NSString *)assetID {
        
    VirtuosoAssetConfig* config = nil;
    if ([assetID isEqualToString:@"SEASON-1-EPISODE-2"])
    {
        config = [[VirtuosoAssetConfig alloc] initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep2/index.m3u8"
                                                  assetID:@"SEASON-1-EPISODE-2"
                                              description:@"Shadow Play"
                                                     type:kVDE_AssetTypeHLS];
    }
    else
    {
        NSLog(@"Episode not found for assetID: %@", assetID);
    }
    if (config)
    {
        return [[VirtuosoPlaylistDownloadAssetItem alloc]initWithAsset:config];
    }
    else
    {
        return [[VirtuosoPlaylistDownloadAssetItem alloc]initWithOption:PlaylistDownloadOption_SkipToNext];
    }
}

@end
