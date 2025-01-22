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
    
    // Register Playlist delegate
    
    [VirtuosoPlaylistManager setDelegate:[[PlaylistDelegateProvider alloc] init]] ;
    
    return YES;
}


@end
