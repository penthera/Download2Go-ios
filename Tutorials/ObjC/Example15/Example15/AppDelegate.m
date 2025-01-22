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
    
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        [instance setBool:YES forKey:@"VFM_BetaFeatures.EnableClientAds"];
        
        [instance allowRestrictedMimeTypesForEncryptionKeys:YES];
        [instance allowAdditionalMimeTypes:@[@"text/html"] forAssetType:kVDE_AssetTypeHLS andDataType:kVF_DataTypeStreamCC];
        [instance allowAdditionalMimeTypes:@[@"application/octet-stream"] forAssetType:kVDE_AssetTypeHSS andDataType:kVF_DataTypeManifest];
        
            // kVF_DataTypeStreamAudio
        [instance allowAdditionalMimeTypes:@[@"application/octet-stream"] forAssetType:kVDE_AssetTypeHLS andDataType:kVF_DataTypeManifest];
    }];
        
    return YES;
}


@end
