//
//  DownloadLimitReached.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/5/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

//
// Adopted December 8, 2021
//

#import <VirtuosoClientDownloadEngine/VirtuosoAssetEvent.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Defines reasons for download limit
 *
 *  @discussion This enum defines the various reasons a DownloadLimitReached event is raised.
 *
 *  @see DownloadLimitReached
 *
 */
typedef NS_ENUM(NSInteger, kVL_LimitType)
{
    /** Account limit reached */
    kVL_LimitTypeAccount = 1,
    
    /** Asset limit reached */
    kVL_LimitTypeAsset = 2,
    
    /** Asset copies limit reached */
    kVL_LimitTypeCopies = 3,
    
    /** Limit on device reached  */
    kVL_LimitTypeDevice = 4,
    
    /** External limits reached */
    kVL_LimitTypeExternal = 5,
    
    /** Unknown limit reached */
    kVL_LimitTypeUnknown = 6,
};

/*!
 *  @abstract Base classs for Download Limit Reached Analytics Events
 *  @discussion Base classs for Download Limit Reached Analytics Events
 */
@interface DownloadLimitReached : VirtuosoAssetEvent

/*!
 *  @abstract Enumeration value indicating type of limit reached.
 *  @see kVL_LimitType
 */
@property(nonatomic,readonly) kVL_LimitType limit_type;

@end

NS_ASSUME_NONNULL_END
