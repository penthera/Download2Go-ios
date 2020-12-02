//
//  ViewController.swift
//  Example16
//
//  Created by Mark S. Lee on 10/13/20.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, VirtuosoDownloadEngineNotificationsDelegate {

    // ---------------------------------------------------------------------------------------------------------
    // IMPORTANT:
    // The following three values must be initialzied, please contact support@penthera.com to obtain these keys
    // ---------------------------------------------------------------------------------------------------------
    let backplaneUrl = "https://qa.penthera.com"                                        // <-- change this
    let publicKey = "c9adba5e6ceeed7d7a5bfc9ac24197971bbb4b2c34813dd5c674061a961a899e"  // <-- change this
    let privateKey = "41cc269275e04dcb4f2527b0af6e0ea11d227319fa743e4364255d07d7ed2830" // <-- change this
    
    // MARK: - Instance Data
    
    var manifestURLs: [(name: String, url: String)] = []
    var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!
    
    // MARK: - Outlets
    
    @IBOutlet weak var manifestPickerView: UIPickerView!
    @IBOutlet weak var urlLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadManifestURLs()
        
        manifestPickerView.delegate = self
        manifestPickerView.dataSource = self
        
        manifestPickerView.selectRow(0, inComponent: 0, animated: true)
        
        urlLabel.text = manifestURLs[0].url
        
        // download engine update listener
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        
        // Enable the engine
        VirtuosoDownloadEngine.instance().enabled = true
        
        // Backplane permissions require a unique user-id for the full range of captabilities support to work
        // Production code that needs this will need a unique customer ID.
        // For demonstation purposes only, we use the device name
        let userName = UIDevice.current.name;
        
        guard let config = VirtuosoEngineConfig(user: userName, backplaneUrl: self.backplaneUrl, publicKey: self.publicKey, privateKey: self.privateKey)
        else {
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
                print("Startup succeeded.")
            } else {
                print("Startup encountered error.")
            }
        }
        
        // We'll use a notification to kick off our player in order to give the StreamAssured Manager time to start up.
        
        NotificationCenter.default.addObserver(self, selector: #selector(playStreamAssuredNotification), name: Notification.Name("Tutorial_PlayStreamAssured"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Picker View
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
   
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < manifestURLs.count {
            urlLabel.text = manifestURLs[row].url
            
            return manifestURLs[row].name
        }
        
        return nil
    }
   
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var updatedView: UILabel? = (view as? UILabel)

        if updatedView == nil {
            updatedView = UILabel()
            updatedView?.font = UIFont.systemFont(ofSize: 12.0)
            updatedView?.textAlignment = .center
            updatedView?.text = manifestURLs[row].name
        }

        return updatedView!
    }
      
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < manifestURLs.count {
            urlLabel.text = manifestURLs[row].url
        }
    }
    
    // MARK: - Picker View Data Source
      
    // returns the number of 'columns' to display.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // returns the # of rows in each component..
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return manifestURLs.count;
    }
    
    // MARK: - Actions
   
    @IBAction func playURL(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("Tutorial_PlayStreamAssured"), object: nil, userInfo: ["url": self.urlLabel.text!])
    }
    
    // MARK: - Local Methods
    
    func loadManifestURLs() {
        
        manifestURLs.append((name: "How To Train Your Dragon HLS Relative URLs", url:"http://hls-vbcp.s3.amazonaws.com/httyd_rel.m3u8"))
        manifestURLs.append((name:"Iron Man 2 HLS Relative URLs", url:"http://hls-vbcp.s3.amazonaws.com/im2_rel.m3u8"))
        manifestURLs.append((name:"True Blood HLS Encrypted Absolute URLs", url:"http://hls-vbcp.s3.amazonaws.com/tb_enc.m3u8"))
        manifestURLs.append((name:"Basic CC Test", url:"http://hls-vbcp.s3.amazonaws.com/cc_test/a.m3u8"))
        manifestURLs.append((name:"CBS Codec+IFrames (Dolby Digital Audio ac3)", url:"http://hls-vbcp.s3.amazonaws.com/cbs/multi-codec-test/Manifest-CnC.m3u8"))
        manifestURLs.append((name:"Chappie HD (361 Seg)", url:"http://hls-vbcp.s3.amazonaws.com/chappie/chappie_twenty_sec/prog_index.m3u8"))
        manifestURLs.append((name:"Kung Fu Dragon 512 Kbps (5177 Seg)", url:"http://hls-vbcp.s3.amazonaws.com/dragon_one_sec/prog_index.m3u8"))
        manifestURLs.append((name:"Lady Frankenstein 128 Kbps (503 Seg)", url:"http://hls-vbcp.s3.amazonaws.com/frankenstein_ten_sec/prog_index.m3u8"))
    }

    @objc func playStreamAssuredNotification(notice:Notification) {
        if let manifestURL = notice.userInfo?["url"] as? String? {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.playStreamAssured(manifestURL: manifestURL!)
            }
        }
    }
        
    func playStreamAssured(manifestURL:String?) {
        if let view = storyboard!.instantiateViewController(withIdentifier: "StreamAssuredPlayer") as? StreamAssuredPlayer {
            view.manifestURL = manifestURL
        
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
    
    // MARK: - VirtuosoDownloadEngineNotificationsDelegate - required methods ONLY
    
    // ------------------------------------------------------------------------------------------------------------
    //  Called whenever the Engine starts downloading a VirtuosoAsset object.
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset){
        return
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever the Engine reports progress for a VirtuosoAsset object
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineProgressUpdated(for asset: VirtuosoAsset){
        return
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // Called when an asset is being processed after background transfer
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset){
        return
    }
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever the Engine reports a VirtuosoAsset as complete
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset){
        return
    }
    
    
    // ------------------------------------------------------------------------------------------------------------
    // Called whenever Engine start completes
    // ------------------------------------------------------------------------------------------------------------
    func downloadEngineStartupComplete(_ succeeded: Bool) {
        print("Download Engine Startup Completed: \(succeeded)")
    }
}

