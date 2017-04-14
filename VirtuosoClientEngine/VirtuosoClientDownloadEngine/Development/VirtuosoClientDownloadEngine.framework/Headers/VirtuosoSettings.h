/*!
 *  @header Virtuoso Settings
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
 *  @copyright (c) 2016 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VSETTINGS
#define VSETTINGS

#import <Foundation/Foundation.h>

/*!
 *  @abstract An encapsulation for all Virtuoso SDK configuration settings.
 *
 *  @discussion A singleton object that manages all SDK configuration settings.  Receives default settings
 *              and business rules from the Backplane.
 *
 *  @warning You must never instantiate an object of this type directly.
 *            The VirtuosoSettings is a singleton and should only be accessed via the
 *           provided instance method.
 */
@interface VirtuosoSettings : NSObject

/**---------------------------------------------------------------------------------------
 * @name Utility
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Utility
#pragma mark

/*!
 *  @abstract The singleton instance access method
 *
 *  @discussion You must never instantiate a local copy of the VirtuosoSettings object.  This object
 *              is intended to be a static singleton accessed through the instance method only.  Instantiating a local
 *              copy will throw an exception.
 *
 *  @return Returns the VirtuosoSettings object instance.
 */
+ (VirtuosoSettings*)instance;


/**---------------------------------------------------------------------------------------
 * @name Backplane-Provided Configuration
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Backplane-Provided Configuration
#pragma mark

/*!
 *  @abstract Once the time since last Backplane sync exceeds this value, Virtuoso makes the downloaded assets inaccessible
 *
 *  @discussion Virtuoso enforces that clients must sync with the Backplane at a required interval,
 *              or else lose access to downloaded assets.
 *              Virtuoso marks the time since the sync with the Backplane, and makes all downloaded
 *              assets inaccessible if the time exceeds this value.
 *              After this timeout, any attempts to playback any assets via the file proxy will fail.
 *              Any calls to VirtuosoAsset methods that would retrieve file paths
 *              for downloaded assets will return nil.
 *              Note that Virtuoso doesn’t delete all downloaded assets; it just makes the assets
 *              inaccessible. Once the next Backplane sync occurs, the assets are again accessible.
 */
@property (nonatomic,readonly) long long defaultOfflineViewingPeriod;

/*!
 *  @abstract The total number of unique enabled devices for the current user
 */
@property (nonatomic,readonly) long long numberOfDevicesEnabled;

/*!
 *  @abstract The maximum number of devices per user that the Backplane allows to be enabled for download
 */
@property (nonatomic,readonly) long long maxDevicesForDownload;

/*!
 *  @abstract Amount of time, in seconds, between when Virtuoso finishes downloading an asset
 *            and when it deletes that downloaded asset.
 *
 *  @discussion As soon as Virtuoso finishes downloading an asset, it marks the asset with a timestamp.
 *              As soon as possible after 'defaultExpiryAfterDownload' has elapsed, Virtuoso will
 *              automatically delete the downloaded asset.
 *              Values less than or equal to zero mean no expiry.
 */
@property (nonatomic,readonly) long long defaultExpiryAfterDownload;

/*!
 *  @abstract Default amount of time after the first playback of a downloaded asset before Virtuoso deletes it
 *
 *  @discussion At the first known 'play' event for this asset, Virtuoso marks the item with a timestamp.
 *              As soon as possible after 'defaultExpiryAfterPlay' time has elapsed, Virtuoso
 *              will automatically delete the downloaded asset.
 *              A values zero or less means "never expire."
 */
@property (nonatomic,readonly) long long defaultExpiryAfterPlay;

/**---------------------------------------------------------------------------------------
 * @name Push Notice Configuration
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Push Notice
#pragma mark

/*!
 *  @abstract The device push token used for remote push notices
 *
 *  @discussion Virtuoso uses push notifications in various ways.
 *              For push notifications to work, you must set this value as soon as you get the
 *              app's push token from the OS. If you cannot access the push token (e.g. the user disabled
 *              push notifications for the device), then set this value to nil.
 */
@property (nonatomic,strong) NSString* devicePushToken;

