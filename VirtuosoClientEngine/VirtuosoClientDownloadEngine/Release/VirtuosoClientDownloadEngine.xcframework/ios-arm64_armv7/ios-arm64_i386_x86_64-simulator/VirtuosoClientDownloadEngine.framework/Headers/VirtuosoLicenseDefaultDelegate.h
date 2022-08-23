//
//  VirtuosoLicenseDelegateHelper.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/14/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtuosoLicenseManager.h"

NS_ASSUME_NONNULL_BEGIN

/*!
*  @abstract Implments a general purpose delegate for VirtuosoLicenseManagerDelegate.
*
*  @discussion This class can be used to provide a delegate for LicenseManager.
*                       Create an instanace, add license configuration objects for each asset you need to process and the class will automatically handle the delegate callbacks.
*
*/
@interface VirtuosoLicenseDelegateHelper : NSObject <VirtuosoLicenseManagerDelegate>

/*!
*  @abstract Adds VirtuosoLicenseConfiguration for the specified AssetID.
*
* @param config Instance of VirtuosoLicenseConfiguration object that will be used to initialize the license
* @param assetID Identifies the asset to which this License applies.
*
*  @return True if successful. False indicates one of the required parameters was invalid.
*/
-(Boolean)addLicense:(VirtuosoLicenseConfiguration*)config forAssetID:(NSString*)assetID;

/*!
*  @abstract Adds VirtuosoLicenseConfiguration for use with any asset that does not have a specific instance of VirtuosoLicenseConfiguration.
*
* @param config Instance of VirtuosoLicenseConfiguration object that will be used to initialize the license
*
*  @return True if successful. False indicates one of the required parameters was invalid.
*/
-(Boolean)addLicense:(VirtuosoLicenseConfiguration*)config;


/*!
*  @abstract Verifies internal configuration has been setup.
*
*  @return True if contains valid VirtuosoLicenseConfiguration settings.
*/
-(Boolean)isConfigured;

@end

NS_ASSUME_NONNULL_END
