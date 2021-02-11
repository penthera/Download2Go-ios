//
//  AppDelegate.swift
//  Example9.1
//
//  Created by Penthera on 11/18/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

import VirtuosoClientDownloadEngine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
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

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

