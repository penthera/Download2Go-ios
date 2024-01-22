//
//  AssetRemovedFromQueue.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/5/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

//
// Adopted December 8, 2021
//

#import <VirtuosoClientDownloadEngine/VirtuosoAssetEvent.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Base classs for Asset Removed from Queue Analytics Events
 *  @discussion Base classs for Asset Removed from Queue Analytics Events
 */
@interface AssetRemovedFromQueue : VirtuosoAssetEvent

/*!
 *  @abstract Size of asset when it was removed from the Queue
 */
@property (nonatomic,readonly) NSInteger downloaded;

@end

NS_ASSUME_NONNULL_END
