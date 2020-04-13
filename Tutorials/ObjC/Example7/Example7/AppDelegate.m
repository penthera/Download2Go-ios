//
//  AppDelegate.m
//  Example7
//
//  Created by Penthera on 07/10/18.
//  Copyright © 2018 penthera. All rights reserved.
//

#import "AppDelegate.h"
#import "PlaylistDelegateProvider.h"

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
    //[VirtuosoSettings.instance setBool:YES forKey:@"VFM_Undocumented_EnableClientAds"];
    
    // Register Playlist delegate
    
    [VirtuosoPlaylistManager setDelegate:[[PlaylistDelegateProvider alloc] init]] ;
    
    return YES;
}


@end
