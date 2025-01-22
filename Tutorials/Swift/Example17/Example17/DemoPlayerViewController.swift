//
//  DemoPlayerViewController.swift
//  Example17
//
//  Created by Penthera on 10/13/21.
//

import UIKit

class DemoPlayerViewController: VirtuosoPlayerViewController, VirtuosoAVAssetResourceLoaderDelegateErrorHandler {
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.play()
        
        // Redirect errors from FairPlay licensing here so we can handle reporting errors to the user.
        let asset = self.playerView.player?.currentItem?.asset as! AVURLAsset       
        if let loader = asset.resourceLoader.delegate as? VirtuosoAVAssetResourceLoaderDelegate {
            loader.errorHandler = self
        }
    }

    func resourceLoaderDelegate(_ delegate: VirtuosoAVAssetResourceLoaderDelegate, generatedError error: Error?)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "License Error", message: "An error was encountered playing this content.  Please try again later.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

