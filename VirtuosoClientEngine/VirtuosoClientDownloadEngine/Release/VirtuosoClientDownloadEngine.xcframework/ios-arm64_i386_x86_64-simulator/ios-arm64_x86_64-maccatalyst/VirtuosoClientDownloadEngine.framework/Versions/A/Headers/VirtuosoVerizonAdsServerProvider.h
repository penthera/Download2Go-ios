//
//  VirtuosoVerizonAdsServerProvider.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 4/29/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "VirtuosoAdsServerProvider.h"

NS_ASSUME_NONNULL_BEGIN

/*!
* @abstract Base class for Verizion VAST Ads
*
* @discussion Implements the Verizion VAST Ads Provider
*/
@interface VirtuosoVerizonAdsServerProvider : VirtuosoAdsServerProvider

/*!
 * @abstract Creates an instance of this Ads Provider
 *
 * @param url Preplay URL for Ads and Asset Manifest
 *
 * @return Instance, nill the URL parameter was invalid
 */
-(nullable instancetype)initWithPreplayUrl:(nonnull NSString*)url;

@end

NS_ASSUME_NONNULL_END
