//
//  PlaylistSelectionController.swift
//  Example7
//
//  Created by Penthera on 7/10/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

class PlaylistSelectionController: UITableViewController {
    
    var playlists: Array<VirtuosoPlaylist>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.playlists = VirtuosoPlaylistManager.instance().findAllItems()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let playlists = self.playlists else { return 0 }
        return playlists.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell") else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "playlistCell")
        }
        
        guard let playlists = self.playlists else {
            return cell
        }
        
        let playlist = playlists[indexPath.row]
        cell.textLabel?.text = playlist.name
        
        var detailText : String?
        detailText = "(\(playlist.items.count)) items\n"
        detailText?.append("Status: \(playlist.statusAsString())\n")
        detailText?.append("Playback required: \(playlist.isPlaybackRequired ? "yes" : "no")\n")
        detailText?.append("Asset History considered: \(playlist.isAssetHistoryConsidered ? "yes" : "no")\n")
        detailText?.append("Search from beginning: \(playlist.isSearchFromBeginningEnabled ? "yes" : "no")\n")
        
        cell.detailTextLabel?.text = detailText;
        if playlist.items.count > 0 {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        guard let playlists = self.playlists else {
            return
        }

        let playlist = playlists[indexPath.row]

        let view = segue.destination as! PlaylistViewController
        view.playlist = playlist
    }


}
