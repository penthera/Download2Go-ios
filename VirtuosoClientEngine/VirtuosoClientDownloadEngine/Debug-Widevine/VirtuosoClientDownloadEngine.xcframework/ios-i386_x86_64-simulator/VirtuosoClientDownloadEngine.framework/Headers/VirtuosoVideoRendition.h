/*!
 *  @header Virtuoso Video Rendition
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

const static long long NOT_PRESENT = 0;

@class VirtuosoAsset;

/*!
 *  @abstract Defines metadata for a video rendition within a multistream HLS manifest.
 *
 *  @discussion Virtuoso will automatically select video renditions based on the supplied
 *              filters and maximum bitrate provided during asset creation.  If you have
 *              more advanced requirements for rendition selection that cannot be fulfilled
 *              by the automatic selection process, you may define your own selection by
 *              assigning a VirtuosoRenditionSelectionDelegate.  Prior to selecting the
 *              rendition for download, the SDK will provide the VirtuosoRenditionSelectionDelegate
 *              a list of VirtuosoVideoRendition objects.  You may choose which one you
 *              would like to use for download, and return that to the delegate call.
 */
@interface VirtuosoVideoRendition : NSObject

@property (nonatomic,readonly) int bandwidth;
@property (nonatomic,readonly) int averageBandwidth;
@property (nonatomic,readonly) NSString* codecs;
@property (nonatomic,readonly) NSString* resolution;
@property (nonatomic,readonly) NSString* audio;
@property (nonatomic,readonly) NSString* video;
@property (nonatomic,readonly) NSString* subtitles;
@property (nonatomic,readonly) NSString* closedCaptions;

@property (nonatomic,readonly) NSString* renditionDefinition;
@property (nonatomic,readonly) NSString* renditionUrl;
@property (nonatomic,readonly) NSString* renditionLocalUrl;

- (id)initWithRenditionDefinition:(NSString*)renditionDefinition url:(NSString*)url localUrl:(NSString*)localUrl;

@end

/*!
 *  @abstract Provides a mechanism to manually choose which video rendition will be used for download and ignore SDK-internal processing,
 *            which is based on configured codec and resolution filters and the supplied maximum bitrate value.
 *
 *  @discussion If an asset is assigned a video rendition selection delegate, then the choice the delegate makes will be honored, rather than
 *              the choice made by internal processing.  If the delegate returns nil, or is not assigned, SDK internal rules will be applied.
 */
@protocol VirtuosoRenditionSelectionDelegate<NSObject>

/*!
 *  @abstract Called whenever the video rendition is to be selected.
 *
 *  @param renditions Array of VirtuosoVideoRendition objects representing available video renditions
 *
 *  @param asset VirtuosoAsset asset
 */

- (VirtuosoVideoRendition* _Nullable)selectRenditionFromAvailableRenditions:(NSArray<VirtuosoVideoRendition*>*)renditions forAsset:(VirtuosoAsset*)asset;

@end

NS_ASSUME_NONNULL_END
