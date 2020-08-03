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
*  @discussion Creates the VirtuosoPlaylist object. Once created you must then pass this VirtuosoPlaylistManager to create the Playlist inside the Virtuoso.
*
*  @param name String that uniquely identifies this Playlist.
*
*  @param assets Array of Strings which uniquely identify the Assets (via AssetID) that will become part of this playlist.
*
*  @param config Settings to control how Playlist is managed
*
*  @return non-nil instance if successful, otherwise nil. Errors are logged.
*/
-(_Nonnull instancetype)initWithName:(NSString* _Nonnull)name assets:(NSArray<NSString*>* _Nonnull)assets config:(VirtuosoPlaylistConfig* _Nullable)config;

/*!
 *  @abstract Name of playlist
 */
@property (nonatomic, copy, readonly)NSString* name;

/*!
 *  @abstract Items contained in the playlist
 */
@property (nonatomic, copy, readonly)NSArray<VirtuosoPlaylistItem*>* items;

/*!
 *  @abstract Settings to control how Playlist is managed
 */
@property (nonatomic, strong, readonly)VirtuosoPlaylistConfig* config;

/*!
 *  @abstract Settings to control how Playlist is managed
 */
@property (nonatomic, assign, readonly)kVDE_PlaylistStatus status;

/*!
 *  @abstract String formatted representation of status
 */
-(NSString*)statusAsString;

@end

NS_ASSUME_NONNULL_END
