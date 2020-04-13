//
//  AppDelegate.m
//  Example12
//
//  Created by dev on 2/3/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "AppDelegate.h"

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //
    // IMPORTANT:
    // Configure Download Engine Logging
    //
    [VirtuosoLogger setLogLevel:kVL_LogVerbose];  // Verbose might be overkill for Production.
    [VirtuosoLogger enableLogsToFile:NO];
        
    return YES;
}


@end
