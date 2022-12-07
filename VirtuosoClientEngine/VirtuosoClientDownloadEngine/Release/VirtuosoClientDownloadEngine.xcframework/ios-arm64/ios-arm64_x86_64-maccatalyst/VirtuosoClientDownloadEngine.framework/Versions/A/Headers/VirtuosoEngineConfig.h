//
//  VirtuosoEngineConfig.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 8/16/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtuosoConstants.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Used to configure the VirtuosoDownloadEngine during startup
 *
 */
@interface VirtuosoEngineConfig : NSObject

/*!
 * @abstract user The Backplane user to use.  This is a string representing your authenticated user ID.
 *              It could be your actual user ID, or a hash of your user ID.  The only requirements are that
 *              it uniqely identifies your user and the value must be less than 512 characters long.
 */
@property (nonatomic, copy, readonly)NSString* user;

/*!
 * @abstract backplaneURL A root URL pointing to the location of the Backplane endpoints
 *
 */
@property (nonatomic, copy, readonly)NSString* backplaneUrl;

/*!
 * @abstract publicKey The Penthera-provided public key
 *
 */
@property (nonatomic, copy, readonly)NSString* publicKey;

/*!
 * @abstract privateKey The Penthera-provided private key
 *
 */
@property (nonatomic, copy, readonly)NSString* privateKey;

/*!
 * @abstract externalDeviceID An optional externally-defined device UUID
 *
 */
@property (nonatomic, copy, readonly)NSString* externalDeviceID;

/*!
 * @abstract Initialize the download engine.
 *
 * @discussion Parameter values for backplaneUrl, publicKey, and privateKey must be set in the Application Bundle info.plist
 *
 * @param user The Backplane user to use
 *
 * @return valid instance, nil on error
 */
-(instancetype _Nullable)initWithUser:(NSString*)user;

/*!
 * @abstract Initialize the download engine.
 *
 * @discussion Parameter values for backplaneUrl, publicKey, and privateKey must be set in the Application Bundle info.plist
 *
 * @param user The Backplane user to use
 *
 * @param externalDeviceID An optional externally-defined device UUID
 *
 * @return valid instance, nil on error
 *
 */
-(instancetype _Nullable)initWithUser:(NSString*)user
                     externalDeviceID:(NSString*)externalDeviceID;

/*!
 * @abstract Initialize the download engine.
 *
 * @discussion Parameter values for backplaneUrl, publicKey, and privateKey must be set in the Application Bundle info.plist
 *
 * @param user The Backplane user to use
 *
 * @param backplaneUrl A root URL pointing to the location of the Backplane endpoints
 *
 * @param publicKey The Penthera-provided public key
 *
 * @param privateKey The Penthera-provided private key
 *
 * @return valid instance, nil on error
 *
 */
-(instancetype _Nullable)initWithUser:(NSString*)user
                         backplaneUrl:(NSString* _Nonnull)backplaneUrl
                            publicKey:(NSString* _Nonnull)publicKey
                           privateKey:(NSString* _Nonnull)privateKey;

/*!
 * @abstract Initialize the download engine.
 *
 * @discussion Parameter values for backplaneUrl, publicKey, and privateKey must be set in the Application Bundle info.plist
 *
 * @param user The Backplane user to use
 *
 * @param backplaneUrl A root URL pointing to the location of the Backplane endpoints
 *
 * @param publicKey The Penthera-provided public key
 *
 * @param privateKey The Penthera-provided private key
 *
 * @param externalDeviceID An optional externally-defined device UUID
 *
 * @return valid instance, nil on error
 *
 */
-(instancetype _Nullable)initWithUser:(NSString*)user
                         backplaneUrl:(NSString* _Nonnull)backplaneUrl
                            publicKey:(NSString* _Nonnull)publicKey
                           privateKey:(NSString* _Nonnull)privateKey
                     externalDeviceID:(NSString* _Nullable)externalDeviceID;

@end

NS_ASSUME_NONNULL_END
