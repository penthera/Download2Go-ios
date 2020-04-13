//
//  AppDelegate.swift
//  Example12
//
//  Created by dev on 2/3/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // For a complete example of advanced logging see Example1.5
        // Enables logging
        VirtuosoLogger.enable = true
        
        #if DEBUG
        // Maximum logging for debug build
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)
        #else
        // Error logging for production
        VirtuosoLogger.setLogLevel(.vl_LogError)
        #endif

        return true
    }
    
}

