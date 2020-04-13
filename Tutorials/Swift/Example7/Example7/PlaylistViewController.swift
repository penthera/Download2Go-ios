//
//  PlaylistViewController.swift
//  Example7
//
//  Created by dev on 7/10/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

class PlaylistViewController: UITableViewController {

    public var playlist: VirtuosoPlaylist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let playlist = self.playlist else { return }
        
        self.navigationItem.title = playlist.name
    }
    
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
        
        detailText.append("Pending Now: \(playlistItem.pending ? "yes" : "no")\n")
        if nil != playlistItem.pendingDate {
            detailText.append("Last Pending: \(dateformatter.string(from: playlistItem.pendingDate!))\n")
        }
        cell.detailTextLabel?.text = detailText;
        
        return cell
    }

}
