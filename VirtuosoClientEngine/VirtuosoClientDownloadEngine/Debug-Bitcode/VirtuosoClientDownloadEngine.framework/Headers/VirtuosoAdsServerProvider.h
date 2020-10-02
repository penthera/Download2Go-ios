//
//  VirtuosoAdsServerProvider.h
//  VirtuosoClientDownloadEngine
//
//  Created by jkountz on 9/28/18.
//  Copyright © 2018 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtuosoAdsProvider.h"

#ifndef VirtuosoAdsServerProvider_Included
#define VirtuosoAdsServerProvider_Included

/*!
 *  @typedef ServerAdProvider
 *
 *  @abstract Defines the various types of Server Ads Providers
 *
 */
typedef NS_ENUM(NSInteger, ServerAdProvider)
{
    /** Undefined. */
    ServerAdProvider_Undefined,
    
    /** Freewheel Server Ads. */
    ServerAdProvider_Google,
    
    /** Google Server Ads. */
    ServerAdProvider_Verizon
};

/*!
* @abstract Base class for Server-Side AdsProviders
*
* @discussion This class defines the comon methods and properties shared by all Server-Side Ads providers
*/
@interface VirtuosoAdsServerProvider : VirtuosoAdsProvider

/*!
* @abstract Type of Server Ad (see enum ServerAdProvider)
*/
@property (nonatomic, assign, readonly)ServerAdProvider type;

/*!
 * @abstract Creates a Google Server Ads Provider
 *
 * @return Instance of VirtuosoAdsServerProvider
 */
+(instancetype _Nullable)GoogleAdsProvider;

/*!
 * @abstract Creates a Verizon Server Ads Provider
 *
 * @return Instance of VirtuosoAdsServerProvider
 */
+(instancetype _Nullable)VerizonAdsProvider;

/*!
 * @abstract Create instance of Server-Side Ads Provider.
 *
 * @param type ServerAdProvider type indicating type of server ads provider.
 *
 * @return True indicates success.
 */
-(instancetype _Nullable)initWithType:(ServerAdProvider)type;

@end

#endif
