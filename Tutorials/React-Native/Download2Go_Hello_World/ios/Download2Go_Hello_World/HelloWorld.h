//
//  HelloWorld.h
//  Download2GoHelloWorld
//
//  Created by Mark S. Lee on 1/22/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelloWorld : RCTEventEmitter <VirtuosoDownloadEngineNotificationsDelegate>
@end

NS_ASSUME_NONNULL_END
