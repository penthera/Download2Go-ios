//
//  AppDelegate.swift
//  Example8.4
//
//  Created by Penthera on 2/7/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)          // Verbose might be overkill for Production.
        VirtuosoLogger.enableLogs(toFile: false)            // Setting to true will save Virtuoso logs to disk
        
        return true
    }

}

