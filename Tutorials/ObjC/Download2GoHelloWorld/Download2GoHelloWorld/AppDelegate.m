//
//  AppDelegate.m
//  Download2GoHelloWorld-Objcå
//
//  Created by Penthera on 11/27/18.
//  Copyright © 2018 penthera. All rights reserved.
//

#import "AppDelegate.h"

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

    return YES;
}


@end
