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

/*!
 *  @abstract Allows a custom CID to be used with the SDK default AVAssetResourceLoaderDelegate
 *
 *  @discussion Normally, the asset CID is extracted from the FairPlay license URL, which takes the form
 *              skd://<contentID>.  Some license servers put the required content ID elsewhere.  If you
 *              don't need to adjust the content ID, you can return nil and the SDK will use the default value
 *              it detects.  If you need to override this value, you can return the proper content ID to use from
 *              this method.
 *
 *  @param asset The VirtuosoAsset the licensing request is for
 *  @param fpRequest The URL provided to the AVAssetResourceLoaderDelegate for the licensing request
 *  @return The CID value to use during SPC creation
 */
- (NSString*)extractCIDForAsset:(VirtuosoAsset*)asset fromFairPlayRequest:(NSURL*)fpRequest;

/*!
 *  @abstract Allows custom processing of the FairPlay POST body before it is send.
 *
 *  @discussion Normally, the SPC data is posted as binary as the POST body to the fairplay server.
 *              If this is the case, you can just return the spc input without modification.  If your
 *              server requires some custom format (base64 encoding or JSON wrapping, for example), then you
 *              should receive the input SPC and return an NSData object suitable for posting in the POST body
 *              to your licensing server.
 *
 *  @param spc The Apple-generated SPC data value
 *  @return An NSData object suitable for the license server POST body
 */
- (NSData*)prepareSPCForLicenseRequest:(NSData*)spc;

/*!
 *  @abstract Allows custom processing of the FairPlay license server response
 *
 *  @discussion Normally, the license server responds to a FairPlay request with binary representing
 *              the license response (CKC).  Some license servers wrap this CKC data with other encodings,
 *              such as base64 or JSON wrappers.  If your license server returns something other than raw
 *              CKC data, you will need to implement this method.  You should parse the response data and return
 *              the raw CKC data object, suitable for handing back to the player in the AVASsetResourceLoaderDelegate response.
 *
 *  @param response The received response from the license server
 *  @return CKC data value suitable for handing to the player for DRM licensing
 */
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
