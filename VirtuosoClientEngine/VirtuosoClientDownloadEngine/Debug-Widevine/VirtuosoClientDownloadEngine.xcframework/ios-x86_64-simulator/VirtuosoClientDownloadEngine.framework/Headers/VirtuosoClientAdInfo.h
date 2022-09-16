//
//  VirtuosoClientAdInfo.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 5/29/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VirtuosoClientAdMedia;
@class VirtuosoClientAdTracking;

/*!
 *  @abstract Object containing client Ad details needed to playback the ad.
 *
 *  @discussion This object contains three properties covering the details for an Ad:
 *
 *        1) adMedia - Ad Video media
 *        2) trackingInfo - Impression and Tracking Beacons assocated with this media
 *        3) errorReporting - URL for reporting any problems assocated with Ads playback.
 */
@interface VirtuosoClientAdInfo : NSObject

/*!
 *  @abstract Array of VirtuosoClientAdMedia object describing the Ad media
 */
@property (nonatomic, strong)NSArray<VirtuosoClientAdMedia*>* adMedia;

/*!
 *  @abstract Array of VirtuosoClientAdMedia object describing the Ad media
 */
@property (nonatomic, strong)NSArray<VirtuosoClientAdTracking*>* trackingInfo;

/*!
 *  @abstract Array of VirtuosoClientAdMedia object describing the Ad media
 */
@property (nonatomic, strong)NSArray<NSString*>* errorReporting;

/*!
 *  @abstract Creates an instance.
 *
 * @param ads array of VirtuosoClientAdMedia
 *
 * @param trackingInfo array of VirtuosoClientAdTracking
 *
 * @param errorReporting array of NSString URL's to report errors
 *
 * @return Instance, nil if failure
 */
-(instancetype)initWithAds:(NSArray*)ads trackingInfo:(NSArray*)trackingInfo errorReporting:(NSArray*)errorReporting;

@end

NS_ASSUME_NONNULL_END
