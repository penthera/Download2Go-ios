/*!
 *  @header Virtuoso Asset (DASH)
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

#ifndef VDASH
#define VDASH

#import <VirtuosoClientDownloadEngine/VirtuosoConstants.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+SegmentedVideo.h>

/*!
 *  @discussion Provides types and methods used to handle MPEG Dynamic Adaptive Streaming over HTTP (DASH) video
 */
@interface VirtuosoAsset (DASH)

/**---------------------------------------------------------------------------------------
 * @name DASH Creation
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Creates a new in-memory DASH VirtuosoAsset.
 *
 *  @discussion This constructor uses the default expiry rules.  To customize expiry rules for this asset,
 *              use the constructors that take expiry parameters, or change the expiry values after creation.
 *
 *  @param assetID A unique identifier for the asset. Used in all log events.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param mpdUrl Where the media presentation description (mpd) file lives on the Internet.
 *
 *  @param protectionType You should pass the default value of kVDE_AssetProtectionTypePassthrough unless
 *                        instructed differently by Penthera support.
 *
 *  @param maximumVideoBitrate For mpd files containing multiple profiles, Virtuoso will select the highest bitrate
 *                             profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest
 *                             bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
 *                             select the lowest bitrate profile. A value of INT_MAX means "use the highest bitrate."
 *
 *  @param maximumAudioBitrate Same as maximumVideoBitrate, but for the audio portion of the stream.  If the audio for
 *                             this asset is contained within the video profile, this value is ignored.
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
 *  @return A new (empty) VirtuosoAsset object, or nil if an error occured.
 *
 */
+ (nullable VirtuosoAsset*)assetWithAssetID:(nonnull NSString*)assetID
                                description:(nonnull NSString*)description
                                     mpdUrl:(nonnull NSString*)mpdUrl
                             protectionType:(kVDE_AssetProtectionType)protectionType
                        maximumVideoBitrate:(long long)maximumVideoBitrate
                        maximumAudioBitrate:(long long)maximumAudioBitrate
                                publishDate:(nullable NSDate*)publishDate
                                 expiryDate:(nullable NSDate*)expiryDate
                             enableFastPlay:(Boolean)enableFastPlay
                                   userInfo:(nullable NSDictionary*)userInfo
                         onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                            onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/*!
 *  @abstract Creates a new in-memory DASH VirtuosoAsset object.
 *
 *  @discussion This constructor allows you to set custom expiry rules.
 *
 *  @param assetID A unique identifier for the asset. Used in all log events.
 *
 *  @param description A description of the asset.  Virtuoso only uses this in log output.
 *
 *  @param mpdUrl Where the media presentation description (mpd) file lives on the Internet.
 *
 *  @param protectionType You should pass the default value of kVDE_AssetProtectionTypePassthrough unless
 *                        instructed differently by Penthera support.
 *
 *  @param maximumVideoBitrate For mpd files containing multiple profiles, Virtuoso will select the highest bitrate
 *                             profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest
 *                             bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
 *                             select the lowest bitrate profile. A value of INT_MAX means "use the highest bitrate."
 *
 *  @param maximumAudioBitrate Same as maximumVideoBitrate, but for the audio portion of the stream.  If the audio for
 *                             this asset is contained within the video profile, this value is ignored.
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
 *  @return A new (empty) VirtuosoAsset object, or nil if an error occured.
 *
 */
+ (nullable VirtuosoAsset*)assetWithAssetID:(nonnull NSString*)assetID
                                description:(nonnull NSString*)description
                                     mpdUrl:(nonnull NSString*)mpdUrl
                             protectionType:(kVDE_AssetProtectionType)protectionType
                        maximumVideoBitrate:(long long)maximumVideoBitrate
                        maximumAudioBitrate:(long long)maximumAudioBitrate
                                publishDate:(nullable NSDate*)publishDate
                                 expiryDate:(nullable NSDate*)expiryDate
                        expiryAfterDownload:(NSTimeInterval)expiryAfterDownload
                            expiryAfterPlay:(NSTimeInterval)expiryAfterPlay
                             enableFastPlay:(Boolean)enableFastPlay
                                   userInfo:(nullable NSDictionary*)userInfo
                         onReadyForDownload:(nullable AssetReadyForDownloadBlock)readyBlock
                            onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

/**---------------------------------------------------------------------------------------
 * @name Update DASH Assets
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Adds a mpd URL to this VirtuosoAsset.  Call does nothing if the VirtuosoAsset is
 *            not a DASH asset.
 *
 *  @param mpdUrl Where the media presentation description (mpd) lives on the Internet.
 *
 *  @param maximumVideoBitrate For mpd files containing multiple profiles, Virtuoso will select the highest bitrate
 *                             profile whose bitrate doesn't exceed this value. A value of 1 means "use the lowest
 *                             bitrate." If there's no profile of lower bitrate than maximumBitrate, Virtuoso will
 *                             select the lowest bitrate profile. A value of INT_MAX means "use the highest bitrate."
 *
 *  @param maximumAudioBitrate Same as maximumVideoBitrate, but for the audio portion of the stream.  If the audio for
 *                             this asset is contained within the video profile, this value is ignored.
 *
 *  @param completeBlock Called when asset parsing completes. May be nil.
 */
- (void)setMpdURL:(nonnull NSString*)mpdUrl
withMaximumVideoBitrate:(long long)maximumVideoBitrate
andMaximumAudioBitrate:(long long)maximumAudioBitrate
  onParseComplete:(nullable AssetParsingCompletedBlock)completeBlock;

@end

#endif
