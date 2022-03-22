//
//  VirtuosoPlaylistConfig.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 2/28/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *
 *  @discussion Playlist type options.
 */
typedef NS_ENUM(NSInteger, kVDE_PlaylistType)
{
    /** Playlist is auto download type triggered by asset delete or expiry. */
    kVDE_PlaylistType_AutoDownload,

    /** Playlist is fastplay download type triggered by fastplay asset playback. */
    kVDE_PlaylistType_FastPlay
};

/*!
 *
 *  @discussion Status of playlist.
 */
typedef NS_ENUM(NSInteger, kVDE_PlaylistStatus)
{
    /** Playlist is actively enabled */
    PlaylistStatus_Active     = 0,
    
    /** Customer requested cancelling further downloads */
    PlaylistStatus_AutoDownloadCancelled,
    
    /** Playlist Asset creation failed */
    PlaylistStatus_AssetCreateFailed,
    
    /** Playlist Asset creation failed and no more assets exist */
    PlaylistStatus_AssetCreateFailedNoAssetsLeft = 500,
};

/*!
 *  @discussion VirtuosoPlaylistConfig is used to control how a VirtuosoPlaylist will be managed.
 *
 *  A VirtuosoPlaylist represents a sequenced set of Assets that are to be consecutively downloaded.
 *  Binge watching a TV series provides an appropriate example for how Playlists are intended to be used. Create an instance by providing an instance of VirtuosoPlaylistConfig which is then used to control how the VirtuosoPlaylist is managed. Paylist type is indicated by property playlistType. See kVDE_PlaylistType
 *
 *  Different types of Playlist can be created:
 *
 *     1) Auto Download (original type)
 *
 *     2) FastPlay
 *
 *   Auto Download:
 *
 *   This type of playlist will auto-download new epidodes as previous episodes are watched and deleted. When TV show in the series is watched,
 *   and deleted, the Playlist will automatically start downloading the next TV show in the series.
 *
 *   FastPlay:
 *
 *   FastPlay Playlists are designed for fast download of FastPlay enabled assets. This playlist type is simlar to AutoDownload playlist but differs on the triggering mechanism for new downloads. Triggering mechism is different. For AutoDownload playlists, the trigger event is asset deletion or expiry. FastPlay playlists trigger next download when the asset starts playing. As soon as an Asset configured for fastplay begins playing, the Playlist will immediately attempt to download the next sequential asset in the FastPlay playlist. Assets configured for this type of Playlist must be configured for FastPlay.
 */
@interface VirtuosoPlaylistConfig : NSObject

/*!
 @abstract Create playlist types AutoDownload or FastPlay.
 @discussion Creates either AutoDownload or FastPlay playlist types.
 
 @param name Name of Playlist. Name is required.
 @param playlistType Type of playlist to create. See kVDE_PlaylistType
 @param error Will be initialized with instance of NSError if the initializer fails.
 @returns Instance of the PlaylistConfig that can then be used to create a new Playlist.

*/
-(_Nullable instancetype)initWithName:(NSString*)name
                         playlistType:(kVDE_PlaylistType)playlistType
                                error:(NSError**)error;


/*!
 *  @abstract Specifies the type of Playlist. See kVDE_PlaylistType
 */
@property (nonatomic, assign, readonly)kVDE_PlaylistType playlistType;

@property (nonatomic, copy, readonly)NSString* name;

/*!
 *  @abstract Controls smart-download trigger logic.
 *
 *  @discussion Controls smart-download trigger logic. Smart-download is triggered when an asset
 *              is deleted via VirtuosoAsset.deleteAsset, OR when an Asset expires after playing.
 *              On trigger, this property is checked to see whether the Asset must ALSO have been played.
 *              If isPlaybackRequired is TRUE, and the Asset has NOT been played, smart-download
 *              is skipped.
 *
 *              VirtuosoAsset.deleteAll will NOT trigger
 *
 *              Default is TRUE.
 *
 *              TRUE:  Asset must have been played before smart-download starts.
 *
 *              FALSE: Asset does not have to have been played before smart-download is triggered.
 *
 * @warning VirtuosoAsset.deleteAll will NOT trigger smart-download.
 */
@property (nonatomic, assign, readwrite)Boolean isPlaybackRequired;

/*!
 *  @abstract Controls smart-download next download selection logic.
 *
 *  @discussion Controls smart-download next download selection logic.
 *              Enabling this option will cause smart-download selction logic to consider asset history
 *              in addition to Playlist history, when determine what the next item to be downloaded
 *              on a Playlist.
 *
 *              Example:
 *
 *                1) User downloads, plays, then deletes asset X
 *
 *                2) Next month, A playlist is created for which asset X is a member.
 *                   VirtuosoPlaylistConfig is created with following settings:
 *                       isAssetHistoryConsidered = TRUE
 *                       isPlaybackRequired = TRUE
 *
 *                3) During smart-download find next, asset X will be skipped in Playlist,
 *                   history shows asset X was downloaded, played, then deleted.
 *
 *              Default is FALSE.
 *
 *              TRUE:  Check asseet history
 *
 *              FALSE: Do not check asset history.
 */
@property (nonatomic, assign, readwrite)Boolean isAssetHistoryConsidered;

/*!
 *  @abstract Controls smart-download next playlist item search logic.
 *
 *  @discussion Controls smart-download next playlist item search logic. Default is FALSE.
 *
 *              Default is FALSE.
 *
 *              TRUE:  Search from beginning of playlist, for first Asset (excluding asset that triggered smart-download) that
 *                     does not exist on the device, and which has not been previously downloaded and deleted.
 *
 *              FALSE: Search from Asset that triggered smart-download to next item in playlist that
 *                     does not exist on the device, and which has not been previously downloaded and deleted.
 */
@property (nonatomic, assign, readwrite)Boolean isSearchFromBeginningEnabled;

@end

NS_ASSUME_NONNULL_END
