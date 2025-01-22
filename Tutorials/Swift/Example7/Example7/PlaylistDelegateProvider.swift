//
//  PlaylistDelegateProvider.swift
//  Example7
//
//  Created by Penthera on 7/1/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import Foundation


class PlaylistDelegateProvider : NSObject, VirtuosoPlaylistManagerDelegate {
    
    /*
     * This method is called by PlaylistManager when it needs next item in a Playlist
     */
    
    @objc func asset(forAssetID assetID: String) -> VirtuosoPlaylistDownloadAssetItem {
        
        var config: VirtuosoAssetConfig?
        
        switch assetID {
        case "SEASON-1-EPISODE-2":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep2/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-2",
                                         description: "Shadow Play",
                                         type: .vde_AssetTypeHLS)
            break
            
        case "SEASON-1-EPISODE-3":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep3/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-3",
                                         description: "Aloha Adventure",
                                         type: .vde_AssetTypeHLS)
            break

        case "SEASON-1-EPISODE-4":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep4/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-4",
                                         description: "Squirrelly",
                                         type: .vde_AssetTypeHLS)
            break

        case "SEASON-1-EPISODE-5":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep5/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-5",
                                         description: "Apples Raining",
                                         type: .vde_AssetTypeHLS)
            break

        case "SEASON-1-EPISODE-6":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep6/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-6",
                                         description: "Fighting Back",
                                         type: .vde_AssetTypeHLS)
            break

        default:
            print("Episode not found for assetID: : \(assetID)")
            break
        }
        
        guard let assetConfig = config else {
            return VirtuosoPlaylistDownloadAssetItem(option: .PlaylistDownloadOption_SkipToNext);
        }
        return VirtuosoPlaylistDownloadAssetItem(asset: assetConfig);
    }
    
}
