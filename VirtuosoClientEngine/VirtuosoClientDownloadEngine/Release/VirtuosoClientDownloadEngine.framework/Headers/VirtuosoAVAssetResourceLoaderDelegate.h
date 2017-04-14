/*!
 *  @header VirtuosoAVAssetResourceLoaderDelegate
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
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VirtuosoAVAssetResourceLoaderDelegate;
@class VirtuosoAsset;

/*!
 *  @abstract Provides a mechanism to easily identify and handle errors encountered during the DRM licensing process
 */
@protocol VirtuosoAVAssetResourceLoaderDelegateErrorHandler <NSObject>

/*!
 *  @abstract Called when an error has been encountered during the DRM licensing process
 *
 *  @param delegate The VirtuosoAVAssetResourceLoaderDelegate that encountered the error
 *  @param error The error describing the issue.
 */
- (void)resourceLoaderDelegate:(nonnull id<VirtuosoAVAssetResourceLoaderDelegate>)delegate generatedError:(nonnull NSError*)error;

@end

/*!
 *  @abstract Provides a mechanism to automatically handle FairPlay licensing using the VirtuosoLicenseManager configuration
 *
 *  @discussion The VirtuosoAVAssetResourceLoaderDelegate automatically uses the configured VirtuosoLicenseManager settings to request
 *              streaming or persistent FairPlay licenses.  If you attempt to use FairPlay licensing on a version of iOS that does not
 *              support persistence, this class automatically degrades to requesting streaming-only keys, and playback of the downloaded
 *              content will only work while the device is online and capable of re-requesting streaming keys.
 */
@protocol VirtuosoAVAssetResourceLoaderDelegate<NSObject,AVAssetResourceLoaderDelegate>

/*!
 *  @abstract The VirtuosoAsset that is going to be played
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;

/*!
 *  @abstract Whether to load a persistent offline FairPlay license
 */
@property (nonatomic,assign) Boolean loadPersistentLicense;

/*!
 *  @abstract An error handler to receive errors encountered while generating FairPlay licenses
 */
@property (nonatomic,weak,nullable) id<VirtuosoAVAssetResourceLoaderDelegateErrorHandler> errorHandler;

@end
