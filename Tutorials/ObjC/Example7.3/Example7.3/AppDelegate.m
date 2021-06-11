//
//  AppDelegate.m
//  Example7.3
//
//  Created by Penthera on 4/13/21.
//

#import "AppDelegate.h"
#import "PlaylistDelegateProvider.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#ifdef DEBUG
    [VirtuosoLogger setLogLevel:kVL_LogVerbose];  // Verbose is helpful for Debugging
    [VirtuosoLogger enableLogsToFile:YES];
#else
    [VirtuosoLogger setLogLevel:kVL_LogWarning];  // Warning is better for Production
    [VirtuosoLogger enableLogsToFile:NO];
#endif

    //
    // Register Playlist delegate
    //
    [VirtuosoPlaylistManager setDelegate:[[PlaylistDelegateProvider alloc] init]] ;

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
