//
//  AppDelegate.swift
//  Example11
//
//  Created by dev on 1/31/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            instance.setBool(true, forKey: "VFM_Undocumented_EnableClientAds")
        })
            
        return true
    }

}

