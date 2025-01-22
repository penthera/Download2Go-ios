//
//  ViewController.swift
//  Example1.5
//
//  Created by dev on 7/24/19.
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
    var refreshInProcess = false
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var statusProgress: UIProgressView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // download engine update listener
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        
        self.statusText.text = "Engine starting..."
        
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
            statusText.text = String(format: "%@ %@%0.02f%% (%qi MB)%@", asset, optionalStatus, fractionComplete*100.0, asset.currentSize/1024/1024, errorAdd)
            statusProgress.progress = Float(fractionComplete)
            downloadButton.isEnabled = false
        }
        else if status == .vde_DownloadComplete {
            statusText.text = String(format: "%@ %0.02f%% (%qi MB)", asset, fractionComplete*100.0, asset.currentSize/1024/1024)
            statusProgress.progress = Float(fractionComplete)
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
            self.statusText.text = "Ready to download"
            self.downloadButton.backgroundColor = UIColor.black
            self.playButton.backgroundColor = UIColor.lightGray
            self.downloadButton.isEnabled = true
            self.playButton.isEnabled = false
            self.refreshButton.isEnabled = false
            self.refreshButton.backgroundColor = UIColor.lightGray

            if nil != self.error {
                self.deleteButton.isEnabled = true
                self.deleteButton.backgroundColor = UIColor.black
            } else {
                self.deleteButton.isEnabled = false
                self.deleteButton.backgroundColor = UIColor.lightGray
            }
            
            self.statusProgress.progress = 0
            return
        }
        
        if (self.refreshInProcess) {
            statusText.text = "Refreshing..."
            
            self.refreshButton.isEnabled = false
            self.refreshButton.backgroundColor = UIColor.lightGray
            
            self.deleteButton.isEnabled = false
            self.deleteButton.backgroundColor = UIColor.lightGray
            
            self.downloadButton.isEnabled = false
            self.downloadButton.backgroundColor = UIColor.lightGray
            
            self.playButton.isEnabled = false
            self.playButton.backgroundColor = UIColor.lightGray
            
            self.statusProgress.progress = Float(asset.fractionComplete)
            return
        }
        else if asset.fractionComplete < 1.0
        {
            self.statusText.text = "Downloading..."
            self.refreshButton.isEnabled = false
            self.refreshButton.backgroundColor = UIColor.lightGray
        }
        else
        {
            self.statusText.text = "Ready to play"
            self.refreshButton.isEnabled = true
            self.refreshButton.backgroundColor = UIColor.black
        }
        
        self.deleteButton.isEnabled = true
        self.deleteButton.backgroundColor = UIColor.black
        self.downloadButton.isEnabled = false
        self.downloadButton.backgroundColor = UIColor.lightGray
        
        self.statusProgress.progress = Float(asset.fractionComplete)

        VirtuosoAsset.isPlayable(asset) { (playable) in
            if playable {
                self.playButton.isEnabled = true
                self.playButton.backgroundColor = UIColor.black
            } else {
                self.playButton.isEnabled = false
                self.playButton.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    
    @IBAction func refreshPressed(_ sender: Any) {
        guard let asset = self.exampleAsset else {
            return
        }
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            instance.audioLanguagesToDownload = nil
        })
        
        self.refreshInProcess = true
        asset.refreshManifestAndDownload { asset, error in
            print("refresh completed")
        }

    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton)
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
            
            // Important:
            // First download only includes Spanish audio, during the refresh we add all other languages.
            VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
                instance.audioLanguagesToDownload = ["sp"]
            })
            
            // Important: AssetID should be unique across your video catalog
            let yourAssetID = "SINGLE_CC_TEST"
            
            // Create asset configuration object
            guard let config = VirtuosoAssetConfig(url: "https://playertest.longtailvideo.com/adaptive/eleph-audio/playlist.m3u8",
                                                   assetID: yourAssetID,
                                                   description: "Sample Asset",
                                                   type: kVDE_AssetType.vde_AssetTypeHLS) else {
                                                    print("create config failed")
                                                    sender.isEnabled = true
                                                    return
            }
            
            // Create asset and commence downloading.
            let _ = VirtuosoAsset.init(config: config)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.refreshView()
            }
        }
    }
    
    //
    // MARK: VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY
    //
    
    func downloadEngineDidFinishRefreshingAsset(_ asset: VirtuosoAsset) {
        if self.exampleAsset?.uuid == asset.uuid
        {
            self.refreshInProcess = false;
            self.exampleAsset = asset
            refreshView()
        }
    }
    
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



