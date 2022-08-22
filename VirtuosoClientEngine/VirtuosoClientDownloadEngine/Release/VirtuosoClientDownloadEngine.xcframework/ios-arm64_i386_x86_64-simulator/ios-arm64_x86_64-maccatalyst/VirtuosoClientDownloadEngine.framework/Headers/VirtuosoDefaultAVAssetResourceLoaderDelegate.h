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
#import <VirtuosoClientDownloadEngine/VirtuosoLicenseManager.h>

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
- (VirtuosoDrmConfig* _Nonnull)drmConfigForAsset:(VirtuosoAsset* _Nonnull)asset;

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

/*!
 *  @abstract If you have custom work unrelated to FairPlay DRM, you may need to set a child delegate.  For all calls that the VIrtuoso SDK does not
 *            directly handle, the call will be handed to the child delegate to service.
 *
 *  @param subdelegate A secondary delegate to call for non-FairPlay requests
 */
- (void)setChildAVAssetResourceLoaderDelegate:(id<AVAssetResourceLoaderDelegate>_Nullable)subdelegate;

@end
