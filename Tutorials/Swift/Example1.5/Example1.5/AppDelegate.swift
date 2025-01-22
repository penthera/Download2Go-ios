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
        
        // Best practice for logging delegte is to process callbacks on a background thread,
        // as demonstrated here. Default for VirtuosoLogger.notificationQueue is main thread
        // which may impact rendering of the UI.
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1;
        queue.name = "sample.loggging.delgate.queue"
        queue.qualityOfService = .background
        VirtuosoLogger.notificationQueue = queue
                
        // SampleLoggingDelegate will get invoked as a logging delegate. 
        VirtuosoLogger.addDelegate(SampleLoggingDelegate())
        
        return true
    }
    
}


