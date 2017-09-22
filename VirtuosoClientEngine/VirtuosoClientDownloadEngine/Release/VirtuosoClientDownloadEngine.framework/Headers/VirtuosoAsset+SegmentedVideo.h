/*!
 *  @header Virtuoso Asset (Segmented Video)
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

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

/*!
 *  @discussion Provides additional types and methods used to handle segmented video
 */
@interface VirtuosoAsset (SegmentedVideo)

/**---------------------------------------------------------------------------------------
 * @name Segmented Video Methods
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract The number of segments that could not be downloaded in this asset.
 *
 *  @discussion This value will always be 0 unless the option in VirtuosoSettings is 
 *              configured to permit downloading after segment errors are hit.
 */
- (NSUInteger)segmentDownloadErrors;

/**---------------------------------------------------------------------------------------
 * @name Segmented Video Properties
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Where the manifest for this asset lives on the Internet.
 *
 *  @discussion The remote URL is the addressable location on the Internet.  The URL must include any
 *              security or CDN tokens required to download the asset.
 *
 *              If your CDN uses dynamic URLs or another method where URLs change over time, Virtuoso
 *              may need to issue a network request to get a 'fresh' URL.  In that case, this method
 *              will block during this network request.
 */
@property (nonatomic,readonly,nullable) NSString* manifestRemoteURL;

/*!
 *  @abstract The local file path for the saved master manifest file
 *
 *  @warning If this asset is not available (Virtuoso is in an timed-out state, the asset is
 *           outside its availability window or the asset is expired), then this property will return nil,
 *           preventing API access to the asset.
 */
@property (nonatomic,readonly,nullable) NSString* manifestLocalPath;

/*!
 *  @abstract The video bitrate of this asset when downloaded
 *
 *  @discussion If the provided manifest contained multiple video profiles, then this property contains the
 *              bitrate of the profile selected for download.  If Virtuoso could not determine the bitrate,
 *              then this property will return 0.  If the asset contains both video and audio in a single
 *              stream, then this property will return the same value as the audioStreamBitrate property.
 */
@property (nonatomic,readonly) long long videoStreamBitrate;

/*!
 *  @abstract The audio bitrate of this asset when downloaded
 *
 *  @discussion If the provided manifest contained multiple audio profiles, then this property contains the
 *              bitrate of the profile selected for download.  If Virtuoso could not determine the bitrate,
 *              then this property will return 0.  If the asset contains both video and audio in a single
 *              stream, then this property will return the same value as the videoStreamBitrate property.
 */
@property (nonatomic,readonly) long long audioStreamBitrate;

/*!
 *  @abstract The audio languages to download
 *
 *  @discussion For manifests containing multiple audio language definitions, it is possible to specify which
 *              languages will be downloaded.  If the languages were filtered when this asset was created,
 *              then the languages that were downloaded will be returned.  If all languages were downloaded,
 *              this property will be nil.
 */
@property (nonatomic,readonly,nullable) NSArray* selectedAudio;

/*!
 *  @abstract The subtitle languages to download
 *
 *  @discussion For manifests containing multiple subtitle language definitions, it is possible to specify which
 *              languages will be downloaded.  If the languages were filtered when this asset was created,
 *              then the languages that were downloaded will be returned.  If all languages were downloaded,
 *              this property will be nil.
 */
@property (nonatomic,readonly,nullable) NSArray* selectedSubtitles;

@end
