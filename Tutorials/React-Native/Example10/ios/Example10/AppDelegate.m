//
//  AppDelegate.m
//  Example10
//
//  Created by Penthera on 4/01/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#if DEBUG
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>

static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
  InitializeFlipper(application);
#endif

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
  
  //  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  //  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
  //                                                   moduleName:@"Example10"
  //                                            initialProperties:nil];

  // Note: Intermittently seeing warning "RCTBridge required dispatch_sync to load..." from RCTModuleData.mm
  //
  //       This is a known issue.  Using this suggested code as a workaround.  The application continues to
  //       run after the warning but I hope this elminates the issue altogether.
  //
  //       See comments in RCTModuleData.mm for more information.
  
  NSURL *bundleURL;
  
  #if DEBUG
    bundleURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  #else
    bundleURL = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  #endif
    
  RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:bundleURL
                                            moduleProvider:nil
                                             launchOptions:launchOptions];
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"Example10"
                                            initialProperties:nil];
    
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
