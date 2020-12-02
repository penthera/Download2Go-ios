//
//  AppDelegate.swift
//  Example15
//
//  Created by dev on 7/24/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)          // Verbose might be overkill for Production.
        VirtuosoLogger.enableLogs(toFile: false)            // Setting to true will save Virtuoso logs to disk
        VirtuosoSettings.instance().setBool(true, forKey:"VFM_BetaFeatures.EnableClientAds")
        
        VirtuosoSettings.instance().allowRestrictedMimeTypes(forEncryptionKeys:true)
        VirtuosoSettings.instance().allowAdditionalMimeTypes(["text/html"], for:.vde_AssetTypeHLS, andDataType:.vf_DataTypeStreamCC)
        VirtuosoSettings.instance().allowAdditionalMimeTypes(["application/octet-stream"], for:.vde_AssetTypeHLS, andDataType:.vf_DataTypeManifest)
        
        return true
    }
}

