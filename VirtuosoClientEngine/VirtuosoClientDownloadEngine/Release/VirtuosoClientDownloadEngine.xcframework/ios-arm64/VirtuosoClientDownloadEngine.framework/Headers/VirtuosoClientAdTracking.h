//
//  VirtuosoClientAdTracking.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 5/29/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtuosoClientAdTracking : NSObject

@property (nonatomic, copy, readonly)NSString* url;
@property (nonatomic, copy, readonly)NSString* _Nullable event;

-(instancetype _Nullable)initWithUrl:(NSString*)url withEvent:(NSString* _Nullable)event;

-(Boolean)isPlaybackEvent;

@end

NS_ASSUME_NONNULL_END
