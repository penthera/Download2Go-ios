//
//  AssetDelete.h
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
 *  @abstract Defines reasons for asset delete
 *
 *  @discussion This enum defines the various reasons an Asset was deleted.
 *
 *  @see AssetDelete
 *
 */
typedef NS_ENUM(NSInteger, kVL_DeletionType)
{
    /** Asset Deleted internally */
    kVL_DeletionTypeInternal = 1,
    
    /** Asset deleted remote */
    kVL_DeletionTypeRemote = 2,
    
    /** Asset deleted by user */
    kVL_DeletionTypeUser = 3,
    
    /** Asset deleted when user login changed */
    kVL_DeletionTypeUserChange = 4,
    
    /** Asset deleted when download failed */
    kVL_DeletionTypeFailedDownload = 5,
    
    /** Asset deleted when user selected delete all assets */
    kVL_DeletionTypeUserDeleteAll = 6,
    
    /** Asset deleted for unknown reason */
    kVL_DeletionTypeUnknown = -1,
};

/*!
 *  @abstract Base classs for Asset Delete Analytics Events
 */
@interface AssetDelete : VirtuosoAssetEvent

/*!
 *  @abstract Reason asset was deleted.
 *  @discussion Reason asset was deleted.
 *  @see kVL_DeletionType
 */
@property (nonatomic,readonly) kVL_DeletionType deletion_type;

@end

NS_ASSUME_NONNULL_END
