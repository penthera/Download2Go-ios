//
//  PlayStop.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/5/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

//
// Adopted December 7, 2021
//

#import <VirtuosoClientDownloadEngine/VirtuosoAssetEvent.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Base classs for Play Stop Analytics Events
 *  @discussion Base classs for Play Stop Analytics Events
 */
@interface PlayStop : VirtuosoAssetEvent

/*!
 *  @abstract Number of seconds the asset was played
 */
@property(nonatomic,readonly) NSInteger played;

@end

NS_ASSUME_NONNULL_END
