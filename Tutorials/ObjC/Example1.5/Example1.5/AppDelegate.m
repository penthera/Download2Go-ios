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
