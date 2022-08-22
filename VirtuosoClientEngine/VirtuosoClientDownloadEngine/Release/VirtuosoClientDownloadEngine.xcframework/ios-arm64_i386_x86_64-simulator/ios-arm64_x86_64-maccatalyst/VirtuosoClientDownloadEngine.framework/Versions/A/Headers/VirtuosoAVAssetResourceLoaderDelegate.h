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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 *
 */
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VirtuosoAVAssetResourceLoaderDelegate;
@class VirtuosoAsset;

/*!
 *  @typedef kVAV_ErrorCode
 *
 *  @abstract Resource loader error codes
 */
typedef NS_ENUM(NSInteger, kVAV_ErrorCode)
{
    /** Error generated when no FairPlay certificate is available */
    kVAV_NoCertificate = -1,
    
    /** Error generated when the FairPlay license expires while the device is offline */
    kVAV_ExpiredWhileOffline = -2,

    /** The resource loading delegate must be configured with delegate prior to use. */
    kVAV_NotConfiguredWithDelegate = -3,
    
    /** The resource loading delegate must be configured with a VirtuosoAsset prior to use */
    kVAV_NotConfiguredWithAsset = -4,

    /** The resoruce loader delegate must be configured with an instance of VirtuosoDrmConfig */
    kVAV_NotConfiguredWithDrmConfig = -5,

    /** The VirtuosoDrmConfig returned invalid configuration values.*/
    kVAV_DrmConfigInvalidValues = -6,

    /** Generated nil SPC */
    kVAV_InvalidSPCValue = -7,
    
    /** Could not find assetID in SDK data */
    kVAV_InvalidAssetIDValue = -8,

    /** Player request CID did not match asset CID */
    kVAV_MismatchedCID = -9,
};

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
- (void)resourceLoaderDelegate:(nonnull id<VirtuosoAVAssetResourceLoaderDelegate>)delegate generatedError:(nullable NSError*)error;

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

@required
/*!
 *  @abstract Whether to load a persistent offline FairPlay license.  Defaults to YES.
 */
@property (nonatomic,assign) Boolean loadPersistentLicense;

/*!
 *  @abstract An error handler to receive errors encountered while generating FairPlay licenses
 */
@property (nonatomic,weak,nullable) id<VirtuosoAVAssetResourceLoaderDelegateErrorHandler> errorHandler;


@optional
/*!
 *  @abstract The VirtuosoAsset that is going to be played
 *
 * @warning This property is no longer used and will be removed in a future release.
 */
@property (nonatomic,strong,nullable) VirtuosoAsset* asset;


@end
