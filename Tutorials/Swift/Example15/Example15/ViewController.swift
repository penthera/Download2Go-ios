//
//  ViewController.swift
//  Example15
//
//  Created by dev on 7/24/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class ViewController: UIViewController, VirtuosoDownloadEngineNotificationsDelegate, VirtuosoAdsManagerNotificationDelegate {
    
    //
    // MARK: Instance data
    //
    var exampleAsset: VirtuosoAsset?
    var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!
    var adsNotifications: VirtuosoAdsNotificationsManager!
    var beaconsReported: [[String:Any]] = []
    
    var error: Error?
    
    // <-- change these to your settings in production
    let backplaneUrl = "replace_with_your_backplane_url"
    let publicKey = "replace_with_your_public_key"
    let privateKey = "replace_with_your_private_key"
    
    // ---------------------------------------------------------------------------------------------------------
    // IMPORTANT:
    // Use a valid Uplynk Preplay URL
    // ---------------------------------------------------------------------------------------------------------

    let preplayUrl = "replace_with_your_preplay_url" // <-- change this
    
    //
    // MARK: Outlets
    //
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var statusProgressBar: UIProgressView!
    
    //
    // MARK: Lifecycle methods
    //
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Verizon AVOD tutorial"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Beacons", style:.plain, target:self, action:#selector(beaconsClicked))
        
        // download engine update listener
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        
        // Ads processing update listener
        adsNotifications = VirtuosoAdsNotificationsManager.init(delegate: self)
        
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
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "SegueToBeacons"
        {
            let beaconsViewController = segue.destination as! BeaconsViewController

            beaconsViewController.setupBeacons(beaconsReported:self.beaconsReported)
        }
    }
    
    //
    // MARK: Click Handlers
    //
    
    @IBAction func deleteBtnClicked(_ sender: UIButton)
   {
       sender.isEnabled = false   // Block reentry
       
       guard let asset = self.exampleAsset else { return }
       
       self.statusLabel.text = "Deleting Asset: \(asset)"
       
       asset.delete {
           self.statusLabel.text = "Deleted."
           self.loadEngineData()
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
        
        DispatchQueue.global(qos: .background).async {
            // Important: AssetID should be unique across your video catalog
            let yourAssetID = "masked-singer-asset-1"
            
            // Create asset configuration object
            guard let config = VirtuosoAssetConfig(url: self.preplayUrl,
                                                   assetID: yourAssetID,
                                                   description: "Masked Singer",
                                                   type: kVDE_AssetType.vde_AssetTypeHLS) else {
                                                    print("create config failed")
                                                    sender.isEnabled = true
                                                    return
            }
            
            // Create ServerAds Provider for Verizon ads.
            config.adsProvider = VirtuosoVerizonAdsServerProvider(preplayUrl: self.preplayUrl)
            
            // Create asset and commence downloading.
            let _ = VirtuosoAsset.init(config: config)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.refreshView()
            }
        }
    }
    
    @objc func beaconsClicked()
    {
        self.performSegue(withIdentifier: "SegueToBeacons", sender: self)
    }
        
    //
    // MARK: Internal implementation
    //
       
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
            statusLabel.text = String(format: "%@%0.02f%% (%qi MB)%@", optionalStatus, fractionComplete*100.0, asset.currentSize/1024/1024, errorAdd)
            statusProgressBar.progress = Float(fractionComplete)
            downloadBtn.isEnabled = false
        }
        else if status == .vde_DownloadComplete {
            statusLabel.text = String(format: "%0.02f%% (%qi MB)", fractionComplete*100.0, asset.currentSize/1024/1024)
            statusProgressBar.progress = Float(fractionComplete)
        }
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // IMPORTANT:
    // Loads data from the Download Engine.
    // ------------------------------------------------------------------------------------------------------------
    private func loadEngineData()
    {
        self.error = nil

        DispatchQueue.global().async
            {
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
                        
                        if (self.exampleAsset != nil)
                        {
                            print("Ad status: \(self.adsStatusToString(self.exampleAsset!.refreshAdsStatus)).")
                        }
                                                
                        self.refreshView()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.loadEngineData() // try again
                    })
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
    
    func displayAdsStatus(asset: VirtuosoAsset, error: Error?) {
        guard let error = error else {
            self.statusLabel.text = "Ad status: \(self.adsStatusToString(asset.refreshAdsStatus))"
            return;
        }
        
        self.statusLabel.text = "Ad status: \(self.adsStatusToString(asset.refreshAdsStatus))  error:\(error.localizedDescription)"
    }
    
    func adsStatusToString(_ status: AssetAdStatus) -> String {
        switch status {
            case .queuedForRefresh:
                return "Queued for refresh"
                
            case .refreshComplete:
                return "Refresh complete"
                
            case .refreshFailure:
                return "Refresh failure"
                
            case .refreshInProcess:
                return "Refresh in process"
                
            case .uninitialized:
                return "Uninitialized"
                
            case .refreshCompleteWithErrors:
                return "Refresh complete with errors"
            
            case .downloadComplete:
                return "Download complete"
            
            case .playing:
                return "Playing"
                
            default:
                return "unknown"
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
    func downloadEngineStartupComplete(_ status: Bool) {
        loadEngineData()
    }
    
    //
    // MARK: VirtuosoAdsManagerNotificationDelegate - required methods ONLY
    //

    func adsRefreshFailure(_ asset: VirtuosoAsset, error: Error?) {
        self.displayAdsStatus(asset: asset, error: error)
    }
    
    func adsRefreshStatusUpdate(_ asset: VirtuosoAsset) {
        refreshView()
        self.displayAdsStatus(asset: asset, error: nil)
    }
    
    func adsTrackingNotification(for asset: VirtuosoAsset?, url: String, httpResponseCode: Int, userInfo: [AnyHashable : Any] = [:]) {
        
        if let logEventData = userInfo["logEventData"]
        {
            var beaconNotification:[String:Any] = ["url": url, "httpResponseCode": httpResponseCode]
            
            beaconNotification = beaconNotification.merging(logEventData as! [String:Any]) { $1 }
            
            self.beaconsReported.append(beaconNotification)
        }
    }
}