/**---------------------------------------------------------------------------------------
 * @name Policy/Configuration
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Policy/Configuration
#pragma mark

/*!
 *  @abstract Returns the headroom configuration value.
 *
 *  @discussion Headroom is the amount of free space that Virtuoso must preserve on disk.
 *              For instance, if headroom is 1GB and the device has 1.2GB free disk space, Virtuoso will
 *              begin to download a 150MB asset, but it will NOT begin to download a 500MB asset. The default
 *              is 1 GB.
 *
 *  @return The headroom setting (in MB).
 *
 *  @see overrideHeadroom:
 *  @see resetHeadroomToDefault
 */
@property (nonatomic,readonly) long long headroom;

/*!
 *  @abstract Allows you to override the default value for the headroom setting.
 *
 *  @param newHeadroom The new headroom setting Virtuoso should use (in MB)
 *
 *  @see headroom
 *  @see resetHeadroomToDefault
 */
- (void)overrideHeadroom:(long long)newHeadroom;

/*!
 *  @abstract Resets Virtuoso's headroom setting to the default (1 GB)
 *
 *  @see headroom
 *  @see overrideHeadroom:
 */
- (void)resetHeadroomToDefault;

/*!
 *  @abstract Returns the max storage configuration value, in MB.
 *
 *  @discussion Max storage is the total amount of space that Virtuoso can use on disk for downloads.
 *              For instance, if maxStorage is 10GB and Virtuoso is now storing 9.5GB,
 *              Virtuoso will begin to download a 400MB asset, but will NOT begin to download an 800MB asset.
 *              The default is 5 GB.
 *
 *  @see overrideMaxStorageAllowed:
 *  @see resetMaxStorageAllowedToDefault
 */
@property (nonatomic,readonly) long long maxStorageAllowed;

/*!
 *  @abstract Allows you to override the default value for max storage.
 *
 *  @param maxStorageAllowed The new max storage value (in MB).
 *
 *  @see maxStorageAllowed
 *  @see resetMaxStorageAllowedToDefault
 */
- (void)overrideMaxStorageAllowed:(long long)maxStorageAllowed;

/*!
 *  @abstract Resets Virtuoso's maximum storage to the default (5 GB)
 *
 *  @see maxStorageAllowed
 *  @see overrideMaxStorageAllowed:
 */
- (void)resetMaxStorageAllowedToDefault;

/*!
 *  @abstract The maximum number of downloads that can exist on the device at any given time.
 *
 *  @discussion Virtuoso limits the total number of downloads the device can have on disk at any given time.
 *              Any download requests beyond this limit are queued, but will not download, and the engine
 *              will report an error indicating the download queue is blocked until the user manually
 *              deletes enough of the currently downloaded assets to get below the limit again.  The default
 *              value is 100.
 */
@property (nonatomic,readonly) long long maxDownloadedAssets;

/*!
 *  @abstract Returns the cellular download permission value.
 *
 *  @discussion The 'downloadOverCellular' value is a permission.
 *              If YES, Virtuoso may elect to use cellular to download under certain conditions.
 *              A NO value guarantees Virtuoso will never download over cellular. The default
 *              values is NO.
 *
 *  @see overrideDownloadOverCellular:
 *  @see resetDownloadOverCellularToDefault
 */
@property (nonatomic,readonly) Boolean downloadOverCellular;

/*!
 *  @abstract Allows you to override Virtuoso's default value for the cellular download permission setting.
 *
 *  @param downloadOverCellular The new cellular download setting
 *
 *  @see downloadOverCellular
 *  @see resetDownloadOverCellularToDefault
 */
- (void)overrideDownloadOverCellular:(Boolean)downloadOverCellular;

/*!
 *  @abstract Reset Virtuoso's cellular download setting to the default (false)
 *
 *  @see downloadOverCellular
 *  @see overrideDownloadOverCellular:
 */
- (void)resetDownloadOverCellularToDefault;


/**---------------------------------------------------------------------------------------
 * @name Advanced Policy/Configuration - stuff you probably should leave alone
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Advanced Policy/Configuration
#pragma mark

/*!
 *  @abstract The network connection timeout for Virtuoso HTTP requests, in seconds.  Default is 60.0s.
 */
