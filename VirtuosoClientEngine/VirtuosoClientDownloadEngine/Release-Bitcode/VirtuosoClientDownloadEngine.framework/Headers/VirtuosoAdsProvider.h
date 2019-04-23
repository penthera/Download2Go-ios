/*!
 *  @header VirtuosoAdsProvider
 *
 *  PENTHERA CONFIDENTIAL
 *
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  @copyright (c) 2018 Penthera Inc. All Rights Reserved.
 */


#ifndef VirtuosoAdsProvider_Included
#define VirtuosoAdsProvider_Included

#import <Foundation/Foundation.h>


@interface VirtuosoAdsProvider : NSObject

/*!
 *  @abstract BETA Feature. Class convienence method to create a server-side Ads Provider
 *
 *  @return A new VirtuosoAdsProvider object.
 */
+(VirtuosoAdsProvider* _Nonnull)serverAdsProvider;

/*!
 *  @abstract BETA Feature. Class convienence method to create a default Ads Provider
 *
 *  @return A new VirtuosoAdsProvider object.
 */
+(VirtuosoAdsProvider* _Nonnull)disableAds;

/*!
 *  @abstract BETA Feature. True if Ads are required for this Asset
 *
 *  @discussion This prperty can be used to check whether Ads are required for this Asset.
 */
@property (nonatomic, assign, readonly)Boolean requireAds;


@end


#endif


