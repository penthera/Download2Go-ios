//
//  DemoPlayerViewController.swift
//  Download2GoHelloWorld
//
//  Created by Penthera on 12/06/18.
//  Copyright © 2018 penthera. All rights reserved.
//

import UIKit

class DemoPlayerViewController: VirtuosoPlayerViewController {
        
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.play()
    }

}
