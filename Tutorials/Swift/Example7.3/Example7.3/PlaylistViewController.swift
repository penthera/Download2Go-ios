//
//  PlaylistViewController.swift
//  Example7
//
//  Created by Penthera on 7/10/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

//
// This view demonstrates displaying

class PlaylistViewController: UITableViewController, VirtuosoDownloadEngineNotificationsDelegate {
    
    public var playlist: VirtuosoPlaylist?
    var notificationManager: VirtuosoDownloadEngineNotificationManager?

    // MARK: -
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
        
        self.notificationManager = VirtuosoDownloadEngineNotificationManager(delegate: self)
        guard let playlist = self.playlist else { return }
        self.navigationItem.title = playlist.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.notificationManager = nil;
    }
    
    // MARK: -
    // MARK: Table Support
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let playlist = self.playlist else { return 0 }
        return playlist.items.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playlistItemCell") else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "playlistItemCell")
        }
        
        guard let playlist = self.playlist else {
            return cell
        }
        
        let playlistItem = playlist.items[indexPath.row]
        
        cell.textLabel?.text = playlistItem.assetID
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        
        var detailText : String = ""
        detailText.append("Status: \(VirtuosoPlaylistItem.status(asString: playlistItem.itemState))\n")
        
        if nil != playlistItem.downloadComplete {
            detailText.append("Downloaded: yes \(dateformatter.string(from: playlistItem.downloadComplete!))\n")
        } else {
            detailText.append("Downloaded: no\n")
        }
        detailText.append("Deleted: \(playlistItem.userDeleted ? "yes" : "no")\n")
        
        if nil != playlistItem.playbackDate {
            detailText.append("Playback: yes \(dateformatter.string(from: playlistItem.playbackDate!))\n")
        } else {
            detailText.append("Playback: no\n")
        }
        
        detailText.append("Expired: \(playlistItem.expired ? "yes" : "no")\n")
        
        detailText.append("Pending Now: \(playlistItem.pending ? "yes" : "no")\n")
        if nil != playlistItem.pendingDate {
            detailText.append("Last Pending: \(dateformatter.string(from: playlistItem.pendingDate!))\n")
        }
        
        cell.detailTextLabel?.text = detailText;
        
        return cell
    }

    // MARK: -
    // MARK: Action handlers
    
    @objc func appendClicked()
    {
        guard let playlist = self.playlist else { return }
        
        // Append will add Episodes 4, 5, 6
        if (playlist.items.count >= 2 && playlist.items.count < 6)
        {
            let episode = "SERIES-8-EPISODE-\(playlist.items.count + 1)"
            
            if (playlist.contains(episode)) { return; }
            
            
            // Important:
            // When the following call completes, if the playlist had a pendingCount
            // we will immediately trigger an auto-download
            do {
            
                try playlist.append([episode])
                
            }
            catch let error as NSError
            {
                print("Playlist append failed with error: \(error.localizedDescription)")
            }
            
            self.refreshView()
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: -
    // MARK: Internals
    func refreshView() {
        DispatchQueue.global(qos: .userInitiated).async
        {
            guard let playlist = self.playlist else { return }
            self.playlist = VirtuosoPlaylist.find(playlist.name)
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
                
                guard let playlist = self.playlist else { return }
                
                if (playlist.items.count < 6) {
                    let append = UIBarButtonItem(title: "Append", style: .done, target: self, action: #selector(self.appendClicked))
                    self.navigationItem.rightBarButtonItem = append
                }
                else {
                    self.navigationItem.rightBarButtonItem = nil
                }
                

            }
        }
    }
    
    
    // MARK: -
    // MARK: VirtuosoDownloadEngineNotificationsDelegate support

    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset) {
        self.refreshView()
    }
    
    func downloadEngineProgressUpdated(for asset: VirtuosoAsset) {
        self.refreshView()
    }
    
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset) {
        self.refreshView()
    }
    
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset) {
        self.refreshView()
    }

    func downloadEngineInternalQueueUpdate() {
        self.refreshView()
    }
    
    func playlistChange(_ playlist: VirtuosoPlaylist) {
        self.refreshView()
    }
}
