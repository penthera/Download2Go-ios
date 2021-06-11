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
 *  @typedef PlaylistItemState
 *
 *  @abstract Status of playlist
 */
typedef NS_ENUM(NSInteger, PlaylistItemState)
{
    /** Item initialized */
    PlaylistItemState_Uninitialized,
    
    /** Item is next item to be processed */
    PlaylistItemState_NextItem,
    
    /** Item created successfully */
    PlaylistItemState_Created,

    /** Item create currently in process */
    PlaylistItemState_CreateInProcess = 100,
    
    /** Item creation failed */
    PlaylistItemState_CreateFailed,
    
    /** Item was not found when delegate was called */
    PlaylistItemState_NotFound = 500,
    
    /** Item was deleted by user */
    PlaylistItemState_UserDeleted,
    
    /** Playlist cancelled auto download */
    PlaylistItemState_AutoDownloadCancelled,
    
    /** Item was evicted from Playlist when maxItems was exceeded */
    PlaylistItemState_Evicted,
    

};


/*!
*  @abstract Defines a smart-download VirtuosoPlaylistItem
*
*  @discussion A VirtuosoPlaylist will contain a collection of VirtuosoPlaylistItem. Each VirtuosoPlaylistItem represents a single VirtuosoAsset that is part of the VirtuosoPlaylist.
*/
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

/*!
 *  @abstract Indicates whether the item expired.
 */
@property (nonatomic, assign, readonly) Boolean expired;

/*!
 *  @abstract String formatted representation of itemState
 *
 *  @discussion Returns a string representation of PlaylistItemState.
 *
 *  @param state PlaylistItemState enum for which we will return a string representation.
 *
 */
+(NSString*)statusAsString:(PlaylistItemState)state;
@end

NS_ASSUME_NONNULL_END
