//
//  AppDelegate.swift
//  Example1.5
//
//  Created by dev on 7/24/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Enables logging
        VirtuosoLogger.enable = true
        
        // Best practice for logging delegte is to process callbacks on a background thread,
        // as demonstrated here. Default for VirtuosoLogger.notificationQueue is main thread
        // which may impact rendering of the UI.
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1;
        queue.name = "sample.loggging.delgate.queue"
        queue.qualityOfService = .background
        VirtuosoLogger.notificationQueue = queue
        
        #if DEBUG
        // Maximum logging for debug build
        VirtuosoLogger.setLogLevel(.vl_LogVerbose)
        #else
        // Error logging for production
        VirtuosoLogger.setLogLevel(.vl_LogError)
        #endif
        
        #if DEBUG
        // Will log to file created in Application Documents folder,
        // don't use this for Production
        VirtuosoLogger.enableLogs(toFile: true)
        #endif
        
        // SampleLoggingDelegate will get invoked as a logging delegate. 
        VirtuosoLogger.addDelegate(SampleLoggingDelegate())
        
        return true
    }
    
}


