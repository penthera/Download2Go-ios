//
//  VirtuosoPlaylistConfig.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 2/15/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtuosoPlaylistConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class VirtuosoPlaylistItem;
@class VirtuosoPlaylistConfig;


/*!
 *  @abstract Defines a auto-download Playlist
 *  
 *  @discussion A VirtuosoPlaylist represents a sequenced set of Assets that are to be consecutively downloaded.
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
@interface VirtuosoPlaylist : NSObject

/**---------------------------------------------------------------------------------------
 * @name Create
 *  ---------------------------------------------------------------------------------------
 */

/*!
*  @abstract Creates persistent instance of playlist.
*
*  @discussion Creates persistent instance of playlist.
*
*  @param config Settings to control how Playlist is managed. See VirtuosoPlaylistConfig
*  @param error NSError object returned indicating error
*
*  @return non-nil instance if successful, otherwise nil. Errors are logged.
*/
+(_Nullable instancetype)create:(VirtuosoPlaylistConfig* _Nonnull)config error:(NSError** _Nullable)error;

/*!
*  @abstract Creates persistent instance of playlist.
*
*  @discussion Creates persistent instance of playlist.
*
*  @param config Settings to control how Playlist is managed. See VirtuosoPlaylistConfig
*
*  @param assets Array of Strings which uniquely identify the Assets (via AssetID) that will become part of this playlist.
*  @param error NSError object returned indicating error
*
*  @return non-nil instance if successful, otherwise nil. Errors are logged.
*/
+(_Nullable instancetype)create:(VirtuosoPlaylistConfig* _Nonnull)config
                     withAssets:(NSArray<NSString*>* _Nonnull)assets
                          error:(NSError** _Nullable)error;


/*!
 *
 *
 *  @abstract Creates an instance of VirtuosoPlaylist
 *
 *  @discussion Creates an instance of VirtuosoPlaylist that can have assets appended.
 *
 *  @param config Provides configuration parameters needed to create the Playlist. See VirtuosoPlaylistConfig
*
 *  @return VirtuosoPlaylist, nil if parameters were invalid
 */
-(_Nonnull instancetype)initWithConfig:(VirtuosoPlaylistConfig* _Nullable)config;

/*!
 *  @abstract Creates an instance of VirtuosoPlaylist
 *
 *  @discussion Creates an instance of VirtuosoPlaylist that can have assets appended.
 *
 *  @param config Provides configuration parameters needed to create the Playlist. See VirtuosoPlaylistConfig
*
 *  @param assets Array of strings for the AssetID's of the assets to be added.
 *
 *  @return VirtuosoPlaylist, nil if parameters were invalid
 */
-(_Nonnull instancetype)initWithConfig:(VirtuosoPlaylistConfig* _Nullable)config
                                assets:(NSArray<NSString*>* _Nonnull)assets  __deprecated_msg("see class method create");

/**---------------------------------------------------------------------------------------
 * @name FInd
 *  ---------------------------------------------------------------------------------------
 */


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
+(instancetype _Nullable)find:(NSString*)name;


/*!
 *  @abstract Finds all Playlist's
 *
 *  @discussion Finds all playlists.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
 *
 *  @return Array<VirtuosoPlaylist>, nil if not found.
 */
+(NSArray<VirtuosoPlaylist*>*)findAll;

/**---------------------------------------------------------------------------------------
 * @name Clear
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Clears all Playlist content
 *
 *  @discussion Clears all Playlist content.
 *
 *  @warning Avoid calling this method directly from MainThread as the call will block.
*
 *  @return True indicates success.
 */
+(Boolean)clearAll;

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
+(Boolean)clear:(NSString* _Nonnull)name;

/*!
*  @abstract Check whether Playlist.items contains the specified assetID
*
*  @param assetID AssetID of asset to search for
*
*  @return True if the playlist contains the specified AssetID
*/
-(Boolean)contains:(NSString*)assetID;

/*!
    @name Add
 */

/*!
*  @abstract Appends assets to the playlist and return error on failure.
*
*  @warning Avoid calling this method directly from MainThread as the call will block.
*
*  @param assets Array of AssetID's for the Assets to be added. Duplicate Assets are not allowed in the Playlist.
*  @param error NSError that will be returned if the call fails.
*  @return True if successful
*/
-(BOOL)append:(NSArray*)assets error:(NSError* _Nullable __autoreleasing* )error;

/*!
    @name Instance Properties
 */

/*!
 *  @abstract Name of playlist
 */
@property (nonatomic, copy, readonly)NSString* name;

/*!
 *  @abstract Items contained in the playlist
 */
@property (nonatomic, copy, readonly)NSArray<VirtuosoPlaylistItem*>* items;

/*!
*  @abstract Indicates Playlist status
*
*  @discussion Active Playlists are enabled for smart-download. Any other status indicates smart-download is disable.
*/
@property (nonatomic, assign, readonly)kVDE_PlaylistStatus status;

/*!
 *  @abstract String formatted representation of status
 */
-(NSString*)statusAsString;

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
@property (nonatomic, assign, readonly)Boolean isAssetHistoryConsidered;

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
@property (nonatomic, assign, readonly)Boolean isSearchFromBeginningEnabled;

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
@property (nonatomic, assign, readonly)Boolean isPlaybackRequired;

/*!
*  @abstract Count of assets that will auto-download if the Playlist has new items appended.
*
*  @discussion This represents the number of assets that satisfied the Playlist auto-download rules, but for which no assets remained. If additional assets are appended to the playlist Penthera will immediately auto-download as many new assets as is indicated by pendingCount as long as the playlist previously ended with assets that met the auto-download rules.
*
*/
@property (nonatomic, assign, readonly)NSInteger pendingCount;

/*!
 @discussion Type of playlist. See kVDE_PlaylistType
 
*/
@property (nonatomic, assign, readonly)kVDE_PlaylistType playlistType;

/*!
 @discussion VirtuosoPlaylistConfig settings for the Playlist. Once set this can not be changed and is only made available for read access.
 
*/
@property (nonatomic, strong, readonly)VirtuosoPlaylistConfig* config;

/*!
 @discussion Refresh current state of Playlist items.
 
*/
-(void)refresh;

@end

NS_ASSUME_NONNULL_END
