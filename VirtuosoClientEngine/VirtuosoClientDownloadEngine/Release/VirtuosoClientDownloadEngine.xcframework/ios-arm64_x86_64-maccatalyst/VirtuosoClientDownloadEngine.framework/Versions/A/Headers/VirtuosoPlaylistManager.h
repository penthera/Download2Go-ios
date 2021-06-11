//
//  VirtuosoAssetQueueManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 2/15/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "PlaylistItemInfo.h"

NS_ASSUME_NONNULL_BEGIN
@class VirtuosoAssetConfig;
@class VirtuosoPlaylist;
@class VirtuosoPlaylistItem;
@class VirtuosoPlaylistConfig;

/*!
 *  @discussion Error codes for Playlists
 */
typedef NS_ENUM(NSInteger, kPLY_Error)
{
    /** Playlist status is not Active */
    kPLE_Error_NotActive = -1,
    /** Invalid parameter see logs */
    kPLE_Error_InvalidParameter = -2,
    /** Internal error see logs */
    kPLE_Error_InternalError = -3,
    
};


/*!
 *  @discussion Control option for continuing Playlist auto downloads
 */
typedef NS_ENUM(NSInteger, kVDE_PlaylistDownloadOption)
{
    /** Continue normal downloading */
    PlaylistDownloadOption_Download,
    
    /** Skip to next item in playlist and attempt to download */
    PlaylistDownloadOption_SkipToNext,
    
    /** Try again later */
    PlaylistDownloadOption_TryAgainLater,

    /** Cancel downloading */
    PlaylistDownloadOption_CancelDownloading,
};

/*!
*  @abstract VirtuosoPlaylistDownloadAssetItem defines the response returned from VirtuosoPlaylistManagerDelegate method assetForAssetID.
*
*  @discussion VirtuosoPlaylistDownloadAssetItem is returned by VirtuosoPlaylistManagerDelegate method assetForAssetID when the next asset in a Playlist needs to be downloaded.
 *
*/
@interface VirtuosoPlaylistDownloadAssetItem : NSObject
    
/*!
*  @abstract Enum used to indicate how the next playlist item shoud be handled.
*/
@property (nonatomic, assign)kVDE_PlaylistDownloadOption option;

/*!
*  @abstract Reference to the VirtuosoAssetConfig object that should be used to create the next asset in a Playlist.
*/
@property (nonatomic, strong)VirtuosoAssetConfig* _Nullable config;

/*!
*  @abstract Creates an instance of VirtuosoPlaylistDownloadAssetItem
*
*  @discussion This constructor can be used to return when no AssetConfig is being returned for cases like PlaylistDownloadOption_SkipToNext, PlaylistDownloadOption_TryAgainLater or PlaylistDownloadOption_CancelDownloading.
*
*  @param option Enum kVDE_PlaylistDownloadOption indicating option
 *
 * @return Return an instance of VirtuosoPlaylistDownloadAssetItem
 *
*/
-(instancetype)initWithOption:(kVDE_PlaylistDownloadOption)option;

/*!
*  @abstract Creates an instance of VirtuosoPlaylistDownloadAssetItem
*
*  @discussion This constructor should be used when you want to return an instance of VirtuosoAssetConfig. Property option will be set to PlaylistDownloadOption_Success when the instance of VirtuosoAssetConfig is a non-nil value. Otherwise, property option is set to PlaylistDownloadOption_SkipToNext.
*
*  @param config Instance of VirtuosoAssetConfig that will be used to create the next playlist download
 *
 * @return Return an instance of VirtuosoPlaylistDownloadAssetItem
 *
*/
-(instancetype)initWithAsset:(VirtuosoAssetConfig*)config;

@end

/*!
 *  @abstract Delegate that must be implemented in order to provide Asset's to the VirtuosoPlaylistManager.
 *
 *  @discussion This delegate defines the method(s) that must be implemented to support automatic downloads for Playlists.
 *            Methods in this delegate are called from a background thread, make sure your code
 *            can properly execute from a Thread other than the thread that created this delegate.
 *
 *            This is an advanced feature which is entirely optional.
 */
@protocol VirtuosoPlaylistManagerDelegate <NSObject>

@required

