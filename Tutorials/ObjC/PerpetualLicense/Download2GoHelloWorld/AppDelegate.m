//
//  AppDelegate.m
//  Download2GoHelloWorld-Objcå
//

@import VirtuosoClientDownloadEngine;
#import "AppDelegate.h"

@interface AppDelegate ()

@end

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
