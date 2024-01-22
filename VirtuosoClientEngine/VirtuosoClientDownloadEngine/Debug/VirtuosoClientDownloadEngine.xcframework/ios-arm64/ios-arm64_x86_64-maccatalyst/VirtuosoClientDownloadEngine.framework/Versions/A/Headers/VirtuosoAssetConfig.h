/*!
 *  @header Virtuoso Asset Configuration
 *
 *  PENTHERA CONFIDENTIAL
 *
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  @copyright (c) 2018 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VirtuosoAssetConfig_h
#define VirtuosoAssetConfig_h

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoConstants.h>

@class VirtuosoAncillaryFile;
@class VirtuosoAdsProvider;
@class VirtuosoPlaylist;
@class VirtuosoPlaylistConfig;

/*!
 *  @abstract Defines type of download to perform.
 *
 *  @discussion This enum controls the type of download used for an Asset.
 *
 *  @see VirtuosoAssetConfig
 *
 */
typedef NS_ENUM(NSInteger, kVDE_DownloadType)
{
    /** Download for Offline playback */
    kVDE_DownloadOfflinePlayback = 0,
    
    /** Download for FastPlay playback */
    kVDE_DownloadFastPlayPlayback = 1,
    
    /** Download for both Offline and FastPay playback */
    kVDE_DownloadBothOfflineFastPlayPlayback = 2,
};


/*!
 *  @abstract Use this class to configure settings used when creating an Asset.
 *
 *  @discussion This class is used to configure the Asset during creation. This class contains all required information
 *              for creating an sset. Create an instance then set other properties as needed.
 *              When using VirtuosoAssetConfig you no longer need to manually add the asset to the download queue.
 *              When property autoAddToQueue when set to true (default), the Asset will automatically be added
 *              to the download queue once created. This means you no longer need to provide the callbacks when
 *              creating the asset and then manually invoking addToQueue.
 *
 *  Default values:
 *
 *    - VirtuosoAssetConfig..autoAddToQueue = TRUE;
 *    - VirtuosoAssetConfig.downloadType = kVDE_DownloadOfflinePlayback;
 *    - VirtuosoAssetConfig.maximumBitrate = INT_MAX;
 *    - VirtuosoAssetConfig.maximumAudioBitrate = INT_MAX;
 *    - VirtuosoAssetConfig.protectionType = kVDE_AssetProtectionTypePassthrough;
 *    - VirtuosoAssetConfig.includeEncryption = YES;
 *    - VirtuosoAssetConfig.assetDownloadLimit = -1;
 *    - VirtuosoAssetConfig.expiryAfterPlay = kInvalidExpiryTimeInterval;     // -42.0
 *    - VirtuosoAssetConfig.expiryAfterDownload = kInvalidExpiryTimeInterval; // -42.0
 *
 *  FastPlay quckest download should use the following:
 *
 *    - VirtuosoAssetConfig.downloadType = kVDE_DownloadFastPlayPlayback;
 *
 *  Download for both FastPlay and Offline playback:
 *  
 *    - VirtuosoAssetConfig.downloadType = kVDE_DownloadBothOfflineFastPlayPlayback;
 *
 */
@interface VirtuosoAssetConfig : NSObject

/**---------------------------------------------------------------------------------------
 * @name Properties
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Where this asset exists on the Internet
 *
 *  @discussion The asset URL is the addressable location on the Internet.
 *              It must include any required security or CDN tokens.
 *
 *              If your CDN uses dynamic URLs or another method where URLs change over time, Virtuoso
 *              may need to issue a network request to get a 'fresh' URL.  In that case, this method
 *              will block during this network request.
 */
@property (nonatomic, copy, readonly)NSString* _Nonnull assetURL;


/*!
 *  @abstract A unique identifier that you provide when instantiating this asset
 *
 *  @discussion Virtuoso uses the assetID in log events and for remote delete/wipe requests.
 */
@property (nonatomic, copy, readonly)NSString* _Nonnull assetID;

/*!
 *  @abstract A human-readable description for this asset
 *
 *  @discussion Virtuoso does not use this internally, but does include it in logging output.
 *              You provided this value when instantiating this asset.
 */
@property (nonatomic, copy, readonly)NSString* _Nonnull assetDescription;

/*!
 *  @abstract The asset type
 */
@property (nonatomic, assign, readonly)kVDE_AssetType assetType;

/*!
 *  @abstract Specified the type of download requested.
 *
 *  @discussion Specifies the type of download requested. Defaults to kVDE_DownloadOfflinePlayback.
 *
 *  @see kVDE_DownloadType
 *
 */
@property (nonatomic, assign)kVDE_DownloadType downloadType;


/*
 *  @abstract The asset protection type identified during asset creation.
 *
 *  @discussion In some configurations, special handling is required in order to download and play assets.
 *              Most of the time, you should pass the default value (kVDE_AssetProtectionTypePassthrough).  If
 *              instructed by Penthera support, you may be required to pass another value when the asset is created.
 */
@property (nonatomic, assign)kVDE_AssetProtectionType protectionType;

/*!
 *  @abstract If YES, then the asset will download any encryption keys in manifest.
 *            Normally, you would pass YES, but this allows for custom behaviors.
 */
@property (nonatomic, assign)Boolean includeEncryption;

/*!
*  @abstract For manifests containing multiple profiles, Virtuoso will select the highest bitrate
*            profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest
*            bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
*            select the lowest bitrate profile.  A value of INT_MAX means "use the highest bitrate."
 *           Defaults to maximum rate INT_MAX.
*/
@property (nonatomic, assign)long long maximumBitrate;

