/*!
 *  @header Virtuoso Subscription Default Data Source
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
 *  @copyright (c) 2013 Penthera Inc. All Rights Reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "VirtuosoSubscriptionDataSource.h"

@class VirtuosoAsset;

/*!
 *  @abstract The default data source for the VirtuosoSubscriptionManager.
 *
 *  @discussion This class provides a default implementation of a VirtuosoSubscriptionDataSource and is provided as a base class for implementations to utilize the
 *              VirtuosoSubscriptionManager with a custom back-end catalog.  If the external catalog provides all required metadata items to the Backplane
 *              during asset reporting, then this default implementation is sufficient to allow automated subscription handling and download management.  
 *
 *              Subclassing Notes: The default implementation of this class receives data from the Backplane and automatically processes any subscription
 *                                 items that have enough metadata provided to proceed immediately.  The default implementation of all methods defined below
 *                                 do nothing, and any items that cannot be automatically processed will be ignored.  Callers using an external catalog may 
 *                                 need to create a custom subclass of VirtuosoSubscriptionDefaultDataSource and define custom implementations of one or both 
 *                                 methods.  If the Caller chooses to develop an entirely custom VirtuosoSubscriptionDataSource instead of starting with this 
 *                                 base class, then they must insure all aspects of the protocol are followed.
 *
 *  @warning The Caller should NEVER instantiate an object of this type directly.  The Caller should configure the VirtuosoSubscriptionManager with the desired
 *           data source by calling the VirtuosoSubscriptionManager registerDataSource: method with the Class you wish to use.  The VirtuosoSubscriptionManager
 *           instance will create appropriate instances of the data source class as needed during syncs and while processing remote push notices.
 */
@interface VirtuosoSubscriptionDefaultDataSource : NSObject<VirtuosoSubscriptionDataSource>

/*!
 *  @abstract Requests a synchronous metadata lookup for a known asset ID
 *
 *  @discussion This method is called during subscription processing, and may be used to provide additional metadata prior to the asset being enqueued by the download
 *              engine.  Subclasses must implement this method to provide metadata to the Manager when required metadata may be missing from the Backplane sync information.
 *              The Caller is expected to do a synchronous lookup of the detailed data, based on the Caller-defined external asset ID, and return a NSDictionary object
 *              containing all required metadata items from the VirtuosoSubscriptionDataSource protocol, at a minimum.  Any additional metadata may also be provided
 *              and will be utilized by the Download Engine to control subscription and download business rules.  If sufficient metadata is not returned by this method,
 *              then the item will be ignored.  The default implementation of this method returns the knownData values.
 *
 *  @param assetID    The asset ID representing an asset to lookup
 *  @param knownData  The known metadata received by the backplane for this asset.  May be used as a reference
 *                    to provide additional missing data.
 *
 *  @return A NSDictionary object containing all required keys, as defined in the data source protocol
 */
- (nonnull NSDictionary*)lookupMetadataForAssetID:(nonnull NSString*)assetID usingKnownData:(nonnull NSDictionary*)knownData;

/*!
 *  @abstract Indicates that an asset was succesfully processed
 *
 *  @discussion Any time the data source successfully parses metadata for an asset, this method will be called.  Since internal subscription and download logic
 *              may define which items result in new VirtuosoAsset items and downloads, the Caller may wish to use this method to receive and process data from the
 *              sync that did not result in new downloads.
 *
 *  @param metadata A NSDictionary object containing, at a minimum, metadata values for the keys defined in the data source protocol.  Any additional data provided by
 *                  the Backplane or the External Catalog during a metadata lookup may also be defined, and Callers can access custom catalog data in this manner.
 */
- (void)didProcessAssetWithMetadata:(nonnull NSDictionary*)metadata;

/*!
 *  @abstract Indicates a new VirtuosoAsset item has been created
 *
 *  @discussion This method will be called as soon as new VirtuosoAsset items have been created, prior to being added to the queue or deferred.  The data source
 *              may further modify the VirtuosoAsset object via this method, such as adding file-unique headers or other file-unique options/metadata.  It is expected
 *              that the implementation of this method will call the VirtuosoAsset save method prior to returning and that any changes made within this method will be
 *              done synchronously.
 *
 *  @param asset A VirtuosoAsset item that has just been created by the Subscription Manager
 */
- (void)willAddAsset:(nonnull VirtuosoAsset*)asset;

@end
