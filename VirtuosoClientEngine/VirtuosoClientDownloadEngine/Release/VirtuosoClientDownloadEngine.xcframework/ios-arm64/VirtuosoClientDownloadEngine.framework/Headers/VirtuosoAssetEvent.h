//
//  VirtuosoAssetEvent.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/8/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

#import <VirtuosoClientDownloadEngine/VirtuosoBaseEvent.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Base classs for Asset Analytics Events
 *
 *  @discussion Base class for Asset Analytics Events.
 */

@interface VirtuosoAssetEvent : VirtuosoBaseEvent

/*!
 *  @abstract Asset ID for which the event was reported
 */
@property (nonatomic,readonly,nonnull) NSString* asset_id;

/*!
 *  @abstract Asset UUID for which the event was reported
 */
@property (nonatomic,readonly,nonnull) NSString* asset_uuid;

@end

NS_ASSUME_NONNULL_END
