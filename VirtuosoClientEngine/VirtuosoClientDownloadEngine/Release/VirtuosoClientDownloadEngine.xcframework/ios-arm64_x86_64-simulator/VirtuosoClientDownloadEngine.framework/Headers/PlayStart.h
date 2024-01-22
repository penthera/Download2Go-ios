//
//  PlayStart.h
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
 *  @abstract Base classs for Play Start Analytics Events
 *  @discussion Base classs for Play Start Analytics Events
 */
@interface PlayStart : VirtuosoAssetEvent

/*!
 *  @abstract Time to first frame.
 */
@property(nonatomic,readonly) double ttff;

@end

NS_ASSUME_NONNULL_END
