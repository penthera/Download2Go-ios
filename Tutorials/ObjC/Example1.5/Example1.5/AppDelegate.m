//
//  AppDelegate.m
//  Example1.5
//
//  Created by dev on 7/24/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "AppDelegate.h"

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "SampleLoggingDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Important:
    // This is the master enable/disable switch.
    VirtuosoLogger.enable = YES;
    
    // Important:
    // Fine grain control for degree of information logged
    // If Logging is disabled (above) no output is sent to the debug console
#ifdef DEBUG
    // Development best practice
    [VirtuosoLogger setLogLevel:kVL_LogVerbose];
#else
    // Production best practice
    [VirtuosoLogger setLogLevel:kVL_LogError];
#endif
    
#if DEBUG
    // Will log to file created in Application Documents folder,
    // don't use this for Production
    [VirtuosoLogger enableLogsToFile:TRUE];
#endif

    // Best practice for logging delegte is to process callbacks on a background thread,
    // as demonstrated here. Default for VirtuosoLogger.notificationQueue is main thread
    // which may impact rendering of the UI.
    NSOperationQueue* queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.name = @"sample.loggging.delgate.queue";
    queue.qualityOfService = NSQualityOfServiceBackground;
    VirtuosoLogger.notificationQueue = queue;
    
    // SampleLoggingDelegate will get invoked as a logging delegate.
    [VirtuosoLogger addDelegate:[SampleLoggingDelegate new]];
    
    return YES;
}


@end
