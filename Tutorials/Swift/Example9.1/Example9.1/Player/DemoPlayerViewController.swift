//
//  AppDelegate.swift
//  Example9
//
//  Created by Penthera on 2/7/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

import VirtuosoClientDownloadEngine

class DemoPlayerViewController: VirtuosoPlayerViewController {
        
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.play()
    }

}
