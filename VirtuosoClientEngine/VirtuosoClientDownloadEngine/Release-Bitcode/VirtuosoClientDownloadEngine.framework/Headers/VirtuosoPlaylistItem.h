//
//  VirtuosoPlaylistItem.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 2/27/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *
 *  @typedef kVDE_PlaylistItemState
 *
 *  @abstract Status of playlist
 */
typedef NS_ENUM(NSInteger, PlaylistItemState)
{
    PlaylistItemState_Uninitialized,
    PlaylistItemState_NextItem,
    PlaylistItemState_Created,

    PlaylistItemState_CreateInProcess = 100,
    PlaylistItemState_CreateFailed,
    
    PlaylistItemState_NotFound = 500,
    PlaylistItemState_UserDeleted,    
};


@interface VirtuosoPlaylistItem : NSObject

/*!
 *  @abstract Creates an item for a playlist.
 *
 *  @param name Name for the playlist item
 *
 *  @param asset Asset for the playlist item
 *
 *  @return Instance of this object
 */
-(_Nullable instancetype)initWithName:(NSString* _Nonnull)name assetID:(NSString* _Nonnull)asset;

/*!
 *  @abstract Name of playlist
 */
@property (nonatomic, copy, nullable, readonly) NSString* name;
/*!
 *  @abstract AssetID of asset in playlist
 */
@property (nonatomic, copy, nullable, readonly) NSString* assetID;
/*!
 *  @abstract date download was completed on this item
 *
 *  @discussion This property will be updated internally when download is completed.
 */
@property (nonatomic, copy, nullable, readonly) NSDate* downloadComplete;
/*!
 *  @abstract ordinal index of this item in the playlist
 *
 *  @discussion This property will be updated internally when the playlist is created or modified.
 */
@property (nonatomic, assign, readonly) NSInteger index;
/*!
 *  @abstract True indicates this item is pending processing for next Smartdownload
 *
 *  @discussion This property will be updated pending=YES when item is deleted and smart-downloading
 *              can not process the item because the device is off-line. Once processed, it is changed
 *              to pending = NO.
 */
@property (nonatomic, assign, readonly) Boolean pending;

/*!
 *  @abstract date item became pending next smart-download
 *
 *  @discussion This property will be updated internally when download is completed.
 */
@property (nonatomic, copy, nullable, readonly) NSDate* pendingDate;

/*!
 *  @abstract date item played
 *
 *  @discussion This property will be updated internally when download is completed.
 */
@property (nonatomic, copy, nullable, readonly) NSDate* playbackDate;


/*!
 *  @abstract True indicates the user deleted this item
 *
 *  @discussion This property will be updated internally when a user deletes the item.
 */
@property (nonatomic, assign, readonly) Boolean userDeleted;

/*!
 *  @abstract Enum indicating state of playlist item
 */
@property (nonatomic, assign, readonly)PlaylistItemState itemState;

@end

NS_ASSUME_NONNULL_END
