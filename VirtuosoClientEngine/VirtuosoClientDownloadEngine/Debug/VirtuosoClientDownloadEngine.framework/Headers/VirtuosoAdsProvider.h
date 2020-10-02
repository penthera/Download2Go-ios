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
 * @abstract Base class for AdsProviders
 *
 * @discussion This class defines the comon methods and properties shared by all AdsProviders.
 */
@interface VirtuosoAdsProvider : NSObject

/*!
 *  @abstract True if Ads are required for this Asset
 *
 *  @discussion This property can be used to check whether Ads are required for this Asset.
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
 *  @abstract Class convienence method to create a Google Client-Side Ads Provider
 *
 *  @param refreshUrl Ads refresh url
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)clientGoogleAdsWithRefreshUrl:(NSString*_Nonnull)refreshUrl;

/*!
 *  @abstract Class convienence method to create a Google Server-Side Ads Provider
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)serverGoogleAds;

/*!
 *  @abstract Class convienence method to create a Verizon Server Side Ads Provider
 *
 * @param prePlayURL - PrePlay URL for the Ads.
 *
 *  @return A new VirtuosoAdsProvider instance, or nil if failure.
 */
+(VirtuosoAdsProvider*_Nullable)serverVerizonAdsWithPreplayUrl:(nonnull NSString*)prePlayURL;

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

/*!
 *  @abstract Time interval when the ad was last refreshed
 */
@property (nonatomic, assign)double refreshedOnTimeInterval;

/*!
 *  @abstract Date representation of time interval when the ad was last refreshed
 */
@property (nonatomic,readonly)NSDate* _Nullable refreshedDate;

/*!
 *   @abstract Flag indicating whether the ad has expired
 *
 *   @discussion Use of ad expirations is controlled by the VFM_EnableAdExpiration setting.  See the VirtuosoAsset isAdExpired property for more details.
 */
@property (nonatomic,readonly)Boolean isExpired;

/*!
 *  @abstract Date when the ad will expire.  This derived by adding the refreshIntervalInDays to the refreshedDate
 */
@property (nonatomic,readonly)NSDate* _Nullable expirationDate;

/*!
 *  @abstract Total duration of all ads within the asset, in seconds.
 *
 *  @discussion Total duration is reported in 2 custom events as the value ads_total_duration_seconds in ads_refresh and ads_download_complete.  These values may differ slightly because they originate from different sources.  For example with Verizon ads the value in  ads_refresh is calculated from the UpLynk JSON payload.  In ads_download_complete the value is derived from the HLS manifest.   The value returned with this property will be the same as that in the ads_download_complete event.
 *
 */
@property (nonatomic, assign)double totalDuration;

/*!
 *  @abstract Total size of all ads within the asset, in bytes.
 */
@property (nonatomic, assign)long long totalSize;

@end

#endif


