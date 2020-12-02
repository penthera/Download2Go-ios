//
//  VirtuosoPlayerViewAdsDelegateProvider.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 5/29/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@class VirtuosoClientAdInfo;
@class VirtuosoAsset;

/*!
 *  @abstract Process client side ads for Playback.
 *
 */
@interface VirtuosoClientAdsPlaybackProvider : NSObject

/*!
 *  @abstract Asset to process client ads for.
 */
@property (nonatomic, strong, readonly)VirtuosoAsset* asset;

/*!
 *  @abstract Asset to process client ads for.
 *
 *  @param asset asset for which client ads exist
 *
 *  @return instance of this object. nil on failure to create which will only happen if the asset is invalid.
 */
-(instancetype _Nullable)initWithAsset:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Begins processing of client ads. The returned array contains client ads.
 *
 *  @return Mutable array of VirtuosoClientAdInfo for the ads. A mutable array is provided so that the caller can pop ads off the array as they are played.
 */
-(NSMutableArray<VirtuosoClientAdInfo*>*)process;

@end

NS_ASSUME_NONNULL_END
