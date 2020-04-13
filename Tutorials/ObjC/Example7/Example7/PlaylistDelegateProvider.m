//
//  PlaylistDelegateProvider.m
//  Example7
//
//  Created by Penthera on 7/11/19.
//  Copyright © 2019 dev. All rights reserved.
//

#import "PlaylistDelegateProvider.h"

@implementation PlaylistDelegateProvider

/*
 * This method is called by PlaylistManager when it needs next item in a Playlist
 */
- (VirtuosoAssetConfig * _Nullable)assetForAssetID:(NSString * _Nonnull)assetID tryAgainLater:(nonnull Boolean *)tryAgainLater { 
    
    VirtuosoAssetConfig* config = nil;
    if ([assetID isEqualToString:@"SEASON-1-EPISODE-2"])
    {
        config = [[VirtuosoAssetConfig alloc] initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep2/index.m3u8"
                                                  assetID:@"SEASON-1-EPISODE-2"
                                              description:@"Shadow Play"
                                                     type:kVDE_AssetTypeHLS];
    }
    else if ([assetID isEqualToString:@"SEASON-1-EPISODE-3"])
    {
        config = [[VirtuosoAssetConfig alloc] initWithURL:@"http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep3/index.m3u8"
                                                  assetID:@"SEASON-1-EPISODE-3"
                                              description:@"Aloha Adventure"
                                                     type:kVDE_AssetTypeHLS];
    }
    else
    {
        NSLog(@"Episode not found for assetID: %@", assetID);
    }
    
    return config;
}

@end
