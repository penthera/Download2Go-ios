//
//  AppDelegate.swift
//  Example7
//
//  Created by dev on 7/1/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            instance.setBool(true, forKey: "VFM_Undocumented_EnableClientAds")
        })
        
        // Register Playlist delegate
        VirtuosoPlaylistManager.setDelegate(PlaylistDelegateProvider())
        
        return true
    }

}

