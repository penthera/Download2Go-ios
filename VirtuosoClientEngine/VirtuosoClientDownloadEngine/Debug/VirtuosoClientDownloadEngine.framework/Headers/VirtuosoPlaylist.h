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
 *  @abstract Defines a smart-download Playlist
 *  
 *  @discussion A VirtuosoPlaylist represents a sequenced set of Assets that are to be consecutively downloaded.
 *  Binge watching a TV series provides an appropriate example for how Playlists are intended to be used. When TV show in the series is watched,
 *  and deleted, the Playlist will automatically start downloading the next TV show in the series. Create an instance by providing an instance of VirtuosoPlaylistConfig which is then used to control how the VirtuosoPlaylist is managed.
 */
@interface VirtuosoPlaylist : NSObject

/*!
*  @abstract Creates playlist.
*
*  @discussion Creates the VirtuosoPlaylist object. Once created you must then pass this to VirtuosoPlaylistManager to create the Playlist inside the Virtuoso.
*
*  @param config Settings to control how Playlist is managed
*
*  @param assets Array of Strings which uniquely identify the Assets (via AssetID) that will become part of this playlist.
*
*  @return non-nil instance if successful, otherwise nil. Errors are logged.
*/
-(_Nonnull instancetype)initWithConfig:(VirtuosoPlaylistConfig* _Nullable)config assets:(NSArray<NSString*>* _Nonnull)assets;


/*!
*  @abstract Finds instance of specified playlist
*
*  @discussion Finds instance of specified playlist.
 *
 * @warning: This method is a blocking call. Best practice is to invoke this method using a background thread.
*
*  @param name String that uniquely identifies this Playlist.
*
*  @return non-nil instance if successful, otherwise nil. Errors are logged.
*/
+(instancetype _Nullable)findPlaylist:(NSString*)name;

/*!
*  @abstract Check whether Playlist.items contains the specified assetID
*
*  @param assetID AssetID of asset to search for
*
*  @return True if the playlist contains the specified AssetID
*/
-(Boolean)contains:(NSString*)assetID;

/*!
*  @abstract Appends assets to the playlist
*
*  @warning Avoid calling this method directly from MainThread as the call will block.
*
*  @param assets Array of AssetID's for the Assets to be added. Duplicate Assets are not allowed in the Playlist.
*/
-(void)append:(NSArray*)assets;

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


@end

NS_ASSUME_NONNULL_END
