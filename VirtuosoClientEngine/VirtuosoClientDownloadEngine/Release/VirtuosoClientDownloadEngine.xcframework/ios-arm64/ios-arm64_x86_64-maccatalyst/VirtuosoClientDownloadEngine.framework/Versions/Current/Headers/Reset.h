//
//  Reset.h
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
 *  @abstract Defines reasons for Reset
 *
 *  @discussion This enum defines the various reasons a Reset
 *
 *  @see Reset
 *
 */
typedef NS_ENUM(NSInteger, kVL_ResetType)
{
    /** Reset from install */
    kVL_ResetTypeInstall = 1,
    
    /** Reset from remote wipe */
    kVL_ResetTypeRemoteWipe = 2,
};

/*!
 *  @abstract Base classs for Reset Analytics Events
 *  @discussion Base classs for Reset Analytics Events
 */
@interface Reset : VirtuosoBaseEvent

/*!
 *  @abstract Reason for reset.
 *  @see kVL_ResetType
 */
@property(nonatomic,readonly) kVL_ResetType reset_type;

@end

NS_ASSUME_NONNULL_END
