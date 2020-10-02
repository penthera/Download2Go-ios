//
//  VirtuosoAdsClientProvider.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 9/28/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtuosoAdsProvider.h"

#ifndef VirtuosoAdsClientProvider_Included
#define VirtuosoAdsClientProvider_Included

/*!
 *  @typedef ClientAdProvider
 *
 *  @abstract Defines the various types of Client Ads Providers
 *
 */

typedef NS_ENUM(NSInteger, ClientAdProvider)
{
    /** Undefined. */
    ClientAdProvider_Undefined,
    
    /** Freewheel Client Ads. */
    ClientAdProvider_Freewheel,
    
    /** Google Client Ads. */
    ClientAdProvider_Google
};

@class VirtuosoAsset;

/*!
* @abstract Base class for Client-Side AdsProviders
*
* @discussion This class defines the comon methods and properties shared by all Client-Side Ads providers
*/
@interface VirtuosoAdsClientProvider : VirtuosoAdsProvider

/*!
* @abstract Type of client Ad  (see enum ClientAdProvider)
*/
@property (nonatomic, assign, readonly)ClientAdProvider type;

/*!
* @abstract URL for Ads Server
*/
@property (nonatomic, copy, readonly)NSString* _Nonnull refreshUrl;

/*!
 * @abstract Creates a Google Client Ads Provider
 *
 * @param refreshUrl Url to use to retrieve Client Ads VAST/VMAP.
 *
 * @return Instance of VirtuosoAdsClientProvider
 */
+(instancetype _Nullable)GoogleAdsProviderWithRefreshUrl:(NSString* _Nonnull)refreshUrl;

/*!
 * @abstract Creates a Freewheel Client Ads Provider
 *
 * @param refreshUrl Url to use to retrieve Client Ads VAST/VMAP.
 *
 * @return Instance of VirtuosoAdsClientProvider
 */
+(instancetype _Nullable)FreewheelAdsProviderWithRefreshUrl:(NSString* _Nonnull)refreshUrl;

/*!
 * @abstract Create instance of Client-Side Ads Provider.
 *
 * @param type ClientAdProvider type indicating type of client ads provider.
 *
 * @param refreshUrl Url to use to retrieve Client Ads VAST/VMAP.
 *
 * @return True indicates success.
 */
-(instancetype _Nullable)initWithType:(ClientAdProvider)type refreshUrl:(NSString* _Nonnull)refreshUrl;

/*!
 * @abstract Refresh Client Side Ads content
 *
 * @param asset Asset to refresh Ads for
 *
 * @param error Receives any NSError* encountered during Ads refresh
 *
 * @return True indicates success.
 */
-(Boolean)refreshAds:(VirtuosoAsset*_Nonnull)asset error:(NSError*_Nullable*_Nullable)error;

/*!
 * @abstract Returns the Ads Playback URL that should be used during Ads Playback.
 *
 * @param asset Asset to refresh Ads for
 *
 * @return Url to use to retrieve Client Ads VAST/VMAP.
 */
-(NSString*_Nullable)playbackAdsUrl:(VirtuosoAsset*_Nonnull)asset;

/*!
 * @abstract Allows Provider to update the Tracking URL with any appropriate information before posting.
 *
 * @discussion This callback is invoked when Ads Tracking URL's are requested from the Video player. The returned url will be reported once the Device receives network connectivity. Returning nil will result in the caller using the original unchanged url.
 *
 * @param asset Asset reporting an Ads tracking event.
 *
 * @param url Tracking url that will be reported.
 *
 * @return Updated url. Returning nil will result in using the original, unchanged url.
 */
-(NSString*_Nullable)prepareTrackingUrl:(VirtuosoAsset*_Nonnull)asset url:(NSString*_Nonnull)url;

@end

#endif

