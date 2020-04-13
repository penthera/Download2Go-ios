//
//  ViewController.swift
//  Example10
//
//  Created by dev on 2/2/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, VirtuosoDownloadEngineNotificationsDelegate {

    // <-- change these to your settings in production
    let backplaneUrl = "replace_with_your_backplane_url"
    let publicKey = "replace_with_your_public_key"
    let privateKey = "replace_with_your_private_key"

    //
    // MARK: Instance data
    //
    var exampleAsset: VirtuosoAsset?
    var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!
    var error: Error?
    
    //
    // MARK: Outlets
    //
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var fastPlayBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var statusProgressBar: UIProgressView!
       
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Important:
        // The download engine runs async in background. We can receive status updates by implementing
        // the VirtuosoDownloadEngineNotificationsDelegate methods. As processing progresses, our delegate
        // will receive callbacks allowing us to refresh the UI.
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        
        self.statusLabel.text = "Engine starting..."
        
        //
        // Enable the Engine
        VirtuosoDownloadEngine.instance().enabled = true;
        
        // Backplane permissions require a unique user-id for the full range of captabilities support to work
        // Production code that needs this will need a unique customer ID.
        // For demonstation purposes only, we use the device name
        let userName = UIDevice.current.name
        
        //
        // Create the engine configuration
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
            if status == .vde_EngineStartupSuccess {
                print("Startup succeeded.")
            } else {
                print("Startup encountered error.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // MARK: Click Handlers
    
    @IBAction func deleteBtnClicked(_ sender: UIButton)
    {
        sender.isEnabled = false   // Block reentry
        
        guard let asset = self.exampleAsset else { return }
        
        statusLabel.text = String(format: "Deleting Asset:%@", asset)
        
        asset.delete(onComplete: {
            self.statusLabel.text = "Deleted.";
            self.loadEngineData()
            self.setEnabledAppearance(self.fastPlayBtn, enabled: true)
        })
    }
        
    @IBAction func fastPlayBtnClicked(_ sender: UIButton)
    {
        // block reentrancy while we create the asset
        
        self.setEnabledAppearance(self.fastPlayBtn, enabled: false)
        
        // This button does double duty
        
        if (self.exampleAsset != nil && self.exampleAsset!.fastPlayReady)
        {
            self.playAsset(self.exampleAsset!);
        }
        else
        {
            // Queue asset for FastPlay.  When enough of the asset has been processed playblack
            // will automatically begin
            
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
                guard let config = VirtuosoAssetConfig(url: "http://virtuoso-demo-content.s3.amazonaws.com/tears/index.m3u8",
                                                      assetID: yourAssetID,
                                                      description: "Tears of Steel",
                                                      type: kVDE_AssetType.vde_AssetTypeHLS) else {
                                                        print("create config failed")
                                                        self.setEnabledAppearance(self.fastPlayBtn, enabled: true)
                                                        return
                }

                // FastPlay specific configuration flags
                
                // Skip automatic download
                config.autoAddToQueue = false;
                
                // Enable FastPlay
                config.enableFastPlay = true;

               // Create asset and commence downloading.
               let _ = VirtuosoAsset.init(config: config)
                    DispatchQueue.main.async {
                        self.refreshView()
                        self.statusLabel.text = "Preparing for FastPlay...";
               }
            }
        }
    }
    
    //
    // MARK: Internal implementation
    //
    
    func displayAsset(asset: VirtuosoAsset)
    {
        let fractionComplete = asset.fractionComplete
        let status = asset.status
        
        if asset.fastPlayReady
        {
            statusLabel.text = String(format: "FastPlay ready at %0.02f%% complete (%qi MB)", fractionComplete*100.0, asset.currentSize/1024/1024)
            statusProgressBar.progress = Float(fractionComplete)
        }
        else
        {
            var errorAdd = ""
            if( asset.downloadRetryCount > 0 ) {
                errorAdd = String(format: " (Errors: %i)", asset.downloadRetryCount)
            }
            if status != .vde_DownloadComplete && status != .vde_DownloadProcessing {
                let optionalStatus = (asset.status == .vde_DownloadInitializing) ? NSLocalizedString("Initializing: ", comment: "") : ""
                statusLabel.text = String(format: "%@ %@%0.02f%% (%qi MB)%@", asset, optionalStatus, fractionComplete*100.0, asset.currentSize/1024/1024, errorAdd)
                statusProgressBar.progress = Float(fractionComplete)
                self.setEnabledAppearance(fastPlayBtn, enabled: false)
            }
            else if status == .vde_DownloadComplete {
                statusLabel.text = String(format: "%@ %0.02f%% (%qi MB)", asset, fractionComplete*100.0, asset.currentSize/1024/1024)
                statusProgressBar.progress = Float(fractionComplete)
            }
        }
    }
    
    private func playAsset(_ asset: VirtuosoAsset)
    {
        self.setEnabledAppearance(fastPlayBtn, enabled: true);
        
        VirtuosoAsset.isPlayable(asset) { (playable) in
            if !playable {
                return // not playable yet
            }

            switch(asset.type)
            {
                case .vde_AssetTypeHLS, .vde_AssetTypeDASH, .vde_AssetTypeNonSegmented:
                    // Present the player
                    
                    let demoPlayer = DemoPlayerViewController()
                
                    asset.play(using: .vde_AssetPlaybackTypeLocal, andPlayer: demoPlayer as VirtuosoPlayer, onSuccess: {
                    self.present(demoPlayer, animated: true, completion: nil)
                    
                }) {
                    self.exampleAsset = nil
                    self.error = nil
                    print("Can't play video!")
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
    
    // ------------------------------------------------------------------------------------------------------------
    // IMPORTANT:
    // Loads data from the Download Engine.
    // ------------------------------------------------------------------------------------------------------------
        
    private func loadEngineData()
    {
        self.error = nil

        DispatchQueue.global().async {
            //
            // Important:
            // Invoked on background thread to prevent blocking UI updates
            //
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
            
            self.statusLabel.text = "Ready to start FastPlay";
            self.statusProgressBar.progress = Float(0.0);
            
            self.setEnabledAppearance(deleteBtn, enabled: nil != self.error ? true : false)
            
            return
        }
        
        self.statusLabel.text = (self.exampleAsset!.fastPlayReady ? "FastPlay ready" : "Preparing for FastPlay...");
        
        self.setEnabledAppearance(deleteBtn, enabled: true)
        
        self.statusProgressBar.progress = Float(asset.fractionComplete);
    }
    
    private func setEnabledAppearance(_ control:UIControl, enabled: Bool)
    {
        control.isEnabled = enabled;
        control.backgroundColor = (enabled ? UIColor.black :UIColor.lightGray);
        
        return;
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
        refreshView()
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
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever the Engine reports a VirtuosoAsset is ready for FastPlay
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineFastPlayAssetReady(_ asset: VirtuosoAsset)
    {
        print("FastPlay asset reported ready to play. Asset: %@", asset);
        
        self.playAsset(asset)
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
}

