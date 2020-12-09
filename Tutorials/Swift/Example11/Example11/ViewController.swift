//
//  ViewController.swift
//  Example11
//
//  Created by dev on 1/31/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class ViewController: UIViewController, VirtuosoDownloadEngineNotificationsDelegate, VirtuosoBackplaneNotificationsDelegate {
    var detectedDeviceUnregister = false
    
    
    // <-- change these to your settings in production
    let backplaneUrl = "replace_with_your_backplane_url"
    let publicKey = "replace_with_your_public_key"
    let privateKey = "replace_with_your_private_key"
    
    //
    // MARK: Instance data
    //
    var exampleAsset: VirtuosoAsset?
    var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!
    var backplaneNotifications: VirtuosoBackplaneNotificationsManager!
    var hasDownloaded = false
    var error: Error?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var statusProgressBar: UIProgressView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // download engine update listener
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        backplaneNotifications = VirtuosoBackplaneNotificationsManager.init(delegate: self)
        
        self.statusLabel.text = "Starting Engine..."

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
                let alert = UIAlertController(title: "Setup Required", message: "Please contact support@penthera.com to setup the backplaneUrl, pulicKey, and privateKey", preferredStyle: .alert)
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
            if status != .vde_EngineStartupSuccess {
                let alert = UIAlertController(title: "Startup Failed", message: "Startup completed with status: \(status)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func displayAsset(asset: VirtuosoAsset)
    {
        let fractionComplete = asset.fractionComplete
        let status = asset.status
        var errorAdd = ""
        if( asset.downloadRetryCount > 0 ) {
            errorAdd = String(format: " (Errors: %i)", asset.downloadRetryCount)
        }
        if status != .vde_DownloadComplete && status != .vde_DownloadProcessing {
            let optionalStatus = (asset.status == .vde_DownloadInitializing) ? NSLocalizedString("Initializing: ", comment: "") : ""
            statusLabel.text = String(format: "%@ %@%0.02f%% (%qi MB)%@", asset, optionalStatus, fractionComplete*100.0, asset.currentSize/1024/1024, errorAdd)
            statusProgressBar.progress = Float(fractionComplete)
            downloadBtn.isEnabled = false
        }
        else if status == .vde_DownloadComplete {
            statusLabel.text = String(format: "%@ %0.02f%% (%qi MB)", asset, fractionComplete*100.0, asset.currentSize/1024/1024)
            statusProgressBar.progress = Float(fractionComplete)
        }
    }
    
    private func loadEngineData()
    {
        self.error = nil

        DispatchQueue.global().async {
            if VirtuosoDownloadEngine.instance().started {
                let downloadComplete = VirtuosoAsset.completedAssets(withAvailabilityFilter: false)
                let downloadPending = VirtuosoAsset.pendingAssets(withAvailabilityFilter: false)
                DispatchQueue.main.async {
                    if downloadComplete.count > 0 {
                        self.exampleAsset = downloadComplete.first as? VirtuosoAsset
                    }
                    else if downloadPending.count > 0 {
                        self.exampleAsset = downloadPending.first as? VirtuosoAsset
                    }
                    else {
                        self.exampleAsset = nil
                    }
                    self.refreshView()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.loadEngineData()
                }
            }
        }
    }
    
    private func refreshView()
    {
        guard let asset = self.exampleAsset else {
            self.statusLabel.text = "Ready to download"
            self.downloadBtn.backgroundColor = UIColor.black
            self.playBtn.backgroundColor = UIColor.lightGray
            self.downloadBtn.isEnabled = true
            self.playBtn.isEnabled = false
            
            if nil != self.error {
                deleteBtn.isEnabled = true
                deleteBtn.backgroundColor = UIColor.black
            } else {
                deleteBtn.isEnabled = false
                deleteBtn.backgroundColor = UIColor.lightGray
            }

            self.statusProgressBar.progress = 0
            return
        }
        
        if asset.fractionComplete < 1.0 {
            statusLabel.text = "Downloading..."
        } else {
            statusLabel.text = "Ready to play"
        }
        
        deleteBtn.isEnabled = true
        deleteBtn.backgroundColor = UIColor.black
        downloadBtn.isEnabled = false
        downloadBtn.backgroundColor = UIColor.lightGray
        
        statusProgressBar.progress = Float(asset.fractionComplete)

        VirtuosoAsset.isPlayable(asset) { (playable) in
            if playable {
                self.playBtn.isEnabled = true
                self.playBtn.backgroundColor = UIColor.black
            } else {
                self.playBtn.isEnabled = false
                self.playBtn.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    //
    // Handles unregistering devices
    @IBAction func unregisterDevicesClicked(_ sender: Any)
    {
        DispatchQueue.global().async {
            let error = self.unregisterAllDevices()
            
            var maximumWait:Double = 30;
            let sleepDuration:Double = 1.0;
            while (!self.detectedDeviceUnregister && maximumWait > 0)
            {
                Thread.sleep(forTimeInterval: sleepDuration)
                maximumWait -= sleepDuration;
            }

            DispatchQueue.main.async {
                let alertView: UIAlertController?
                if nil != error
                {
                    //
                    // Encountered an error while attempting to unregister,
                    // most likely cause is a Network issue.
                    alertView = UIAlertController(title: "Unregister Failed", message: "Error encountered while unregistering. error: \(String(describing: error))", preferredStyle: .alert)
                    alertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    }))
                }
                else if (maximumWait <= 0) {
                    alertView = UIAlertController(title: "Unregister Complete With Issues", message: "All devices are unregistered but never detected device unregister notification. App will now exit.", preferredStyle: .alert)
                    alertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        exit(0);
                    }))
                }
                else
                {
                    //
                    // Devices un-registered
                    // Penthera SDK must be initialzed again before it can be used.
                    // See: VirtuosoDownloadEngine.instance().startup
                    alertView = UIAlertController(title: "Unregister Complete", message: "All devices are unregistered. App will now exit.", preferredStyle: .alert)
                    alertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        exit(0)
                    }))
                }
                guard let alert = alertView else { return }
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func unregisterAllDevices() -> NSError? {
        // Private function to handle unregistering device
        // and waiting for that to complete.
        func unregisterAndWait(device : VirtuosoDevice) ->NSError?
        {
            let semaphore = DispatchSemaphore(value:0)
            var result: NSError? = nil
            DispatchQueue.global().async {
                device.unregister { (status, error) in
                    
                    result = error as NSError?
                    if (status)
                    {
                        print("unregister device \(device.nickname) succeeded.")
                    }
                    else
                    {
                        print("unregister device \(device.nickname) failed.")
                    }
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            return result
        }

        
        // Important:
        // Once you have unregistered devices, Penthera is unavailable until
        // you invoke VirtuosoDownloadEngine.instance().startup again.
        
        let devices = VirtuosoDownloadEngine.instance().devices;
        
        var currentDevice: VirtuosoDevice? // last device to unregister is the current device
        var error: NSError? = nil
        for anyObject in devices
        {
            if (anyObject is VirtuosoDevice)
            {
                let device = anyObject as! VirtuosoDevice
                if device.isThisDevice
                {
                    currentDevice = device
                }
                else
                {
                    error = unregisterAndWait(device: device)
                    if error != nil {
                        return error
                    }
                }
            }
        }
        
        guard let current = currentDevice else {
            return nil
        }
        
        // unregister the current device
        return unregisterAndWait(device: current)

    }
    
    @IBAction func deleteBtnClicked(_ sender: UIButton)
    {
        sender.isEnabled = false   // Block reentry
        
        guard let asset = self.exampleAsset else { return }
        asset.delete {
            self.statusLabel.text = ""
            self.statusProgressBar.progress = 0
            // Give next smartdownload time to get started
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.loadEngineData()
            })
        }
    }
    
    @IBAction func playBtnClicked(_ sender: UIButton)
    {
        guard let asset = self.exampleAsset else {
            print("asset not playable yet")
            return
        }
        
        VirtuosoAsset.isPlayable(asset) { (playable) in
            if !playable { return }

            switch(asset.type) {
            case .vde_AssetTypeHLS, .vde_AssetTypeDASH, .vde_AssetTypeNonSegmented:
                let demoPlayer = DemoPlayerViewController()
                
                asset.play(using: .vde_AssetPlaybackTypeLocal, andPlayer: demoPlayer as VirtuosoPlayer, onSuccess: {
                    self.present(demoPlayer, animated: true, completion: nil)
                    
                }) {
                    self.exampleAsset = nil
                    self.error = nil
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
    
    @IBAction func downloadBtnClicked(_ sender: UIButton)
    {
        sender.isEnabled = false // block reentrancy while we create the asset
        
        if .vde_ReachableViaWiFi != VirtuosoDownloadEngine.instance().currentNetworkStatus() {
            let alertView = UIAlertController(title: "Network Unreachable", message: "Demo requires WiFi", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                sender.isEnabled = true
            }))
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        // Create the Asset on a background thread
        DispatchQueue.global(qos: .background).async {
            // Create asset configuration object
            guard let config = VirtuosoAssetConfig(url: "http://virtuoso-demo-content.s3.amazonaws.com/bbb/season1/ep1/index.m3u8",
                                                   assetID: "SEASON-1-EPISODE-1",
                                                   description: "The Right Kite",
                                                   type: kVDE_AssetType.vde_AssetTypeHLS) else {
                                                    print("create config failed")
                                                    sender.isEnabled = true
                                                    return
            }
            
            // Create the Playlist
            // The playlist contains three assets, which will download in sequence as previous episode
            // is played and then deleted.
            //
            // PlaylistConfig is used to control how smart-download works.
            let playlistConfig = VirtuosoPlaylistConfig(name: "TEST_PLAYLIST")
            
            // Create array of Playlist
            var playlists : Array<VirtuosoPlaylist> = Array()
            
            // Add a Playlist to the array
            playlists.append(VirtuosoPlaylist(config: playlistConfig,
                                              assets: ["SEASON-1-EPISODE-1", "SEASON-1-EPISODE-2", "SEASON-1-EPISODE-3"]))
            
            // When you create an Asset, you can also create playlists that might be assocated with the Asset.
            config.playlists = playlists
            
            // For demo purposes we clear the previous playlist.
            // This causes 'TEST_PLAYLIST' to be removed completely, resetting the demo.
            // Ordinarily you would NOT do this as doing so will reset the smart-downloading cycle,
            // restarting at the beginning.
            VirtuosoPlaylistManager.instance().clear("TEST_PLAYLIST")
            
            // Create asset and commence downloading.
            let _ = VirtuosoAsset.init(config: config)
            
            //
            // Alternatively, you can create a Playlist directly using the following:
            // VirtuosoPlaylistManager.instance().create(withItems: playlists)
            
            //
            // Playlists can be appended to as well
            // VirtuosoPlaylistManager.instance().appendItems(playlists)

            DispatchQueue.main.async {
                sender.isEnabled = true
                self.hasDownloaded = true
                self.refreshView()
            }
        }
        
    }

    //
    // MARK: VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY
    //
    
    // --------------------------------------------------------------
    //  Called whenever the Engine starts downloading a VirtuosoAsset object.
    // --------------------------------------------------------------
    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset)
    {
        displayAsset(asset: asset)
    }
    
    // --------------------------------------------------------------
    // Called whenever the Engine reports progress for a VirtuosoAsset object
    // --------------------------------------------------------------
    func downloadEngineProgressUpdated(for asset: VirtuosoAsset)
    {
        DispatchQueue.global(qos: .background).async {
            VirtuosoAsset.isPlayable(asset) { (playable) in
                if playable {
                    self.exampleAsset = asset;
                    self.refreshView()
                }
                self.displayAsset(asset: asset)
            }
        }
    }
    
    // --------------------------------------------------------------
    // Called when an asset is being processed after background transfer
    // --------------------------------------------------------------
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset)
    {
        displayAsset(asset: asset)
    }
    
    // --------------------------------------------------------------
    // Called whenever the Engine reports a VirtuosoAsset as complete
    // --------------------------------------------------------------
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset)
    {
        // Download is complete
        displayAsset(asset: asset)
        refreshView()
        loadEngineData()
    }
    
    // --------------------------------------------------------------
    // Called whenever an Engine encounters error downloading asset
    // --------------------------------------------------------------
    func downloadEngineDidEncounterError(for asset: VirtuosoAsset, error: Error?, task: URLSessionTask?, data: Data?, statusCode: NSNumber?) {
        self.error = error
        displayAsset(asset: asset)
        refreshView()
        loadEngineData()
    }
    
    // --------------------------------------------------------------
    // Called whenever an asset is added to the Engine
    // --------------------------------------------------------------
    func downloadEngineInternalQueueUpdate() {
        loadEngineData()
    }
    
    // --------------------------------------------------------------
    // Called whenever Engine start completes
    // --------------------------------------------------------------
    func downloadEngineStartupComplete(_ succeeded: Bool) {
        loadEngineData()
    }
    
    
    //
    // MARK: VirtuosoBackplaneNotificationsDelegate - required methods ONLY
    //
    
    func backplaneSyncComplete(withStatus status: Bool, error: Error?) {
        
    }

    func backplaneRemoteKill() {
        
    }
    
    func backplaneStartingRemoteKill() {
        
    }
    
    func backplaneDidUnregisterDevice(withStatus success: Bool, error: Error?) {
        self.detectedDeviceUnregister = true
    }
    

}

