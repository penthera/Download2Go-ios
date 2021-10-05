//
//  ViewController.swift
//  Example7.1
//
//  Created by Penthera on 3/3/21.
//

import UIKit
import VirtuosoClientDownloadEngine

class ViewController: UITableViewController {
    
    let PlaylistName = "TESTQUEUE-8"
    let MaxItems = 3;
    let InitialAssetList = ["SERIES-8-EPISODE-1", "SERIES-8-EPISODE-2", "SERIES-8-EPISODE-3", "SERIES-8-EPISODE-4", "SERIES-8-EPISODE-5", "SERIES-8-EPISODE-6"]
    
    let backplaneUrl = "https://qa.penthera.com"
    let publicKey = "c9adba5e6ceeed7d7a5bfc9ac24197971bbb4b2c34813dd5c674061a961a899e"
    let privateKey = "41cc269275e04dcb4f2527b0af6e0ea11d227319fa743e4364255d07d7ed2830"
    let loadQueue = OperationQueue()
    
    var assets = [VirtuosoAsset]();
    var playlist : VirtuosoPlaylist?
    var player : DemoPlayerViewController?
    var assetsDeleted = false
    
    var notificationManager : VirtuosoDownloadEngineNotificationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadQueue.maxConcurrentOperationCount = 1
        loadQueue.qualityOfService = .userInitiated
        
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
        self.title = "FastPlay Playlist Episodes"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(resetClicked))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Browse", style: .done, target: self, action: #selector(addClicked))

        self.notificationManager = VirtuosoDownloadEngineNotificationManager(delegate: self)
        self.startup()
    }

    // MARK: -
    // MARK: Click Handlers
    
    @objc func resetClicked() {
        DispatchQueue.global(qos: .utility).async {
            self.clearData()
        }

    }
    
    @objc func addClicked()
    {
        guard let playlist = self.playlist else { return }
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let view = sb.instantiateViewController(identifier: "PlaylistViewController") as PlaylistViewController
        view.playlist = playlist
        self.navigationController?.pushViewController(view, animated: true)
    }

    // MARK: -
    // MARK: Internal Methods
    
    func clearData()
    {
        // Blow away existing Playlist, this needs to happen
        // before we remove the assets.
        VirtuosoPlaylist.clear(self.PlaylistName)
        
        self.playlist = nil
        
        self.assetsDeleted = false;
        // Blow away existing Assets
        VirtuosoAsset.deleteAll()
        
        // wait for all assets to be deleted before
        // adding the first asset.
        while(!self.assetsDeleted) {
            Thread.sleep(forTimeInterval: 1)
        }
        
        // Create demo Playlist
        if (!self.initializeData()) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Initialization error", message: "Check logs for reason.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                }))
                self.present(alert, animated: true, completion: nil)
            }
            return

        }
        // create initial asset
        if VirtuosoDownloadEngine.instance().started {
            self.createInitialAsset()
        }
        self.loadData()
    }
    
    func refreshView()
    {
        let items = self.playlist?.items.count ?? 0;
        if (items < 6)
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addClicked))

        }
        else
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Browse", style: .done, target: self, action: #selector(addClicked))
        }
    }
    
    
    func startup()
    {
        DispatchQueue.global(qos: .utility).async {
            // Important
            // Each time the app starts we blow away all of the previous demo data.
            // Definitely do NOT want to do this in a production app.
            self.clearData()
            //
            // Enable the Engine
            VirtuosoDownloadEngine.instance().enabled = true;
            
            // Backplane permissions require a unique user-id for the full range of captabilities support to work
            // Production code that needs this will need a unique customer ID.
            // For demonstation purposes only, we use the device name
            let userName = UIDevice.current.name
            
            //
            // Create the engine confuration
            guard let config = VirtuosoEngineConfig(user: userName,
                                                    backplaneUrl: self.backplaneUrl,
                                                    publicKey: self.publicKey,
                                                    privateKey: self.privateKey)
            else
            {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Setup Required", message: "Please contact support@penthera.com to setup the backplaneUrl, publicKey, and privateKey", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        exit(0)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            //
            // Start the Engine
            // This method will execute async, the callback will happen on the main-thread.
            VirtuosoDownloadEngine.instance().startup(config) { (status) in
                if status == .vde_EngineStartupSuccess {
                    print("start succeeded")
                    self.createInitialAsset()
                } else {
                    print("start failed")
                }
            }
        }
    }
    
    func loadData() {
        if (loadQueue.operationCount > 0) {
            loadQueue.cancelAllOperations()
        }
        loadQueue.addOperation {
            self.internalLoadData()
        }
    }
    
    func internalLoadData() {
        
        guard let playlist = self.playlist else {
            return
        }
        let name = playlist.name
        
        // Fetch existing assets
        let assets = VirtuosoAsset.assets(withAvailabilityFilter: true)
        
        // Refresh the Playlst
        let refresh = VirtuosoPlaylist.find(name)
        
        DispatchQueue.main.async {
            self.playlist = refresh
            self.assets.removeAll()
            self.assets.append(contentsOf: assets as! [VirtuosoAsset])
            
            self.assets = self.assets.sorted(by: { (asset1, asset2) -> Bool in
                return asset1.assetID < asset2.assetID
            })
            self.tableView.reloadData()
            
            self.refreshView()
        }
    }
    
    func initializeData() -> Bool
    {
        do {
            
            let config = try VirtuosoPlaylistConfig(name: PlaylistName, playlistType: .vde_PlaylistType_FastPlay)
                             
            
            self.playlist = try VirtuosoPlaylist.create(config, withAssets: InitialAssetList)
            return true
        } catch let error as NSError {
            print("Playlist create failed \(error.localizedDescription)")
            return false
        }
    }

    func createInitialAsset()
    {
        guard let assetConfig = VirtuosoAssetConfig(url: "http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep1/index.m3u8",
                                              assetID: "SERIES-8-EPISODE-1",
                                              description: "Sample Description",
                                              type: .vde_AssetTypeHLS) else {
            return;
        }
        
        // Configure asset for FastPlay
        assetConfig.fastPlayEnabled = true
        assetConfig.offlinePlayEnabled = false
        assetConfig.autoAddToQueue = false
        let _ = VirtuosoAsset.init(config: assetConfig)
    }
    
    func play(asset: VirtuosoAsset) {
        
        VirtuosoAsset.isPlayable(asset) { (playable) in
            if !playable { return }

            switch(asset.type) {
            case .vde_AssetTypeHLS, .vde_AssetTypeDASH, .vde_AssetTypeNonSegmented:
                let demoPlayer = DemoPlayerViewController()
                
                //
                // Playback FastPlay
                //
                asset.play(using: .vde_AssetPlaybackTypeFastPlay, andPlayer: demoPlayer as VirtuosoPlayer, onSuccess: {
                    self.present(demoPlayer, animated: true, completion: nil)
                    
                }) {
                    print("Video is unplayble.")
                }
                break
                
            case .vde_AssetTypeHSS:
                print("Playback of HSS supported in another Tutorial")
                break
                
            @unknown default:
                break;
            }
        }

    }
}

