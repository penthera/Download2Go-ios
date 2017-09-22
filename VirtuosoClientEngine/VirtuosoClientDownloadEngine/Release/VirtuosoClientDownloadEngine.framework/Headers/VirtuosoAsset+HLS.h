/*!
 *  @header Virtuoso Asset (HLS)
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
 *  @copyright (c) 2016 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VHLS
#define VHLS

#import <VirtuosoClientDownloadEngine/VirtuosoConstants.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+SegmentedVideo.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>

/*!
 *  @discussion Provides types and methods used to handle HTTP Live Streaming (HLS) video
 */
@interface VirtuosoAsset (HLS)

/**---------------------------------------------------------------------------------------
 * @name HLS Creation
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Creates a new in-memory HLS VirtuosoAsset.
 *
 *  @discussion This constructor uses the default expiry rules.  To customize expiry rules for this asset,
 *              use the constructors that take expiry parameters, or change the expiry values after creation.
 *
 *  @param assetID A unique identifier for the asset. Used in all log events.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param manifestUrl Where the manifest lives on the Internet.
 *
 *  @param protectionType You should pass the default value of kVDE_AssetProtectionTypePassthrough unless
 *                        instructed differently by Penthera support.
 *
 *  @param includeEncryption If YES, then this method will download any encryption keys in
 *                           manifest.  Normally, you would pass YES, but this allows for custom behaviors.
 *
 *  @param maximumBitrate For manifests containing multiple profiles, Virtuoso will select the highest bitrate 
 *                        profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest 
 *                        bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
 *                        select the lowest bitrate profile.  A value of INT_MAX means "use the highest bitrate."
 *
 *  @param publishDate Virtuoso will not provide API access to the asset until this date. Nil means "now."
 *
 *  @param expiryDate Virtuoso will not provide API access to the asset after this date. Nil means no expiry.
 *
 *  @param enableFastPlay If enabled, Virtuoso will automatically download the initial portion of the asset as soon
 *                        as the asset is created.  Whenever an asset is streamed, the cached beginning of the asset
 *                        will be returned to the player immediatley, eliminating startup buffer time for streamed playback.
 *
 *  @param userInfo A convenience field allowing you to associate arbitrary data with an asset.
 *                  Virtuoso will serialize this data and store it, but not explicitly use this data.
 *                  The provided userInfo must be property-list compatible. May be nil.
 *
 *  @param readyBlock Called when the asset is ready to be added to the download queue
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 *
 *  @return A new (empty) VirtuosoAsset object, or nil if there was an error.
 *
 */
+ (nullable VirtuosoAsset*)assetWithAssetID:(nonnull NSString*)assetID
                       description:(nonnull NSString*)description
                       manifestUrl:(nonnull NSString*)manifestUrl
                    protectionType:(kVDE_AssetProtectionType)protectionType
             includeEncryptionKeys:(Boolean)includeEncryption
                    maximumBitrate:(long long)maximumBitrate
                       publishDate:(nullable NSDate*)publishDate
                        expiryDate:(nullable NSDate*)expiryDate
                    enableFastPlay:(Boolean)enableFastPlay
                          userInfo:(nullable NSDictionary*)userInfo
                onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                   onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/*!
 *  @abstract Creates a new in-memory HLS VirtuosoAsset object.
 *
 *  @discussion This constructor allows you to set custom expiry rules.
 *
 *  @param assetID A unique identifier for the asset. Used in all log events.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param manifestUrl Where the manifest lives on the Internet.
 *
 *  @param protectionType You should pass the default value of kVDE_AssetProtectionTypePassthrough unless
 *                        instructed differently by Penthera support.
 *
 *  @param includeEncryption If YES, then this method will download any encryption keys in
 *                           manifest.  Normally, you would pass YES, but this allows for custom behaviors.
 *
 *  @param maximumBitrate For manifests containing multiple profiles, Virtuoso will select the highest bitrate
 *                        profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest 
 *                        bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
 *                        select the lowest bitrate profile.  A value of INT_MAX means "use the highest bitrate."
 *
 *  @param publishDate Virtuoso will not provide API access to the asset until this date. Nil means "now."
 *
 *  @param expiryDate Virtuoso will not provide API access to the asset after this date. Nil means no expiry.
 *
 *  @param expiryAfterDownload  Amount of time after Virtuoso completes download of the asset that
 *                              Virtuoso will delete the asset. In seconds. <=0 means no expiry.
 *
 *  @param expiryAfterPlay Amount of time after the asset is first played that
 *                         Virtuoso will delete the asset. In seconds. <=0 means no expiry.
 *
 *  @param enableFastPlay If enabled, Virtuoso will automatically download the initial portion of the asset as soon
 *                        as the asset is created.  Whenever an asset is streamed, the cached beginning of the asset
 *                        will be returned to the player immediatley, eliminating startup buffer time for streamed playback.
 *
 *  @param userInfo A convenience field allowing you to associate arbitrary data with an asset.
 *                  Virtuoso will serialize this data and store it, but not explicitly use this data.
 *                  The provided userInfo must be property-list compatible. May be nil.
 *
 *  @param readyBlock Called when the asset is ready to be added to the download queue
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 *
 *  @return A new (empty) VirtuosoAsset object, or nil if there was an error.
 *
 */
