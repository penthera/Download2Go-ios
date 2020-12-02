//
//  AppDelegate.m
//  Example15
//
//  Created by Penthera on 07/20/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import "AppDelegate.h"

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
    [VirtuosoSettings.instance setBool:YES forKey:@"VFM_BetaFeatures.EnableClientAds"];
    
    
    [[VirtuosoSettings instance] allowRestrictedMimeTypesForEncryptionKeys:YES];
    [[VirtuosoSettings instance] allowAdditionalMimeTypes:@[@"text/html"] forAssetType:kVDE_AssetTypeHLS andDataType:kVF_DataTypeStreamCC];
    [[VirtuosoSettings instance] allowAdditionalMimeTypes:@[@"application/octet-stream"] forAssetType:kVDE_AssetTypeHSS andDataType:kVF_DataTypeManifest];
    
    // kVF_DataTypeStreamAudio
    [[VirtuosoSettings instance] allowAdditionalMimeTypes:@[@"application/octet-stream"] forAssetType:kVDE_AssetTypeHLS andDataType:kVF_DataTypeManifest];
    
    
    
    return YES;
}


@end
