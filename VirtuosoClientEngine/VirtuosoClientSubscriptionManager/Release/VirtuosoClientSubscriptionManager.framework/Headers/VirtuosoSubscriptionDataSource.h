/*!
 *  @header Virtuoso Subscription Data Source
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

/*!
 *  @typedef SubscriptionServerRemoteUUIDKey
 *
 *  @abstract The Backplane provides data to the data source via data in an NSDictionary.  At a minimum, the data will include a
 *            remote asset UUID representing the feed on the Backplane and an array of dictionaries, representing individual video items,
 *            at the following keys.  Each individual item dictionary will contain, at a minimum, a remote asset UUID representing the
 *            feed item.  Additional information *may* be available if it was provided to the server by the external catalog.
 */

extern NSString* _Nonnull const SubscriptionServerRemoteUUIDKey;
extern NSString* _Nonnull const SubscriptionServerCollectionUUIDKey;
extern NSString* _Nonnull const SubscriptionServerAssetsKey;

/*!
 *  @typedef kVSM_MediaTypeCode
 *
 *  @abstract A defined list of media types that the Manager is aware of and will auto-start downloads for.  The data source *must* include
 *            a media type value in the parsed data response for automatic downloads to be handled.  Any returned item that does not have one
 *            of these values will be ignored.
 */
typedef NS_ENUM(NSInteger, kVSM_MediaTypeCode)
{
    /** Value used for range checking.  Should not be used by Caller. */
    kVSM_MediaTypeCodeFirst       = 0,
    
    kVSM_MediaTypeCodeFile        = 0,
    kVSM_MediaTypeCodeAudio       = 1,
    kVSM_MediaTypeCodeVideo       = 2,
    kVSM_MediaTypeCodeHLS         = 3,
    kVSM_MediaTypeCodeHSS         = 5,
    
    /** Value used for range checking.  Should not be used by Caller. */
    kVSM_MediaTypeCodeLast        = 5,
};


/*!
 *  @abstract The following keys are used to reference video item data within a metadata lookup request.
 *
 *  @constant Created Date           (Required - NSDate)       A timestamp representing the time the asset was created in the external catalog
 *  @constant Asset ID               (Required - NSString)     An asset ID that uniquely identifies the asset within the external catalog
 *  @constant Media Type             (Required - NSNumber)     One of the kVSM_MediaTypeCode enumeration values, indicating what type of file is being processed
 *  @constant Collection Asset ID    (Optional - NSString)     If the asset belongs to a collection, then this is the asset ID that uniquely identifies the collection in
 *                                                             the external catalog.
 *  @constant Title                  (Optional - NSString)     A human-readable title used for logging and identification.
 *  @constant Description            (Optional - NSString)     A human-readable description used for logging and identification, usually the asset's title, but
 *                                                             may be a longer extended format containing the asset's detailed description.
 *  @constant Download URL           (Required - NSString)     The URL of the asset in the remote CDN.  May be a direct file link or an HLS manifest.
 *  @constant Maximum Bitrate        (Optional - NSNumber)     Only utilized for HLS.  If not provided, defaults to the highest bitrate available.
 *  @constant Publish Date           (Optional - NSDate)       The date/time before which this asset should not be available.  If not provided, defaults to now.
 *  @constant Expiry Date            (Optional - NSDate)       The date/time after which this asset should not be available.  If not provided, defaults to never.
 *  @constant Expiry After Download  (Optional - NSNumber)     The amount of time after download that the asset should be available, in seconds. If not provided,
 *                                                             falls back to Backplane defaults.
 *  @constant Expiry After Play      (Optional - NSNumber)     The amount of time after initial playback that the asset should be available, in seconds. If not
 *                                                             provided, falls back to Backplane defaults.
 *  @constant Permitted Mime Types   (Optional - NSArray)      A list of NSString values representing valid MIME types for this download.  If provided, only MIME types in
 *                                                             this list will result in completed downloads.  Other types will result in a download error.
 *  @constant User Info              (Optional - NSDictionary) A PList compatible dictionary of arbitrary key-value pairs which may be used by the Caller for use
 *                                                             within the application.
 *  @constant Require Ads            (Optional - NSNumber)     Whether or not this asset requires ads.  This value is evaluated as a Boolean
 */

