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
- (NSString* _Nullable)extractCIDForAsset:(VirtuosoAsset* _Nonnull)asset fromFairPlayRequest:(NSURL* _Nonnull)fpRequest;

/*!
 *  @abstract Allows custom processing of the FairPlay POST body before it is send.
 *
 *  @discussion Normally, the SPC data is posted as binary as the POST body to the fairplay server.
 *              If this is the case, you can just return the spc input without modification.  If your
 *              server requires some custom format (base64 encoding or JSON wrapping, for example), then you
 *              should receive the input SPC and return an NSData object suitable for posting in the POST body
 *              to your licensing server.
 *
 *  @param asset The VirtuosoAsset the licensing request is for
 *  @param spc The Apple-generated SPC data value
 *  @return An NSData object suitable for the license server POST body
 */
- (NSData* _Nullable)prepareSPCForAsset:(VirtuosoAsset* _Nonnull)asset inLicenseRequest:(NSData* _Nonnull)spc;

/*!
 *  @abstract Allows custom processing of the FairPlay license server response
 *
 *  @discussion Normally, the license server responds to a FairPlay request with binary representing
 *              the license response (CKC).  Some license servers wrap this CKC data with other encodings,
 *              such as base64 or JSON wrappers.  If your license server returns something other than raw
 *              CKC data, you will need to implement this method.  You should parse the response data and return
 *              the raw CKC data object, suitable for handing back to the player in the AVASsetResourceLoaderDelegate response.
 *
 *  @param asset The VirtuosoAsset the licensing request is for
 *  @param response The received response from the license server
 *  @return CKC data value suitable for handing to the player for DRM licensing
 */
- (NSData* _Nullable)extractCKCForAsset:(VirtuosoAsset* _Nonnull)asset inLicenseResponse:(NSData* _Nonnull)response;

@optional
/*!
* @abstract If you have configured custom DRM Types, this method allows you to indicate which to use for processing this asset.
*
* @discussion Normally, the resource loader will use the kVLM_FairPlay DRM type to process all requests using the configuration
*                           stored in the VirtuosoLicenseManager.  However, if you need to use different DRM systems for different assets you
*                           wish to download, you can set configuratins with VirtuosoLicenseManager using custom DRM type codes and
*                           implement this method to indicate which DRM SubType should be used for the asset. The SubType is an arbitrary, non-nil string that uniquely identifies ths DRM system.
*
*
*  @param asset The VirtuosoAsset to resolve DRM SubType for.
*  @return non-nil string ideitifying the DRM SubType for the Asset.
*/
- (NSString* _Nullable)drmSubTypeForAsset:(VirtuosoAsset* _Nonnull)asset;

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


/*!
 *  @abstract Sets the license processing delegate
 *
 *  @param delegate The license processing delegate
 */
+ (void)setLicenseProcessingDelegate:(id<VirtuosoLicenseProcessingDelegate>_Nonnull)delegate;

@end
