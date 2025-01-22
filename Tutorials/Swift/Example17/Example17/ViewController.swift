//
//  ViewController.swift
//  Example17
//
//  Created by Penthera on 10/13/21.
//

import UIKit

class ViewController: UIViewController, VirtuosoDownloadEngineNotificationsDelegate, VirtuosoRenditionSelectionDelegate,
                      UIPickerViewDelegate, UIPickerViewDataSource{
    // ---------------------------------------------------------------------------------------------------------
    // IMPORTANT:
    // The following three values must be initialzied, please contact support@penthera.com to obtain these keys
    // ---------------------------------------------------------------------------------------------------------
    let publicKey = "replace_with_your_public_key"  // <-- change this
    let privateKey = "replace_with_your_private_key" // <-- change this
   
    var error:VirtuosoError?
    
    // Bandwidths available for this asset
    
    let bandwidths = [258157 ,520929, 831270, 1144430, 1558322, 4149264, 6214307, 10285391]
    var bandwidthIndex = 0
    
    //
    // MARK: Instance data
    //
    var exampleAsset: VirtuosoAsset?
    var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var statusProgressBar: UIProgressView!
    @IBOutlet weak var bandwidthPicker: UIPickerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // download engine update listener
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        self.statusLabel.text = "Starting Engine..."
        
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
                let alert = UIAlertController(title: "Setup Required",
                                              message: "Please contact support@penthera.com to setup the backplaneUrl, publicKey, and privateKey",
                                              preferredStyle: .alert)
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
        
        // Set the rendition delegate
        
        VirtuosoAsset.renditionSelectionDelegate = self
        
        bandwidthPicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // MARK: UIPickerViewDataSource
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bandwidths.count
    }
    
    // MARK: UIPickerViewDelegate

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var bandwidth = "unknown"
        
        if (row >= 0 && row < bandwidths.count) {
            bandwidth = "\(bandwidths[row])"
        }
        
        return bandwidth
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row >= 0 && row < bandwidths.count) {
            bandwidthIndex = row
            
            refreshView()
        }
    }
    
    // MARK: Click Handlers
    
    @IBAction func deleteBtnClicked(_ sender: UIButton)
    {
        sender.isEnabled = false   // Block reentry
        
        guard let asset = self.exampleAsset else { return }
        statusLabel.text = "Deleting Asset: \(asset)"

        self.exampleAsset?.delete(onComplete: {
            self.statusLabel.text = "Deleted"
            self.loadEngineData()
        })
    }
    
    @IBAction func playBtnClicked(_ sender: UIButton)
    {
        guard let asset = self.exampleAsset else {
            return
        }
        
        playAsset(asset: asset)
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
            let yourAssetID = "sintel-asset-1"
            
            // Create asset configuration object
            guard let config = VirtuosoAssetConfig(url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                                                   assetID: yourAssetID,
                                                   description: "Sintel",
                                                   type: kVDE_AssetType.vde_AssetTypeHLS)
            else {
                print("create config failed")
                sender.isEnabled = true
                return
            }
            
            // Set the userInfo dictionary to track which bandwidth was selected to download.
            //
            // The userInfo dictionary is accessible via the asset and the asset is passed as a parameter
            // to the rendition selection delegate.
            

            config.userInfo = ["bandwidth_requested": self.bandwidths[self.bandwidthIndex]]
            
            // Create asset and commence downloading.
            self.exampleAsset = VirtuosoAsset.init(config: config)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.refreshView()
            }
        }
    }
    
    func displayAsset(asset: VirtuosoAsset)
    {
        let fractionComplete = asset.fractionComplete
        let status = asset.status
        var errorAdd = "";
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
    
    func playAsset(asset: VirtuosoAsset) {
        
        VirtuosoAsset.isPlayable(asset) { (playable) in
            if playable {
                if asset.type != .vde_AssetTypeHSS {
                    let demoPlayer = DemoPlayerViewController()
                    
                    asset.play(using: .vde_AssetPlaybackTypeLocal,
                               andPlayer: demoPlayer as VirtuosoPlayer,
                               onSuccess: {
                                    // Present the player
                        
                                    self.present(demoPlayer, animated: true, completion: nil)
                                },
                               onFail: {
                                    self.exampleAsset = nil
                                    self.error = nil
                                })
    
                }
            }
        }
    }
    
    
    
    private func loadEngineData()
    {
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
                    
                    self.bandwidthIndex = 0
                    
                    if (self.exampleAsset != nil) {
                        if let bandwidthRequested = self.exampleAsset!.userInfo?["bandwidth_requested"] as? Int {
                            for i in 0..<self.bandwidths.count {
                                if self.bandwidths[i] == bandwidthRequested {
                                    self.bandwidthIndex = i
                                    
                                    break
                                }
                            }
                        }
                    }
                    
                    self.bandwidthPicker.selectRow(self.bandwidthIndex, inComponent: 0, animated: false)
                    
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
        guard let asset = exampleAsset else {
            self.statusLabel.text = "Ready to download"
            self.statusProgressBar.progress = 0
            
            setEnabledAppearance(control: downloadBtn, enabled: true)
            setEnabledAppearance(control: playBtn, enabled: false)
            setEnabledAppearance(control: deleteBtn, enabled: (nil != self.error ? true : false))
            
            bandwidthPicker.isUserInteractionEnabled = true
            
            return;
        }
        
        let downloadInProcess = (asset.fractionComplete < 1.0 ? true : false)
        
        self.statusLabel.text = (downloadInProcess ?
                                 "Downloading (Bandwidth = \(bandwidths[bandwidthIndex]))..." :
                                 "Ready to play (Bandwidth = \(bandwidths[bandwidthIndex]))")
                                    
        setEnabledAppearance(control: deleteBtn, enabled: true)
        setEnabledAppearance(control: downloadBtn, enabled: false)
        
        bandwidthPicker.isUserInteractionEnabled = false
        
        statusProgressBar.progress = Float(asset.fractionComplete)
        
        VirtuosoAsset.isPlayable(asset) { (playable) in
            self.setEnabledAppearance(control: self.playBtn, enabled: playable)
        }
    }
    
    func setEnabledAppearance(control:UIControl, enabled:Bool)
    {
        control.isEnabled = enabled
        control.backgroundColor = (enabled ? UIColor.black : UIColor.lightGray)
    }
    
    //
    // MARK: VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY
    //
    
    // ------------------------------------------------------------------------------------------------------------
    //  Called whenever the Engine starts downloading a VirtuosoAsset object.
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset)
    {
        displayAsset(asset: asset)
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever the Engine reports progress for a VirtuosoAsset object
    // ------------------------------------------------------------------------------------------------------------
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
    
    // ------------------------------------------------------------------------------------------------------------
    // Called when an asset is being processed after background transfer
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset)
    {
        displayAsset(asset: asset)
        refreshView()
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
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever the Engine reports a VirtuosoAsset as complete
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset)
    {
        // Download is complete
        displayAsset(asset: asset)
        refreshView()
        loadEngineData()
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever an asset is added to the Engine
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineInternalQueueUpdate() {
        loadEngineData()
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever Engine start completes
    // ------------------------------------------------------------------------------------------------------------
    
    func downloadEngineStartupComplete(_ succeeded: Bool) {
        loadEngineData()
    }

    //
    // MARK: VirtuosoRenditionSelectionDelegate
    //
    
    func selectRendition(fromAvailableRenditions renditions: [VirtuosoVideoRendition], for asset: VirtuosoAsset) -> VirtuosoVideoRendition? {
        var selectedRendition:VirtuosoVideoRendition? = nil
        
        // Prefer HLS average bandwidth over bandwidth (peak) if it is specified in the manifest
        
        if let bandwidthRequested = asset.userInfo?["bandwidth_requested"] as? Int {
            for rendition in renditions {
                if ((rendition.averageBandwidth > 0 && rendition.averageBandwidth == bandwidthRequested) ||
                    rendition.bandwidth == bandwidthRequested)
                {
                    selectedRendition = rendition
                    
                    break
                }
            }
        }
        
        return selectedRendition
    }
}