/*!
 * @abstract Same as maximumBitrate, but for the audio portion of the stream.  If the audio for
 *           this asset is contained within the video profile, this value is ignored.
 *           Defaults to maximum rate INT_MAX.
 */
@property (nonatomic, assign)long long maximumAudioBitrate;

/*!
 *  @abstract Configures video resolutions to consider when determining video rendition for download
 *
 *  @discussion Only renditions from the manifest that match the given resolution filter will be considered during rendition
 *              selection.  The format of filter strings will be required to match that values you use for the RESOLUTION tag
 *              in the HLS manifest (E.G. 1920x1080).  The default value is nil.
 *
 *              When selecting which rendition to download, multiple factors are applied.  First, codec filters remove any
 *              renditions that  do not match the global filter settings.  Second, resolution filters are applied so that only
 *              renditions with the requested resolution  are considered.  Finally, the maximumBitrate selection is applied,
 *              to insure we only download a bitrate that most closely matches the target value.
 */
@property (nonatomic,strong,nullable) NSArray* resolutions;

/*!
 *  @abstract When this asset should become available
 *
 *  @discussion Virtuoso will download assets as soon as they are enqueued.
 *              But in some cases, you may wish to embargo an asset.
 *              You do so by setting the publishDate property in the future.
 *              Until this date, Virtuoso will disallow access to this asset via the
 *              VirtuosoClientHTTPServer, and will not include this asset in any filtered
 *              query methods.
 *
 *  @see expiryDate
 */
@property (nonatomic, copy)NSDate* _Nullable publishDate;

/*!
 *  @abstract As soon as possible after 'expiryDate' has passed, Virtuoso automatically deletes the asset.
 *
 *  @discussion A nil value means the asset never expires.
 */
@property (nonatomic, copy)NSDate* _Nullable expiryDate;

/*!
 *  @abstract After the asset has completed download, as soon as possible after 'expiryAfterDownload'
 *            time has elapsed, Virtuoso automatically deletes the asset.
 *
 *  @discussion A value of zero means the asset never expires.
 */
@property (nonatomic, assign)NSTimeInterval expiryAfterDownload;

/*!
 *  @abstract After the asset is first played, as soon as possible after 'expiryAfterPlay' time has elapsed,
 *            Virtuoso automatically deletes the asset.
 *
 *  @see VirtuosoAsset.firstPlayDateTime
 *
 *  @discussion A value of zero means the asset never expires.
 */
@property (nonatomic, assign)NSTimeInterval expiryAfterPlay;

/*!
 *  @abstract The asset-specific lifetime download limit.
 *
 *  @discussion The Backplane specifies a globally applied lifetime download limit for all assets.  An individual
 *              asset may not be downloaded more than this number of times in a given account.  Once the asset has
 *              been successfully downloaded this many time, future attempts to download the asset will return an error.
 *              This optional value may be specified to override the lifetime download limit for this particular asset.
 *              If this value is greater than 0, it will be used for permissions calculations instead of the backplane-
 *              defined value.  This value is provided during creation of the asset and cannot be changed after creation.
 */
@property (nonatomic, assign)NSInteger assetDownloadLimit;
                                     
/*!
 *  @abstract If true the asset is automatically added to the download queue. Default is true.
 */
@property (nonatomic, assign)Boolean autoAddToQueue;

/*!
 *  @abstract Optional array of ancillary files.
 */
@property (nonatomic, strong)NSArray<VirtuosoAncillaryFile*>* _Nullable ancillaries;

/*!
 *  @abstract AdsProvider assocated with the Asset if Ads are enabled.
 *
 */
@property (nonatomic, strong)VirtuosoAdsProvider* _Nullable adsProvider;

/*!
 *  @abstract The generic userInfo metadata for this asset
 *
 *  @discussion The userInfo dictionary is for you to store metadata alongside this asset.
 *              Since Virtuoso serializes this object, all objects contained within the userInfo dictionary
 *              MUST be property list compatible objects.  If you attempt to save non-compatible objects,
 *              the userInfo dictionary won't be persisted.
 */
@property (nonatomic, copy)NSDictionary* _Nullable userInfo;

/*!
 *  @abstract Optional Playlist configuration to which this assedt will be added.
 */
@property (nonatomic, strong)VirtuosoPlaylistConfig* _Nullable playlistConfig;

/*!
 *  @abstract Optional list of assets to be added to the Playlist
 */
@property (nonatomic, strong)NSArray<NSString*>* _Nullable playlistAssets;


/*!
 *  @abstract Optional Playlists that this asset should be added to.
 *
 *
 */
@property (nonatomic, strong)NSArray<VirtuosoPlaylist*>* _Nullable playlists
__deprecated_msg("Prefer playlistConfig and playlistAssets");

/**---------------------------------------------------------------------------------------
 * @name Initializer
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Creates instance
 *
 *  @discussion This constructor creates an instance with the basic properties needed by all Asset types.
 *
 *  @param url Where the manifest lives on the Internet.
 *
 *  @param assetID A globally unique identifier for the asset. Used in all log events.
 *                 IMPORTANT: This value must be globally unique across all assets within the Catalog.
 *                 Dupicate AssetID's are not allowed.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param type Type of asset to create. See kVDE_AssetType
 *
 *  @return A instance of this class, nil if an error was encountered.
 */
-(instancetype _Nullable)initWithURL:(NSString* _Nonnull)url assetID:(NSString* _Nonnull)assetID description:(NSString* _Nonnull)description type:(kVDE_AssetType)type;

@end

#endif /* VirtuosoAssetConfig_h */
