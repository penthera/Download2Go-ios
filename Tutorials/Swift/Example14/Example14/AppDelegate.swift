//
//  AppDelegate.swift
//  Example14
//
//  Created by Penthera on 7/13/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var refreshManager: VirtuosoRefreshManager?
    let delay = 10.0 * 60.0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
        // Maximum logging for debug build
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)
        #else
        // Error logging for production
        VirtuosoLogger.setLogLevel(.vl_LogError)
        #endif

        // Register Playlist delegate
        VirtuosoPlaylistManager.setDelegate(PlaylistDelegateProvider())
                
        // Register Wake Delegate to wake after App is backgrounded for some minimum delay.
        // The App must be network connected and connected to power for the wake to happen.
        refreshManager = VirtuosoRefreshManager.init(delegate: WakeDelegate(), wakeInterval: delay)
        
        return true
    }

}

