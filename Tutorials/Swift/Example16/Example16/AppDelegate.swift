//
//  AppDelegate.swift
//  Example16
//
//  Created by Mark S. Lee on 10/13/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        //
        // IMPORTANT:
        // Configure Download Engine Logging
        //
        
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)  // Verbose might be overkill for Production.
        VirtuosoLogger.enableLogs(toFile: false)
        
        return true
    }
}

