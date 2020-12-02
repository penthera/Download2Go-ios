//
//  WakeDelegate.swift
//  Example14
//
//  Created by Penthera on 7/13/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import Foundation

class WakeDelegate : NSObject, VirtuosoRefreshManagerDelegate, VirtuosoDownloadEngineNotificationsDelegate {

    let playlistName = "TEST_PLAYLIST"
    let episodeID = "SEASON-1-EPISODE-2"

    var episodeDownloadComplete: Date?
    
    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset) {
        
    }
    
    func downloadEngineProgressUpdated(for asset: VirtuosoAsset) {
        
    }
    
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset) {
        
    }
    
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset) {
        if (asset.assetID == episodeID)
        {
            self.episodeDownloadComplete = Date()
            print("Download finished for assetID \(episodeID)")
        }
    }
    
    func downloadEngineDidEncounterError(for asset: VirtuosoAsset, error: Error?, task: URLSessionTask?, data: Data?, statusCode: NSNumber?) {
        self.episodeDownloadComplete = Date()
    }
    
    // This method will be invoked during a background wake. We use
    // that opportnity to update the Playlist catalog with a new episode.
    func performRefresh()
    {
        _ = VirtuosoDownloadEngineNotificationManager(delegate: self)
        
        print("PerformRefresh: executing")
        guard let playlist = VirtuosoPlaylist.find(playlistName) else
        {
            print("PerformRefresh: Playlist \(playlistName) not found")
            return
        }
        
        if (playlist.contains(episodeID))
        {
            print("PerformRefresh: Episode already exists")
            return
        }
        
        print("PerformRefresh: Appending episode: \(episodeID) to playlist: \(playlistName)")
        playlist.append([episodeID])
        
        // When this method returns, background execution will stop. If you need to do more work
        // while in the background, make sure you do that before you return here...
        
        // For demonstration purposes, we wait for download to complete
        var maxWait = 60.0 * 5.0
        let sleep = 5.0
        
        while(self.episodeDownloadComplete == nil && maxWait > 0)
        {
            print("PerformRefresh: Waiting for asset to finish downloading. AssetID: \(episodeID) Playlist: \(playlistName)")
            Thread.sleep(forTimeInterval: sleep)
            maxWait -= sleep
        }
    }
    
}
