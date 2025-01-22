//
//  ViewController.swift
//  Example1.4
//
//  Created by dev on 7/19/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, VirtuosoDownloadEngineNotificationsDelegate {
    
    // <-- change these to your settings in production
    let publicKey = "replace_with_your_public_key"
    let privateKey = "replace_with_your_private_key"
    
    //
    // MARK: Instance data
    //
    var exampleAsset: VirtuosoAsset?
    var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!
    var error: VirtuosoError?
    
    @IBOutlet weak var ancillaryImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var statusProgressBar: UIProgressView!
    @IBOutlet weak var pauseSwitch: UISwitch!
    @IBOutlet weak var pauseStatusLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // download engine update listener
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        
        self.statusLabel.text = "Engine starting..."
        
        // Backplane permissions require a unique user-id for the full range of captabilities support to work
        // Production code that needs this will need a unique customer ID.
        // For demonstation purposes only, we use the device name
        let userName = UIDevice.current.name
        
        //
        // Create the engine confuration
        guard let config = VirtuosoEngineConfig(user: userName,
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
            } else {
                print("start failed")
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
        
        displayAncillary(asset)
    }
    
    func displayAncillary(_ asset: VirtuosoAsset) {
        self.ancillaryImage.image = nil
        
        // Notice you can query ancillarys based on the tag you assigned when creating
        let ancillaries = asset.findCompletedAncillaries(withTag: "movie-posters")
        
        guard let ancillary = ancillaries.first else { return }
        if ancillary.isDownloaded {
            self.ancillaryImage.image = ancillary.image
        }
    }
    
    private func loadEngineData()
    {
        self.error = nil
        
        // Recommended calls into VirtuosoDownloadEngine are done on a background thread
        // to prevent blocking the MainThread.
        DispatchQueue.global().async {
            
            //
            // Make sure the engine is started
            if VirtuosoDownloadEngine.instance().started {
                
                // assets that have finished downloading
                let downloadComplete = VirtuosoAsset.completedAssets(withAvailabilityFilter: false)
                
                // assets that are being parsed & downloaded
                let downloadPending = VirtuosoAsset.pendingAssets(withAvailabilityFilter: false)
                
                // Switch to UI MainThread & update the view
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
            self.ancillaryImage.image = nil
            self.pauseSwitch.setOn(false, animated: true)
            self.pauseSwitch.isEnabled = false
            self.pauseStatusLabel.text = "Pause Download"
            self.pauseStatusLabel.isEnabled = false
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
        
        displayAncillary(asset)
        
        if asset.fractionComplete < 1.0 {
            statusLabel.text = "Downloading..."
            self.pauseSwitch.isEnabled = true
            self.pauseSwitch.setOn(asset.isPaused, animated: true)
            self.pauseStatusLabel.isEnabled = true
            self.pauseStatusLabel.text = "Pause Download"
        } else {
            statusLabel.text = "Ready to play"
            self.pauseSwitch.isEnabled = false
            self.pauseSwitch.setOn(asset.isPaused, animated: true)
            self.pauseStatusLabel.isEnabled = false
            self.pauseStatusLabel.text = "Pause Download"
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
    
    @IBAction func pauseClicked(_ sender: Any) {
        guard let asset = self.exampleAsset else { return }
        
        // Pause downloading for the Asset
        asset.isPaused = self.pauseSwitch.isOn
        
        refreshView()
    }
    
    @IBAction func deleteBtnClicked(_ sender: UIButton)
    {
        sender.isEnabled = false   // Block reentry
        
        guard let asset = self.exampleAsset else { return }
        
        self.exampleAsset = nil;
        asset.delete()
        loadEngineData()
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
            // Important: AssetID should be unique across your video catalog
            let yourAssetID = "tears-of-steel-asset-1"
            
            // Create asset configuration object
            guard let config = VirtuosoAssetConfig(url: "https://virtuoso-demo-content.s3.amazonaws.com/tears/index.m3u8",
                                                   assetID: yourAssetID,
                                                   description: "Tears of Steel",
                                                   type: kVDE_AssetType.vde_AssetTypeHLS) else {
                                                    print("create config failed")
                                                    sender.isEnabled = true
                                                    return
            }
            
            self.addAncillary(config: config)
            
            // Create asset and commence downloading.
            let _ = VirtuosoAsset.init(config: config)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.refreshView()
            }
        }
    }
    
    // Sample method to show how you might add an ancillary file to the asset for download
    // Ancilllary files are downloaded with the asset. In this example, we download a movie poster.
    func addAncillary(config: VirtuosoAssetConfig) {
        
        // Create ancillary and specify a tag of "movie-posters"
        // The tag allows you to logically group a collection of related Ancillaries
        guard let ancillary = VirtuosoAncillaryFile(
            downloadUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Tos-poster.png/440px-Tos-poster.png",
            andTag: "movie-posters") else {
                return
        }
        
        // Add array of ancillaries.
        config.ancillaries = [ancillary]
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
    func downloadEngineDidEncounterError(for asset: VirtuosoAsset, virtuosoError: VirtuosoError?, task: URLSessionTask?, data: Data?, statusCode: NSNumber?) {
        self.error = virtuosoError
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
}