// MARK: -
// MARK: TableView Delegate Methods

extension ViewController 
{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assets.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        if (assets.count <= indexPath.row) {
            cell.textLabel?.text = "Unknown"
            return cell
        }
        
        let asset = self.assets[indexPath.row]
        cell.textLabel?.text  = asset.assetID
        var text = ""
        if (asset.downloadCompleteDateTime != nil) {
            text += "Downloaded: \(dateformatter.string(from: asset.downloadCompleteDateTime!))\n"
        }
        if (asset.fastPlayEnabled) {
            text += "FastPlay Enabled\n"
        }
        if (asset.fastPlayReady) {
            text += "FastPlay Ready\n"
        }

        cell.detailTextLabel?.text = text
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (assets.count <= indexPath.row) {
            return;
        }
        
        let asset = self.assets[indexPath.row];
        self.play(asset: asset)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -
// MARK: VirtuosoDownloadEngineNotificationsDelegate Methods


extension ViewController : VirtuosoDownloadEngineNotificationsDelegate {
    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset) {
        self.loadData()
    }
    
    func downloadEngineProgressUpdated(for asset: VirtuosoAsset) {
        self.loadData()
    }
    
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset) {
        self.loadData()
    }
    
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset) {
        self.loadData()
    }
    
    func downloadEngineAllAssetsDeleted() {
        self.assetsDeleted = true;
        self.loadData()
    }
    
    func downloadEngineDeletedAssetId(_ assetID: String) {
        self.loadData()
    }
    
    func playlistChange(_ playlist: VirtuosoPlaylist) {
        self.loadData()
    }
    
}
