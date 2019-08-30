/*!
 *  @header VirtuosoDefaultAVAssetResourceLoaderDelegate
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
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>

/*!
 *  @abstract  Allows Virtuoso to request the enclosing application for asset specific DRM
 *             values when requesting FairPlay license keys.
 */
@interface VirtuosoDrmConfig : NSObject
@end

/*!
 *  @abstract  Allows Virtuoso to request the enclosing application for asset specific DRM
 *             values when requesting FairPlay license keys.
 */
@protocol VirtuosoDrmConfigDelegate <NSObject>

/*!
 *  @abstract  Called when the DRM subsystem needs a DRM configuration to make a licensing request.
 *
 *  @param asset The VirtuosoAsset object that will request a FairPlay license.
 *
 *  @return A properly configured DrmConfig object containing proper licensing details for the asset.
 *
 *  @warning You should never return an instance of the base DrmConfig class.  Depending on your
 *           configured AVAssetResourceLoaderDelegate subclass, you should return an appropriate
 *           DRMConfig subclass from the available options.
 */
- (VirtuosoDrmConfig*)drmConfigForAsset:(VirtuosoAsset*)asset;

@end

/*!
 *  @abstract  Allows custom processing of the SPC license request and the license response
 */
@protocol VirtuosoLicenseProcessingDelegate <NSObject>

- (NSData*)prepareSPCForLicenseRequest:(NSData*)spc;
- (NSData*)extractCKCFromLicenseResponse:(NSData*)response;

@end


/*!
 *  @abstract A convenience subclass that automatically handles basic FairPlay licensing using the VirtuosoLicenseManager configuration
 *
 *  @discussion The VirtuosoDefaultAVAssetResourceLoaderDelegate automatically uses the configured VirtuosoLicenseManager settings to request
 *              streaming or persistent FairPlay licenses.  If you attempt to use FairPlay licensing on a version of iOS that does not
 *              support persistence, this class automatically degrades to requesting streaming-only keys, and playback of the downloaded
 *              content will only work while the device is online and capable of re-requesting streaming keys.
 */
@interface VirtuosoDefaultAVAssetResourceLoaderDelegate : NSObject<VirtuosoAVAssetResourceLoaderDelegate>

+ (void)setLicenseProcessingDelegate:(id<VirtuosoLicenseProcessingDelegate>)delegate;

@end
