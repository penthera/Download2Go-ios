//
//  DownloadComplete.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/5/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

//
// Adopted December 6, 2021
//

#import <VirtuosoClientDownloadEngine/VirtuosoAssetEvent.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Base classs for Download Complete Analytics Events
 *  @discussion Base classs for Download Complete Analytics Events
 */
@interface DownloadComplete : VirtuosoAssetEvent

/*!
 *  @abstract Duration of asset
 */
@property (nonatomic,readonly) double asset_duration;

/*!
 *  @abstract Download elapse time
 */
@property (nonatomic,readonly) NSInteger download_elapse;

/*!
 *  @abstract Size of asset
 */
@property (nonatomic,readonly) NSInteger current_size;

@end

NS_ASSUME_NONNULL_END
