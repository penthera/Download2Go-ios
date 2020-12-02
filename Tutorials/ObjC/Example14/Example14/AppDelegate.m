//
//  AppDelegate.m
//  Example14
//
//  Created by Penthera on 7/13/20.
//  Copyright © 2020 Penthera. All rights reserved.
//
#import "AppDelegate.h"
#import "PlaylistDelegateProvider.h"
#import "WakeDelegate.h"

static NSTimeInterval delay = 10.0 * 60.0;

@interface AppDelegate() {
    VirtuosoRefreshManager* refreshManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //
    // IMPORTANT:
    // Configure Download Engine Logging
    //
    [VirtuosoLogger setLogLevel:kVL_LogVerbose];  // Verbose might be overkill for Production.
    [VirtuosoLogger enableLogsToFile:NO];
    //[VirtuosoSettings.instance setBool:YES forKey:@"VFM_Undocumented_EnableClientAds"];
    
    // Register Playlist delegate
    [VirtuosoPlaylistManager setDelegate:[[PlaylistDelegateProvider alloc] init]] ;
    
    // Register Wake Delegate to wake after App is backgrounded for some minimum delay.
    // The App must be network connected and connected to power for the wake to happen.
    refreshManager = [[VirtuosoRefreshManager alloc]initWithDelegate:[WakeDelegate new] wakeInterval:delay];
    return YES;
}


@end
