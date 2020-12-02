//
//  VirtuosoClientAdMedia.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 5/29/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtuosoClientAdInfo.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Object describing Ad Media
 */
@interface VirtuosoClientAdMedia : NSObject

/*!
 *  @abstract Ad Media URL
 */
@property (nonatomic, copy, readonly)NSString* url;

/*!
 *  @abstract Ad Break
 */
@property (nonatomic, copy, readonly)NSString* _Nullable breakId;

/*!
 *  @abstract Time-offset for ad
 */
@property (nonatomic, copy, readonly)NSString* _Nullable timeOffset;

/*!
 *  @abstract Ad this Ad Media is assocated with
 */
@property (nonatomic, weak, readonly)VirtuosoClientAdInfo* _Nullable adInfo;

/*!
 *  @abstract Creates an instance
 *
 *  @param url URL for the Media
 *
 *  @param breakId Break details
 *
 *  @param timeOffset time when the ad should play
 *
 *  @return Instance, nil if failure
 *
 */
-(instancetype _Nullable)initWithUrl:(NSString*)url breakId:(NSString* _Nullable)breakId timeOffset:(NSString* _Nullable)timeOffset;

/*!
 *  @abstract True of this Ad is a pre-roll Ad
 */
-(Boolean)isPreroll;

/*!
 *  @abstract True of this Ad is a post-roll Ad
 */
-(Boolean)isPostroll;
    
/*!
 *  @abstract True if this Ad should be played now
 *
 *  @param current current percent complete
 *
 *  @param duration duration in miliseconds
 *
 *  @return True if ads should be played
 *
 */
-(Boolean)shouldPlayAdNow:(NSTimeInterval)current duration:(NSTimeInterval)duration;
    
@end

NS_ASSUME_NONNULL_END