/*!
 *  @abstract Requests the next asset that should be downlaoded for the named Playlist.
 *
 *  @discussion Fires when an asset has been deleted in the asset Playlist and the next logical asset that is not on the device can be readied for download.
 *
 *  @param assetID The ID of the Asset in the specificed Playlist.
 *
 *  @return Return an instance of VirtuosoPlaylistNextAssetDownloadItem
 */
-(VirtuosoPlaylistDownloadAssetItem*)assetForAssetID:(NSString* _Nonnull)assetID;

@optional

/*!
 *  @abstract Requests the next asset that should be downlaoded for the named Playlist.
 *
 *  @discussion Fires when a Playlist determins next logical asset that is not on the device can be readied for download. FastPlay playlist assets must be configured for fastPlay download only (VirtuosoAssetConfig.fastPlayEnabled = true).
 *
 *  @param assetID The ID of the Asset in the specificed Playlist.
 *  @param triggerAssetID The ID of the Asset that triggered the need to download a new asset.
 *  @param playlists Playlists this triggeringAssetID is contained in.
 *
 *  @return Return an instance of VirtuosoPlaylistNextAssetDownloadItem
 */

-(VirtuosoPlaylistDownloadAssetItem*)assetForAssetID:(NSString* _Nonnull)assetID
                                      triggerAssetID:(NSString* _Nonnull)triggerAssetID
                                        forPlaylists:(NSArray<VirtuosoPlaylist*>*) playlists;

@end

/*!
*  @abstract VirtuosoPlaylistManager defines the top level object used to create and manage a VirtuosoPlaylist.
*
*  @discussion VirtuosoPlaylistManager is used to manage VirtuosoPlaylist's.  Each VirtuosoPlaylist contains a collection of VirtuosoPlaylistItem. VirtuosoPlaylistItem's represents a single VirtuosoAsset that is part of the Playlist.
*  The VirtuosoPlaylistManager is used to manage creation, updates to, and deletion of Playlists.
 *
*/
@interface VirtuosoPlaylistManager : NSObject

/*!
 *  @abstract Error domain for errors returned by Playlists. See kPLY_Error

 */
@property (nonatomic, class, readonly)NSString* errorDomain;

/*!
 *  @abstract Sets the delegate that will be called when an asset is needed for downloading from Playlist
 *
 *  @discussion Fires when an asset has been deleted in the asset Playlist and the next logical asset that is not on the device can be readied for download.
 *
 *  @param delegate Reference to delegate implementing the VirtuosoAssetQueueManagerDelegate protocol.
 */
+(void)setDelegate:(id<VirtuosoPlaylistManagerDelegate>)delegate;

/*!
 *  @abstract Returns the singleton instance managing the Asset Playlist. Use this method and not the init method.
 *
 *  @return Singleton instance of VirtuosoAssetQueueManager
 */
+(instancetype)instance;

/*!
 *  @abstract Creates Playlist
 *
 *  @discussion Creates and replaces any previous contents for the specified Playlist.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoPlaylist method create
 *
 *  @param name Name of the Playlist.
 *
 *  @param assets Array of Asset ID's to be added to the specified Playlist. Assets in the Playlist are indexed based on the order of items in this array.
 *
 *  @param config Configuration options for the Playlist.
 *
 *  @return True indicates success.
 */
-(Boolean)create:(NSString* _Nonnull)name assets:(NSArray<NSString*>* _Nonnull)assets config:(VirtuosoPlaylistConfig* _Nullable)config __deprecated_msg("Use VirutosoPlaylist create");

/*!
 *  @abstract Creates Playlist's
 *
 *  @discussion Creates and replaces any previous contents for the specified Playlist's.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoPlaylist method create
 *
 *  @param item Playlist to create
 *
 *  @return True indicates success.
 */
-(Boolean)create:(VirtuosoPlaylist* _Nonnull)item __deprecated_msg("Use VirutosoPlaylist create");

/*!
 *  @abstract Creates Playlist's
 *
 *  @discussion Creates and replaces any previous contents for the specified Playlist's.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoPlaylist method create
 *
 *  @param items Array of Playlists to create
 *
 *  @return True indicates success.
 */
-(Boolean)createWithItems:(NSArray<VirtuosoPlaylist*>* _Nonnull)items __deprecated_msg("Use VirutosoPlaylist create");;

