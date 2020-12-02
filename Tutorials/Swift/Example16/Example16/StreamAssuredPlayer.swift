//
//  StreamAssuredPlayer.swift
//  Example16
//
//  Created by Mark S. Lee on 10/14/20.
//

import UIKit
import AVKit

class StreamAssuredPlayer: UIViewController {

    private static var StreamAssurePlayerTimeControlStatusObservationContext = 0
    
    var manifestURL:String?
    var playerVC:AVPlayerViewController?
    var sam:StreamAssuredManager?
    var startupHUD:MBProgressHUD?
    var started:Bool = false
    var isStopped:Bool = false
    var isRestartedPlayback = false
               
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        // This button simply hides the back button which is defaulted for pushed views
        //
        let hide = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(playStreamAssured))
        
        self.navigationItem.leftBarButtonItem = hide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.started {
            self.stopPlayback()
        }
        else {
            self.playStreamAssured()
        }
    }
    
    // MARK: - Local methods
        
    @objc func playStreamAssured() {
        if self.playerVC != nil {
            return
        }
       
        self.startupHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.startupHUD!.labelText = "Starting Sam"
        
        StreamAssuredManager.isNetworkReady( {(success:Bool) -> Void in
            
            self.startupHUD!.hide(true)
            self.startupHUD = nil
            
            if !success {
                let alert:UIAlertController = UIAlertController(title: "Network Unreachable",
                                                                message: "Unable to initialize SAM while Network is unreachable.",
                                                                preferredStyle: .alert)
                
                let ok:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: {(action:UIAlertAction) -> Void in
                    self.stopPlayback()
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            var error:NSError? = nil
            
            self.sam = StreamAssuredManager.init(manifestURL: self.manifestURL!, config: StreamAssuredConfig(), error: &error)
            
            if self.sam == nil {
                let alert:UIAlertController = UIAlertController(title: "SAM Error",
                                                                message: "SAM Failed to initialize. \(error!.localizedDescription) Check logs.",
                                                                preferredStyle: .alert)
                
                let ok:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: {(action:UIAlertAction) -> Void in
                    self.stopPlayback()
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            self.startPlayback()
            
            return
        })
    }
    
    func stopPlayback() {
        self.playerVC?.player?.pause()
        self.playerVC?.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: &StreamAssuredPlayer.StreamAssurePlayerTimeControlStatusObservationContext)
        self.playerVC?.player = nil
        self.playerVC = nil
        self.sam!.shutdown()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func startPlayback() {
        
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.startPlayback()
            }
            
            return
        }
        
        if self.playerVC == nil {
            //
            // Initial creation of the view
            //
            self.playerVC = AVPlayerViewController()
            self.playerVC?.player = AVPlayer(url: URL(string: self.sam!.streamingURL)!)
            
            self.playerVC?.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new], context: &StreamAssuredPlayer.StreamAssurePlayerTimeControlStatusObservationContext)
            
            self.present(self.playerVC!, animated: true, completion: {() -> Void in
                self.playerVC?.player?.seek(to: .zero, completionHandler: {(Bool) -> Void in
                    self.playerVC?.player?.play()
                    self.started = true
                })
            })
        }
        else {
            //
            // Refresh of the view following playback stall
            //

            self.playerVC?.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: &StreamAssuredPlayer.StreamAssurePlayerTimeControlStatusObservationContext)

            let currentTime:CMTime? = self.playerVC?.player?.currentTime()

            self.playerVC?.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new], context: &StreamAssuredPlayer.StreamAssurePlayerTimeControlStatusObservationContext)

            self.playerVC?.player?.seek(to: currentTime!, completionHandler: {(Bool) -> Void in
                self.playerVC?.player?.play()
                self.started = true
            })
        }
    }
    
    func restartPlayback() {
        
        weak var weakSelf:StreamAssuredPlayer? = self
        
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + .seconds(3)) {
            
            if weakSelf == nil {
                return
            }
            
            if weakSelf!.isStopped {
                return
            }
            
            if weakSelf!.playerVC?.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                if weakSelf!.isRestartedPlayback {
                    weakSelf!.restartPlayback()
                    
                    return
                }
                    
                print("Asset playback stalled. Waiting for Network connection to restart playback. manifestURL: \(self.manifestURL!)")
                
                StreamAssuredManager.isNetworkReady( {(success:Bool) -> Void in
                    if success {
                        weakSelf!.isRestartedPlayback = true
                        print("Attempting playback restart following stalled playback. manifestURL: \(self.manifestURL!)")
                        weakSelf!.startPlayback()
                        weakSelf!.restartPlayback()
                    }
                    else {
                        weakSelf!.restartPlayback()
                    }
                })
            }
            else {
                if weakSelf!.isRestartedPlayback {
                    weakSelf!.isRestartedPlayback = false;
                
                    print("Successfully restarted player following stall. manifestURL: \(self.manifestURL!)")
                }
                else  {
                    print("Restart requested, but player recovered without restarting. manifestURL: \(self.manifestURL!)")
                }
            }
        }
    }
    
    
// MARK: - KVO to handle stalling
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard context == &StreamAssuredPlayer.StreamAssurePlayerTimeControlStatusObservationContext else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
        
        if keyPath == "timeControlStatus" {
            let timeControlStatus:AVPlayer.TimeControlStatus? = (object as? AVPlayer)?.timeControlStatus
                        
            print("AVPlayer Time Control Status Update: \(timeControlStatus!.rawValue), SAM Player started: \(self.started)")
            
            if self.started && timeControlStatus! == .waitingToPlayAtSpecifiedRate {
                self.restartPlayback()
            }
        }
    }
}
