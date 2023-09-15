//
//  AppDelegate.swift
//  Example6
//
//  Created by dev on 6/27/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)          // Verbose might be overkill for Production.
        VirtuosoLogger.enableLogs(toFile: false)            // Setting to true will save Virtuoso logs to disk
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            instance.setBool(true, forKey: "VFM_BetaFeatures.EnableClientAds")
        })
        
        return true
    }
}