+ (nullable VirtuosoAsset*)assetWithAssetID:(nonnull NSString*)assetID
                       description:(nonnull NSString*)description
                       manifestUrl:(nonnull NSString*)manifestUrl
                    protectionType:(kVDE_AssetProtectionType)protectionType
             includeEncryptionKeys:(Boolean)includeEncryption
                    maximumBitrate:(long long)maximumBitrate
                       publishDate:(nullable NSDate*)publishDate
                        expiryDate:(nullable NSDate*)expiryDate
               expiryAfterDownload:(NSTimeInterval)expiryAfterDownload
                   expiryAfterPlay:(NSTimeInterval)expiryAfterPlay
                    enableFastPlay:(Boolean)enableFastPlay
                          userInfo:(nullable NSDictionary*)userInfo
                onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                   onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/**---------------------------------------------------------------------------------------
 * @name Update HLS Assets
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Adds a manifest URL to this VirtuosoAsset.  Call does nothing if the VirtuosoAsset is
 *            not an HLS asset.
 *
 *  @param manifestUrl Where the manifest lives on the Internet.
 *
 *  @param includeEncryption If YES, then this method will download any encryption keys in
 *                           manifest.  Normally, you would pass YES, but this allows for custom behaviors.
 *
 *  @param maximumBitrate For manifests containing multiple profiles, Virtuoso will select the highest bitrate
 *                        profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest
 *                        bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
 *                        select the lowest bitrate profile.  A value of INT_MAX means "use the highest bitrate."
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 */
- (void)setManifestURL:(nonnull NSString*)manifestUrl
 includeEncryptionKeys:(Boolean)includeEncryption
    withMaximumBitrate:(long long)maximumBitrate
       onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/**---------------------------------------------------------------------------------------
 * @name HLS Playback
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Returns the local file path for the HLS manifest of the given type and subtype
 *
 *  @discussion If the type is hlsManifestTypeMaster, then subtype is ignored.  If you are requesting
 *              a language or closed captioning sub-manifest, then subtype should be the language code
 *              for the specified manifest.  If you are requesting a particular bitrate stream, then 
 *              subtype should be the bitrate of the stream, represented as a string.
 *
 *  @warning If this asset is not available (Virtuoso is in an timed-out state, the asset is
 *           outside its availability window or the asset is expired), then this method will return nil,
 *           preventing API access to the asset.
 *
 *  @param type The HLS manifest type to return
 *  @param subtype The subtype of the manifest to return
 *
 *  @return The local file path for the HLS manifest of the given type and subtype
 */
- (nullable NSString*)hlsManifestLocalPathForType:(kVDM_ManifestType)type forSubtype:(nullable NSString*)subtype;

/**---------------------------------------------------------------------------------------
 * @name HLS Properties
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract The local file path for the saved FastPlay manifest file
 */
- (nullable NSString*)hlsManifestFastPlayPath;

@end

#endif
