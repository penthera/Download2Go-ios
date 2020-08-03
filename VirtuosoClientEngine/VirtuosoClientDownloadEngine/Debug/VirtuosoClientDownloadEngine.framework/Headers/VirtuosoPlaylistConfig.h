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
 *  @typedef kVDE_PlaylistStatus
 *
 *  @abstract Status of playlist
 */
typedef NS_ENUM(NSInteger, kVDE_PlaylistStatus)
{
    /** Playlist is actively enabled */
    PlaylistStatus_Active     = 0,
    
    /** Playlist Asset creation failed */
    PlaylistStatus_AssetCreateFailed,
    
    /** Playlist Asset creation failed and no more assets exist */
    PlaylistStatus_AssetCreateFailedNoAssetsLeft = 500,
    
};


/*!
*  @abstract Defines the various confiuration options that can be used to create a VirtuosoPlaylist.
*
*  @discussion Create this object and set the various properties to control how the VirtuosoPlaylist will be manged.
*/
@interface VirtuosoPlaylistConfig : NSObject

-(instancetype)initWithName:(NSString*)name;

@property (nonatomic, copy, readonly)NSString* name;

/*!
 *  @abstract Indicates Playlist status
 *
 *  @discussion Active Playlists are enabled for smart-download. Any other status indicates smart-download is disable.
 */
@property (nonatomic, assign, readonly)kVDE_PlaylistStatus status;

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