extern NSString* _Nonnull const SubscriptionAssetDataCreatedDateKey;
extern NSString* _Nonnull const SubscriptionAssetDataCollectionAssetIDKey;
extern NSString* _Nonnull const SubscriptionAssetDataAssetIDKey;
extern NSString* _Nonnull const SubscriptionAssetDataMediaTypeKey;
extern NSString* _Nonnull const SubscriptionAssetDataTitleKey;
extern NSString* _Nonnull const SubscriptionAssetDataDescriptionKey;
extern NSString* _Nonnull const SubscriptionAssetDataDownloadURLKey;
extern NSString* _Nonnull const SubscriptionAssetDataMaximumBitrateKey;
extern NSString* _Nonnull const SubscriptionAssetDataPublishDateKey;
extern NSString* _Nonnull const SubscriptionAssetDataExpiryDateKey;
extern NSString* _Nonnull const SubscriptionAssetDataExpiryAfterDownloadKey;
extern NSString* _Nonnull const SubscriptionAssetDataExpiryAfterPlayKey;
extern NSString* _Nonnull const SubscriptionAssetDataPermittedMimeTypesKey;
extern NSString* _Nonnull const SubscriptionAssetDataUserInfoKey;
extern NSString* _Nonnull const SubscriptionAssetDataRequireAds;



/*!
 *  @abstract Provides a configurable and dynamic mechanism for retrieving required data about subscription content.
 *
 *  @discussion When new subscription episodes are announced, the Backplane may only send an episode asset ID, or it may send complete asset metadata.
 *              The VirtuosoSubscriptionDataSource protocol allows the Subscription Manager to retrieve any missing episode metadata prior to automatically
 *              downloading new asset and it allows the Caller to customize the created Virtuoso SDK objects before they are enqueued with the download Engine.
 *
 *              When the Manager needs to start new downloads, it will create a new VirtuosoSubscriptionDataSource object using the class name registered with it
 *              and initialize the new data source with any data provided by the Backplane.  The data source object must then retrieve __at least__ the required metadata
 *              necessary to start the download in the Virtuoso Download Engine (see the dictionary keys identified in this class for descriptions of optional and 
 *              required fields).  It may also retrieve any of the optional metadata listed in the protocol, in addition to any arbitrary values provided by the external
 *              catalog.
 *
 *              The Virtuoso SDK provides one built-in data source, the VirtuosoSubscriptionDefaultDataSource.  This data source is the default data source and will 
 *              always be used if no other data source class is registered.  Additional external data sources may be registered with the Manager.  In addition, 
 *              Penthera can support development of custom data sources as-needed.  Contact Penthera Support for further details.
 *
 *  @see VirtuosoSubscriptionDefaultDataSource
 */

@protocol VirtuosoSubscriptionDataSource <NSObject>

/*!
 *  @abstract Initializes a data source with subscriptions that require data lookups
 *
 *  @discussion This method receives an NSArray of subscriptions that the Manager requires detailed metadata for.  The NSArray *will* contain a list of
 *              NSDictionary objects.  At minimum, the dictionaries will contain a single NSString value
 *
 *  @param subscriptions A list of subscription data
 *
 *  @return Returns an initialized unstarted data source
 */
- (nonnull id)initWithSubscriptions:(nonnull NSArray*)subscriptions;

/*!
 *  @abstract Initializes a data source with individual assets that require data lookups
 *
 *  @discussion This method receives an NSArray of assets that the Manager requires detailed metadata for.  The NSArray *will* contain a list of 
 *              NSDictionary objects.  At a minimum, the dictionaries will contain a single NSString value
 *
 *  @param assets A list of asset data
 *
 *  @return Returns an initialized unstarted data source
 */
- (nonnull id)initWithAssets:(nonnull NSArray*)assets;

/*!
 *  @abstract Processes a data lookup operation using the initalized subscription data
 *
 *  @discussion This call *must* synchronously execute using the data provided during the init call.  The Manager will handle all threading requirements.
 *              If an error occurs, the data source must return a nil value.  If the lookup completed successfully, but no data was available, the data 
 *              source should return an empty container object.  The data source may also lookup additional data that may be needed by the Application in order
 *              to display the user interface or perform other Application-specific tasks.  That data does not need to be returned.  Since internal Manager rules
 *              may cause items to be downloaded or deleted, Callers should not rely on this method or data source processing to determine when items
 *              have been added or removed from the Download Queue or when they have been deleted.  The Caller should, rather, use the appropriate Manager notifications.
 *
 *  @warning The Caller must not make any assumptions about which thread or operation queue this method will be executed on.  If thread-dependent calls must be made,
 *           to notify other code to update CoreData objects for instance, then the Caller must explicitly execute that code on the desired operation queue.
 *
 *  @return If the data source was initialized with subscriptions, via the initWithSubscriptions method, then a NSDictionary where the keys are subscription IDs and
 *          the values are NSArrays containing NSDictionaries representing asset data, with key-value data as defined in SubscriptionAssetDataAttributes.  If the 
 *          data source was initialized with assets, via the initWithAssets method, then a single NSArray is returned directly, without the top NSDictionary package.
 */
- (nonnull NSObject*)process;

@end
