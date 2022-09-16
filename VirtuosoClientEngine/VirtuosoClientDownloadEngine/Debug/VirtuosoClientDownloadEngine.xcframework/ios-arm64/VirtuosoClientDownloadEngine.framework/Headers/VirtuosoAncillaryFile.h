/*!
 *  @header VirtuosoAncillaryFile
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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 */
#ifndef VIRTUOSOANCILLARYFILE_INCLUDE
#define VIRTUOSOANCILLARYFILE_INCLUDE

#import <Foundation/Foundation.h>
#import "VirtuosoAsset.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#import <AppKit/AppKit.h>
#endif

/*!
 *  @abstract An abstract object that can be downloaded "as part" of a VirtuosoAsset
 *            download.  These may represent out-of-manifest closed caption files,
 *            cover art images, or other files that you may want to keep associated
 *            with the asset.
 *
 *            This is an advanced feature which is entirely optional.
 */
@interface VirtuosoAncillaryFile : NSObject

/*!
 *  @abstract UUID of the ancillary
 *
 *  @discussion Property is set once Ancillary has been created
 */
@property (nonatomic, readonly)NSString* _Nullable uuid;

/*!
 *  @abstract URL for this ancillary
 *
 *  @discussion The remote URL for the ancillary
 */
@property (nonatomic,readonly)NSString* _Nonnull fileDownloadURL;

/*!
 *  @abstract tag optional string that can be used to identify
 *
 *  @discussion Specifying a tag will allow targeted searches
 */
@property (nonatomic,readonly)NSString* _Nullable tag;

/*!
 *  @abstract URL for this ancillary
 *
 *  @discussion The remote URL for the ancillary
 */
@property (nonatomic,readonly,nullable) NSString* localFilePath;

/*!
 *  @abstract The current size of this ancillary
 *
 *  @discussion The amount of data that Virtuoso has downloaded for this ancillary (in bytes)
 */
@property (nonatomic,readonly) long long currentSize;

/*!
 *  @abstract The expected size of this ancillary
 *
 *  @discussion The amount of data that Virtuoso will downloaded for this ancillary (in bytes)
 */
@property (nonatomic,readonly) long long expectedSize;

/*!
 *  @abstract Indicates the ancillary has been downloaded
 *
 *  @discussion Boolean value true when downloaded
 */
@property (nonatomic,readonly)Boolean isDownloaded;

/*!
 *  @abstract Image representing this Ancillary
 *
 *  @discussion Returns an instance of the Image representing this ancillary. The ancillary must be a valid image.
 */
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@property (nonatomic,readonly,nullable)UIImage* image;
#else
@property (nonatomic,readonly,nullable)NSImage* image;
#endif

/*!
 *  @abstract Indicates the ancillary is client ad media content
 *
 *  @discussion Boolean value true when downloaded
 */
@property (nonatomic,assign, readonly)Boolean isAd;

/*!
 *  @abstract Creates instance of Ancillary file
 *
 *  @param downloadUrl URL of the file to be downloaded. Required.
 *
 *  @return instance of the object
 */
-(instancetype _Nullable)initWithDownloadUrl:(NSString* _Nonnull)downloadUrl;

/*!
 *  @abstract Creates instance of Ancillary file
 *
 *  @param downloadUrl URL of the file to be downloaded. Required.
 *
 *  @param tag user defined string that identifies this ancillary.
 *
 *  @return instance of the object
 */
-(instancetype _Nullable)initWithDownloadUrl:(NSString* _Nonnull)downloadUrl andTag:(NSString* _Nullable)tag;

@end

#endif

