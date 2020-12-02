//
//  PlaylistDelegateProvider.swift
//  Example7
//
//  Created by dev on 7/1/19.
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
            config = VirtuosoAssetConfig(url: "http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep2/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-2",
                                         description: "Shadow Play",
                                         type: .vde_AssetTypeHLS)
            break
            
        case "SEASON-1-EPISODE-3":
            config = VirtuosoAssetConfig(url: "http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep3/index.m3u8",
                                         assetID: "SEASON-1-EPISODE-3",
                                         description: "Aloha Adventure",
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
