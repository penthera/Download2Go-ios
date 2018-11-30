//
//  VirtuosoAncillaryFile.h
//  VirtuosoClientDownloadEngine
//
//  Created by jk on 6/25/18.
//  Copyright © 2018 Penthera. All rights reserved.
//
#ifndef VIRTUOSOANCILLARYFILE_INCLUDE
#define VIRTUOSOANCILLARYFILE_INCLUDE

#import <Foundation/Foundation.h>
#import "VirtuosoAsset.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#import <AppKit/AppKit.h>
#endif

@interface VirtuosoAncillaryFile : NSObject


/*!
 *  @abstract URL for this ancillary
 *
 *  @discussion The remote URL for the ancillary
 */
@property (nonatomic,readonly)NSString* _Nonnull fileDownloadURL;

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
 *  @abstract Creates instance of Ancillary file
 *
 *  @param downloadUrl URL of the file to be downloaded. Required.
 *
 *  @return instance of the object
 */
-(instancetype _Nullable)initWithDownloadUrl:(NSString* _Nonnull)downloadUrl;

@end

#endif

