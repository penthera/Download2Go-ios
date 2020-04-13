//
//  ViewBridge.h
//  Example1_1
//
//  Created by Penthera on 1/29/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewBridge : RCTEventEmitter <VirtuosoDownloadEngineNotificationsDelegate>

@end

NS_ASSUME_NONNULL_END
