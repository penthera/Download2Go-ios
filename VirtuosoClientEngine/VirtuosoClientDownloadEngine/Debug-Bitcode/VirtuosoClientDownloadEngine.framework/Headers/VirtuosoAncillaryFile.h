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


@property (nonatomic,readonly)NSString* _Nonnull fileDownloadURL;
@property (nonatomic,readonly,nullable) NSString* filePath;
@property (nonatomic,readonly,nullable) NSString* localFilePath;
@property (nonatomic,readonly) long long currentSize;
@property (nonatomic,readonly) long long expectedSize;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@property (nonatomic,readonly,nullable)UIImage* image;
#else
@property (nonatomic,readonly,nullable)NSImage* image;
#endif


// TODO: copy doc's from VAsset header
+ (Boolean)addFile:(VirtuosoAncillaryFile* _Nonnull)file inAsset:(VirtuosoAsset* _Nonnull)asset;

// TODO: copy doc's from VAsset header
+ (Boolean)addFile:(VirtuosoAncillaryFile* _Nonnull)file inAsset:(VirtuosoAsset* _Nonnull)asset andSaveContext:(Boolean)saveContext;

// TODO: comment this
-(instancetype _Nullable)initWithDownloadUrl:(NSString* _Nonnull)downloadUrl;

@end

#endif