@property (nonatomic,assign) NSTimeInterval networkTimeout;

/*!
 *  @abstract A dictionary of additional HTTP headers that Virtuoso will send (along with the
 *           default set of HTTP headers) in every HTTP request. Takes precedence over the default
 *           HTTP headers.  These headers may also be overridden by additionalNetworkHeaders
 *           specified on the VirtuosoAsset individually.
 *
 *            Example:
 *              engine.additionalNetworkHeaders = @{"AccessKey":"<UUID>"};
 */
@property (nonatomic,assign) NSDictionary* additionalNetworkHeaders;

/*!
 *  @abstract Enables Penthera's StreamPackager service for background download of segmented VirtuosoAssets (HLS, HSS, DASH, etc).
 *
 *  @discussion Penthera's StreamPackager (a server proxy) allows Virtuoso to more efficiently download 
 *              segmented VirtuosoAsset formats even when the enclosing app isn't in the foreground.  
 *              To disable this feature (and continue with slower background downloads), set this property to NO.
 *              Default is YES.
 *
 *  @warning Since Virtuoso uses this value during startup, you must supply this value before
 *           calling any other Virtuoso methods. Changes to this value won't take effect
 *           until the next time you call startup.
 */
@property (nonatomic,assign) Boolean useStreamPackagerForBackgroundDownloads;


/*!
 *  @abstract An explicit device ID to use when authenticating and syncing with the Backplane.
 *
 *  @discussion By default, Virtuoso will use an internally generated UUID to authenticate
 *              with the Backplane.  To use a different device ID value, set it here.
 *
 *  @warning Since Virtuoso uses this value during startup, you must supply this value before
 *           calling any other Virtuoso methods.
 */
@property (nonatomic,strong) NSString* manualDeviceUDID;


/*!
 *  @abstract Whether Virtuoso should set the app's network activity indicator
 *
 *  @discussion If YES, then Virtuoso will set the enclosing app's network activity indicator when downloading.
 *              Set this to NO if you don't want the Virtuoso's downloading to trigger the app's
 *              network activity indicator.  Default is YES.
 */
@property (nonatomic,assign) Boolean engineSetsNetworkActivityIndicator;


/*!
 *  @abstract The minimum amount of time between Backplane syncs
 *
 *  @discussion No matter how many times the Backplane sync method is called, or how often internal events might
 *              attempt a sync, the SDK will generally sync with the backplane more often than this value.  Certain time-critical
 *              events, such as a SDK push notice, may cause the SDK to sync regardless of the last sync.  The default
 *              is 15 minutes.
 */
@property (nonatomic,assign) NSTimeInterval minimumBackplaneSyncInterval;


/**---------------------------------------------------------------------------------------
 * @name SSL Configuration
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark SSL Configuration
#pragma mark

/*!
 *  @abstract The path to the client SSL cert to use for all SSL auth challenges.  Can be nil.
 */
@property (nonatomic,strong) NSString* clientSSLCertificatePath;

/*!
 *  @abstract The password required to use the client SSL cert.  Can be nil.
 */
@property (nonatomic,strong) NSString* clientSSLCertificatePassword;

/*!
 *  @abstract Whether Virtuoso will trust self-signed SSL certs
 *
 *  @discussion Setting to YES causes Virtuoso to trust all self-signed server certs.
 *              Don't do this in a production build - it's only meant for testing! Default is NO.
 */
@property (nonatomic,assign) Boolean trustSelfSignedServerCertificates;

/**---------------------------------------------------------------------------------------
 * @name DRM Settings
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Drm Settings
#pragma mark

/*!
 *  @abstract The user name to use with the DRM system.
 *
 *  @discussion Depending on the DRM system being used, this property may be ignored.  You only need to set
 *              this value if you know your DRM system requires it.
 */
@property (nonatomic,strong) NSString* drmUserName;

/*!
 *  @abstract The password to use with the DRM system.
 *
 *  @discussion Depending on the DRM system being used, this property may be ignored.  You only need to set
 *              this value if you know your DRM system requires it.
 */
@property (nonatomic,strong) NSString* drmPassword;

@end

#endif
