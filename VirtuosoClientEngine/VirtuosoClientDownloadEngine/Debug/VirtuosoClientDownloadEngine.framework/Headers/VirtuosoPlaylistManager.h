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
 *  @typedef VirtuosoPlaylistManagerDelegate
 *
 *  @abstract This delegate defines the method(s) that must be implemented to support Smart Downloads.
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
 *  @param tryAgainLater Out parameter client sets if PlaylistManager should try to retrieve this item again at a later time.
 *
 *  @return Return an instance of VirtuosoAssetConfig for the specified Asset. If a valid instance is returned, the asset is parsed and automatically downloaded.
 */
-(VirtuosoAssetConfig* _Nullable)assetForAssetID:(NSString* _Nonnull)assetID tryAgainLater:(Boolean*)tryAgainLater;

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
 *  @abstract Server that is used to verify Internet accessibility via Ping.
 *
 *  @discussion Smart-Downloads will verify this server is reachable via Ping before attempting next smart-download.
 *              Consider overriding the default when you would prefer to verify Internet reachability for the servers
 *              hosting your Asset content. Verification is done via Ping.
 *
 *              Example: www.google.com
 *
 *              Default is a well-known web address with high availability.
 */
@property (nonatomic, strong, readwrite)NSString* pingServer;

/*!
 *  @abstract Creates Playlist
 *
 *  @discussion Creates and replaces any previous contents for the specified Playlist.
 *
 *  @param name Name of the Playlist.
 *
 *  @param assets Array of Asset ID's to be added to the specified Playlist. Assets in the Playlist are indexed based on the order of items in this array.
 *
 *  @param config Configuration options for the Playlist.
 *
 *  @return True indicates success.
 */
-(Boolean)create:(NSString* _Nonnull)name assets:(NSArray<NSString*>* _Nonnull)assets config:(VirtuosoPlaylistConfig* _Nullable)config;

/*!
 *  @abstract Creates Playlist's
 *
 *  @discussion Creates and replaces any previous contents for the specified Playlist's
 *
 *  @param item Playlist to create
 *
 *  @return True indicates success.
 */
-(Boolean)create:(VirtuosoPlaylist* _Nonnull)item;

/*!
 *  @abstract Creates Playlist's
 *
 *  @discussion Creates and replaces any previous contents for the specified Playlist's
 *
 *  @param items Array of Playlists to create
 *
 *  @return True indicates success.
 */
-(Boolean)createWithItems:(NSArray<VirtuosoPlaylist*>* _Nonnull)items;

/*!
 *  @abstract Appends to a Playlist
 *
 *  @discussion Appends to an existing Playlist
 *
 *  @param item Playlist data to append
 *
 *  @return True indicates success.
 */
-(Boolean)append:(VirtuosoPlaylist* _Nonnull)item;

/*!
 *  @abstract Appends to a Playlist
 *
 *  @discussion Appends to an existing Playlist
 *
 *  @param items Playlist items to be appended
 *
 *  @return True indicates success.
 */
-(Boolean)appendItems:(NSArray<VirtuosoPlaylist*>* _Nonnull)items;

/*!
 *  @abstract Clears all items in the specified Playlist
 *
 *  @discussion Clears all items in the specified Playlist
 *
 *  @param name Name of the Asset Playlist.
 *
 *  @return True indicates success.
 */
-(Boolean)clear:(NSString* _Nonnull)name;

/*!
 *  @abstract Clears all Playlist content
 *
 *  @discussion Clears all Playlist content
 *
 *  @return True indicates success.
 */
-(Boolean)clearAll;

/*!
 *  @abstract Finds Playlist
 *
 *  @discussion Finds the specified playlist
 *
 *  @param name Name of the Playlist.
 *
 *  @return VirtuosoPlaylist, nil if not found.
 */
-(VirtuosoPlaylist*)find:(NSString* _Nonnull)name;


/*!
 *  @abstract Finds all Playlist's
 *
 *  @discussion Finds all playlists
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
