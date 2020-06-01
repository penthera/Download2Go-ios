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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 */

#ifndef VirtuosoAdsProvider_Included
#define VirtuosoAdsProvider_Included

#import <Foundation/Foundation.h>

@class VirtuosoAsset;

/*!
 *  @abstract Base class for all AdsProviders
 *
 */
@interface VirtuosoAdsProvider : NSObject

/*!
 *  @abstract True if Ads are required for this Asset
 *
 *  @discussion This prperty can be used to check whether Ads are required for this Asset.
 */
@property (nonatomic, assign, readonly)Boolean requireAds;

@property (nonatomic, copy, readonly)NSString* _Nullable providerService;

/*!
 * @abstract Url for Ads Map needed during Playback
 *
 * @param asset asset for ads playback
 */
-(NSString* _Nullable) playbackAdsUrl:(VirtuosoAsset* _Nonnull)asset;

/*!
 *  @abstract Class convienence method to create a client Freewheel Ads provider
 *
 *  @param refreshUrl Ads refresh url
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)clientFreewheelAdsWithRefreshUrl:(NSString*_Nonnull)refreshUrl;

/*!
 *  @abstract Class convienence method to create a client Google Ads provider
 *
 *  @param refreshUrl Ads refresh url
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)clientGoogleAdsWithRefreshUrl:(NSString*_Nonnull)refreshUrl;

/*!
 *  @abstract Class convienence method to create a server Google Ads provider
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)serverGoogleAds;

/*!
 *  @abstract Class convienence method to create a server Verizon Ads provider
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)serverVerizonAds;

/*!
 * @abstract Allows Provider to update the Tracking URL with any appropriate information before posting.
 *
 * @discussion This callback is invoked when Ads Tracking URL's are requested from the Video player. The returned url will be reported once the Device receives network connectivity. Returning nil will result in the caller using the original unchanged url.
 *
 * @param asset - Asset reporting an Ads tracking event.
 *
 * @param url - Tracking url that will be reported.
 *
 * @return Updated url. Returning nil will result in using the original, unchanged url.
 *
 */
-(NSString*_Nullable)prepareTrackingUrl:(VirtuosoAsset*_Nonnull)asset url:(NSString*_Nonnull)url;

/*!
 *  @abstract Interval in days for when Ads should be refreshed
 */
@property (nonatomic, assign)NSInteger refreshIntervalInDays;

@end

#endif


