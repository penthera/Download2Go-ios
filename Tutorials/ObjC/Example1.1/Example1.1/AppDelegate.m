//
//  AppDelegate.m
//  Example1.1
//
//  Created by Penthera on 7/17/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "AppDelegate.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // For more detailed info on advanced Logging see Tutorial Example1.5
    
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
    
    return YES;
}


@end
