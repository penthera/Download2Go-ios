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
     * This method is called by PlaylistManager when it needs to create a PlaylistItem
     */
    
    @objc func asset(forAssetID assetID: String) -> VirtuosoPlaylistDownloadAssetItem {
        
        var config: VirtuosoAssetConfig?
        
        switch assetID {
        case "SERIES-8-EPISODE-1":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep1/index.m3u8",
                                         assetID: assetID,
                                         description: "The Right Knight",
                                         type: .vde_AssetTypeHLS)
            break
        case "SERIES-8-EPISODE-2":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep2/index.m3u8",
                                         assetID: assetID,
                                         description: "Shadow Play",
                                         type: .vde_AssetTypeHLS)
            break
        case "SERIES-8-EPISODE-3":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep3/index.m3u8",
                                         assetID: assetID,
                                         description: "Aloha Adventure",
                                         type: .vde_AssetTypeHLS)
            break
            
        case "SERIES-8-EPISODE-4":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep4/index.m3u8",
                                         assetID: assetID,
                                         description: "Squirrelly",
                                         type: .vde_AssetTypeHLS)
            break

        case "SERIES-8-EPISODE-5":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep5/index.m3u8",
                                         assetID: assetID,
                                         description: "Apples Raining",
                                         type: .vde_AssetTypeHLS)
            break

        case "SERIES-8-EPISODE-6":
            config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep6/index.m3u8",
                                         assetID: assetID,
                                         description: "Final Call",
                                         type: .vde_AssetTypeHLS)
            break

        default:
            print("Episode not found for assetID: : \(assetID)")
            break
        }
        
        guard let assetConfig = config else {
            return VirtuosoPlaylistDownloadAssetItem(option: .PlaylistDownloadOption_SkipToNext);
        }
        
        // IMPORTANT:
        // This asset has been created for FastPlay so we need
        // to alter the default configuration as follows:
        assetConfig.downloadType = .vde_DownloadFastPlayPlayback;
        assetConfig.autoAddToQueue = false
        
        
        return VirtuosoPlaylistDownloadAssetItem(asset: assetConfig);
    }
        
}
