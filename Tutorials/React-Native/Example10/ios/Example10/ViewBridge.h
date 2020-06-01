//
//  ViewBridge.h
//  Example10
//
//  Created by Penthera on 4/01/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewBridge : RCTEventEmitter <VirtuosoDownloadEngineNotificationsDelegate>

@end

NS_ASSUME_NONNULL_END
