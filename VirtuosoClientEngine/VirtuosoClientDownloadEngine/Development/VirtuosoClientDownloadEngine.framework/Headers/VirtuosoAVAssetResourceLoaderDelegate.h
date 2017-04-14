//
//  VirtuosoAVAssetResourceLoaderDelegate.h
//  VirtuosoClientDownloadEngine
//
//  Created by Josh Pressnell on 8/15/16.
//  Copyright © 2016 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VirtuosoAVAssetResourceLoaderDelegate;
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
- (void)resourceLoaderDelegate:(VirtuosoAVAssetResourceLoaderDelegate*)delegate generatedError:(NSError*)error;

@end

/*!
 *  @abstract A convenience subclass that automatically handles FairPlay licensing using the VirtuosoLicenseManager configuration
 *
 *  @discussion The VirtuosoAVAssetResourceLoaderDelegate automatically uses the configured VirtuosoLicenseManager settings to request
 *              streaming or persistent FairPlay licenses.  If you attempt to use FairPlay licensing on a version of iOS that does not
 *              support persistence, this class automatically degrades to requesting streaming-only keys, and playback of the downloaded
 *              content will only work while the device is online and capable of re-requesting streaming keys.
 */
@interface VirtuosoAVAssetResourceLoaderDelegate : NSObject<AVAssetResourceLoaderDelegate>

/*!
 *  @abstract The VirtuosoAsset that is going to be played
 */
@property (nonatomic,strong) VirtuosoAsset* asset;

/*!
 *  @abstract Whether to load a persistent offline FairPlay license
 */
@property (nonatomic,assign) Boolean loadPersistentLicense;

/*!
 *  @abstract An error handler to receive errors encountered while generating FairPlay licenses
 */
@property (nonatomic,weak) id<VirtuosoAVAssetResourceLoaderDelegateErrorHandler> errorHandler;

@end
