//
//  AppDelegate.swift
//  Download2GoHelloWorld
//
//  Created by Penthera on 11/15/18.
//  Copyright © 2018 penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VirtuosoLoggerDelegate {

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

