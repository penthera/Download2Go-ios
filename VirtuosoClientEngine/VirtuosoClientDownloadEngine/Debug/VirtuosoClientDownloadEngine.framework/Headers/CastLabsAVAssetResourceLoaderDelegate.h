/*!
 *  @header CastLabsAVAssetResourceLoaderDelegate
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
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract  Allows Virtuoso to request the enclosing application for asset specific DRM
 *             values when requesting CastLabs (DrmToday) FairPlay license keys.
 */
@interface CastLabsDrmConfig : NSObject

/*!
 *  @abstract  The CastLabs user ID.
 */
@property (nonatomic,strong) NSString* clUserID;

/*!
 *  @abstract  A CastLabs session ID appropriate for the asset.
 */
@property (nonatomic,strong) NSString* clSessionID;

/*!
 *  @abstract  The CastLabs Merchant ID
 */
@property (nonatomic,strong) NSString* clCustomerName;
@end

/*!
 *  @abstract  Allows Virtuoso to request the enclosing application for asset specific DRM
 *             values when requesting CastLabs (DrmToday) FairPlay license keys.
 */
@protocol CastLabsDrmConfigDelegate <NSObject>

/*!
 *  @abstract  Called when the DRM subsystem needs a DRM configuration to make a licensing request.
 *
 *  @param asset The VirtuosoAsset object that will request a FairPlay license.
 *
 *  @return A properly configured CastLabsDrmConfig object containing proper licensing details for the asset.
 */
- (CastLabsDrmConfig*)drmConfigForAsset:(VirtuosoAsset*)asset;
@end

/*!
 *  @abstract A convenience subclass that automatically handles CastLabs FairPlay licensing using the VirtuosoLicenseManager configuration
 *
 *  @discussion The CastLabsAVAssetResourceLoaderDelegate automatically uses the configured VirtuosoLicenseManager settings to request
 *              streaming or persistent FairPlay licenses.  If you attempt to use FairPlay licensing on a version of iOS that does not
 *              support persistence, this class automatically degrades to requesting streaming-only keys, and playback of the downloaded
 *              content will only work while the device is online and capable of re-requesting streaming keys.
 */
@interface CastLabsAVAssetResourceLoaderDelegate : NSObject<VirtuosoAVAssetResourceLoaderDelegate>

/*!
 *  @abstract An object to call to reuest asset-specific drm configuration details during licensing.
 *
 *  @warning A proper CastLabsDrmConfigDelegate MUST be configured and the delegate MUST provide all values
 *           from the CastLabsDrmConfig class when called or licensing will fail.
 *
 *  @param delegate The delegate to call curing licensing requests.
 */
+ (void)setDrmConfigDelegate:(id<CastLabsDrmConfigDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