/*!
 *  @abstract Appends to a Playlist
 *
 *  @discussion Appends to existing Playlist. You can also append using VirtuosoPlaylist method append once the playlist has been created.
 *
 *  If the Playlist does not exist it will be created and configured using Playlist.config.
 *
 *  If the Playlist exists, items are append but changes to Playlist.config are not applied once the playlist has been created.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoPlaylist method append
 *
 *  @param item Playlist data to append
 *
 *  @return True indicates success.
 */
-(Boolean)append:(VirtuosoPlaylist* _Nonnull)item __deprecated_msg("Use VirutosoPlaylist append");;

/*!
 *  @abstract Appends to items to each of the specified Playlist in the input array.
 *
 *  @discussion Appends to existing Playlists. You can also append using VirtuosoPlaylist method append once the playlist has been created.
 *
 *  If the Playlist does not exist it will be created and configured using Playlist.config.
 *
 *  If the Playlist exists, items are append but changes to Playlist.config are not applied once the playlist has been created.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @deprecated This method has been deprecated and replaced by VirtuosoPlaylist method append
 *
 *  @param items Array of Playlists to have items appended. See append method for details.
 *
 *  @return True indicates success.
 */
-(Boolean)appendItems:(NSArray<VirtuosoPlaylist*>* _Nonnull)items __deprecated_msg("Use VirutosoPlaylist append");;

/*!
 *  @abstract Clears all items in the specified Playlist
 *
 *  @discussion Clears all items in the specified Playlist.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @param name Name of the Asset Playlist.
 *
 *  @return True indicates success.
 */
-(Boolean)clear:(NSString* _Nonnull)name;

/*!
 *  @abstract Clears all Playlist content
 *
 *  @discussion Clears all Playlist content.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
*
 *  @return True indicates success.
 */
-(Boolean)clearAll;

/*!
 *  @abstract Finds Playlist
 *
 *  @discussion Finds the specified playlist.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
*
 *  @param name Name of the Playlist.
 *
 *  @return VirtuosoPlaylist, nil if not found.
 */
-(VirtuosoPlaylist*)find:(NSString* _Nonnull)name;


/*!
 *  @abstract Finds all Playlist's
 *
 *  @discussion Finds all playlists.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @return Array<VirtuosoPlaylist>, nil if not found.
 */
-(NSArray<VirtuosoPlaylist*>*)findAllItems;


/*!
 *  @abstract Asks the PlaylistManager to process any pending Smart-Downloads
 *
 *  @discussion When PlaylistManager delegate returns tryAgainLater, items are marked pending awaiting smart-downloading.
 *              These pending items can be restarted for Smart-downloads by calling this method. Otherwise, the will be restarted
 *              when the Engine state changes to Idle or Downloading.
 *
 *  @return True indicates PlaylistManager started. False is returned if Network is unreachable.
 */
-(Boolean)processPendingItems;


/*!
 *  @abstract Default timeout waiting for Playlist asset to be created (excluding time to download).
 *
 *  @discussion When multiple simultaneous smart-downloads are triggered, the Engine waits this duration for each
 *              asset to be created and parsed. This helps ensure assets hit the download queue in the same order
 *              the smart-downloads were triggered. Assets with thousands of segments might take longer than this
 *              duration to parse. If that happens, it's possible another smart-download might begin downloading
 *              ahead of the asset with thousands of segments. This timeout represents worst-case. If asset create
 *              happens faster, the timeout is not triggered and downloading continues unimpeeded.
 */
+(long)createTimeoutDefaultInSeconds;

/*!
 *  @abstract Minimum timeout waiting for Playlist asset to be created. Setting a value less than this will be
 *            overridden. The minumum timeout is 30 seconds.
 */
+(long)createTimeoutMinimumInSeconds;

/*!
 *  @abstract Maximum timeout waiting for Playlist asset to be created. Setting a value greater than this will be
 *            overridden. The maximum timeout is 600 seconds.
 */
+(long)createTimeoutMaximumInSeconds;

/*!
 *  @abstract Get the current value for asset creation timeout wait.
 */
+(long)createTimeoutInSeconds;

/*!
 *  @abstract Set the current value for asset creation timeout wait. The input value must be at least
 *            createTimeoutMinimumInSeconds and less than createTimeoutMaximumInSeconds. This method
 *            returns the final value following range checks.
 *
 *  @param seconds value for timeout in seconds
 */
+(long)setCreateTimeoutInSeconds:(long)seconds;

@end

NS_ASSUME_NONNULL_END
