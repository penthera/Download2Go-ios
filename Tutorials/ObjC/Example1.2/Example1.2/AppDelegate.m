//
//  AppDelegate.m
//  Example1.2
//
//  Created by Penthera on 7/18/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

@import VirtuosoClientDownloadEngine;
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // For customer safety, Virtuoso disables download over cell data by default.
    // For purposes of this tutorial, we'll just enable it in case you don't have access
    // to wifi just now.
    
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
            [instance overrideDownloadOverCellular:YES];
    }];
        
    return YES;
}

@end
