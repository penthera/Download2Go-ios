//
//  VirtuosoGoogleoAdsClientProvider.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 6/14/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "VirtuosoAdsClientProvider.h"
NS_ASSUME_NONNULL_BEGIN

/*!
*
*  @typedef VirtuosoGoogleAdsClientProvider
*
*  @abstract Ads provider for Google Client-Side ads
*/
@interface VirtuosoGoogleAdsClientProvider : VirtuosoAdsClientProvider

-(instancetype _Nullable)initWithRefreshUrl:(NSString*_Nonnull)refreshUrl;

-(NSString*_Nullable)prepareTrackingUrl:(VirtuosoAsset*_Nonnull)asset url:(NSString*_Nonnull)url;

@end

NS_ASSUME_NONNULL_END
