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
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            instance.setBool(true, forKey:"VFM_BetaFeatures.EnableClientAds")
            
            instance.allowRestrictedMimeTypes(forEncryptionKeys:true)
            instance.allowAdditionalMimeTypes(["text/html"], for:.vde_AssetTypeHLS, andDataType:.vf_DataTypeStreamCC)
            instance.allowAdditionalMimeTypes(["application/octet-stream"], for:.vde_AssetTypeHLS, andDataType:.vf_DataTypeManifest)
        })
            
        return true
    }
}

