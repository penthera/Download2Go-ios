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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VSETTINGS
#define VSETTINGS

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoConstants.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSettingsBase.h>
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
@interface VirtuosoSettings : VirtuosoSettingsBase

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
+ (nonnull VirtuosoSettings*)instance;


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
 *  @abstract The maximum number of downloads that can exist on the device at any given time
 *
 *  @discussion Virtuoso limits the total number of downloads the device can have on disk at any given time.
 *              Any download requests beyond this limit are queued, but will not download, and the engine
 *              will report an error indicating the download queue is blocked until the user manually
 *              deletes enough of the currently downloaded assets to get below the limit again.  The default
 *              value is 100.
 */
@property (nonatomic,readonly) long long maxDownloadedAssetsOnDevice;

/*!
 *  @abstract The maximum number of downloads that can exist across all devices on the account at any given time
 *
 *  @discussion Virtuoso limits the total number of downloads the user can have on disk across all their devices
 *              at any given time.  Any download requests beyond this limit are queued, but will not download, and
 *              the engine will report an error indicating the download queue is blocked until the user manually
 *              deletes enough of the currently downloaded assets, on this device or other devices, to get below
 *              the limit again.  The default value is -1 (unlimited).
 */
@property (nonatomic,readonly) long long maxDownloadedAssetsPerAccount;

/*!
 *  @abstract The maximum number of times any single asset can be downloaded
 *
 *  @discussion Virtuoso limits the total number of times an asset can be downloaded on any device in the account.
 *              Once this limit is reached, the asset can no longer be downloaded without administrative action.
 *              The default value is -1 (unlimited).
 */
@property (nonatomic,readonly) long long maxLifetimeDownloadsForAsset;

/*!
 *  @abstract The maximum number of copies of this asset that can be stored in all devices in the account
 *
 *  @discussion Virtuoso limits the total number of copies of an asset that can be downloaded on any device in the
 *              account.  Once this limit is reached, the asset can no longer be downloaded until the user deletes
 *              a copy of the asset from other devices in the account.  Any download requests beyond this limit are
 *              queued, but will not download, and the engine will report an error indicating the download queue is
 *              blocked until the user manually deletes copies of the asset on other devices to get below the limit
 *              again.  The default value is -1 (unlimited).
 */
@property (nonatomic,readonly) long long maxCopiesOfAssetPerAccount;

/*!
 *  @abstract Whether the engine should acquire download permissions when the asset is queued or when it starts downloading
 *
 *  @discussion Normally, the download engine acquires any necessary download permissions when the item starts downloading. By
 *              delaying the permission check until download can occur, the SDK can allow new assets to be queued while the
 *              device is offline.  If this setting is enabled, the download engine acquires permissions when the item is initially
 *              queued.  This means that assets can only be created and queued when the device is online.  If this setting is
 *              enabled and permissions are required (the maximum lifetime download limit or the maximum downloads per account features
 *              are configured), then attempts to create/queue the asset while offline will fail.  The default value is NO.
 */
@property (nonatomic, readonly) Boolean acquirePermissionWhenQueued;

/*!
 *  @abstract If YES, Virtuoso will always call the Backplane to request download permissions.  Defaults to NO.
 *
 *  @discussion Normally, the download engine will not request download permissions when the Backplane settings for maximum
 *              downloads per account and maximum lifetime download limit is set to unlimited, as there is no reason to attempt
 *              policy enforcement under these conditions.  If, however, your settings are currently unlimited, you anticipate
 *              that you might enforce limits later, and you wish to track downloads done while the policy was unrestricted, you may wish
 *              to set this value to YES.  If you have an external policy service (configured in Backplane settings) and have set
 *              both Backplane limits to unrestricted, you will also need to set this value to YES.
 */
@property (nonatomic, assign) Boolean alwaysRequestDownloadPermission;

/*!
 *  @abstract If YES, Virtuoso will enable IFRAME support in HLS.  Defaults to NO.
 *
 *  @discussion Normally, the download engine will not support IFRAME's for HLS. Enabling this will provide IFRAME support
 *              for HLS video content. This improves fast-forward and rewind experience during playback.
 */
@property (nonatomic, assign) Boolean iframeSupportEnabled;

/*!
 *  @abstract Minumum segments required for FastPlay
 *
 *  @discussion Default value is 5 segments, minimum value is 1.
 */
@property (nonatomic, assign) NSInteger fastPlayMinimumSegmentCount;

/*!
 *  @abstract If YES, Virtuoso will block duplicate asset creation. Defaults to YES.
 *
 *  @discussion Duplicate assets are assets with the same assetID property value. This check is performed
 *              when VirtuosoAssetConfig is created. If this value is YES, and an asset already exists with
 *              this assetID, VirtuosoAssetConfig initializer will return nil.
 */
@property (nonatomic, assign) Boolean blockDuplicateAssetCreation;

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

/*!
 *  @abstract If YES, Virtuoso will disable.  Defaults to NO.
 *
 *  @discussion Normally, the download engine will automatically renew DRM license in 48 hours,
 *              but user can disable this feature using this property
 */
@property (nonatomic, assign) Boolean disableAutoRenewDRMLicense;

/*!
 *  @abstract If YES, Virtuoso will require a successful DRM license request before allowing download.
 *
 *  @discussion Normally, during asset creation, Virtuoso attempts to perform all asset creation processes
 *              asynchronously in order to setup and start the asset download as fast as possible.  The normal
 *              flow is that the manifests will be parsed.  As soon as enough segments are identified from the
 *              manifests to begin download, download will begin while the rest of the manifest structure is parsed
 *              and created.  Any DRM license required is asynchronously requested during this process.  If the DRM
 *              license fails to load, the asset continues to download, and Virtuoso will re-attempt to retrieve the
 *              DRM license when the download completes.  Virtuoso will continue to attempt to aquire a DRM license
 *              at opportune times if the license request continues to fail.
 *
 *              If you would prefer that the asset not be parsed at all if the DRM request fails, you can enable this
 *              setting, which defaults to NO.  If set to YES, if the DRM request fails, then the new asset will *not*
 *              be parsed and, instead, will be created but flagged as 'too many errors'.  If this occurs,
 *              the parse complete callback will be fired, containing the asset and an error indicating that the DRM
 *              license failed.  It is expected that you will message the user appropriate and then delete the returned asset.
 *
 *  @warning    If you enable this setting, Virtuoso will take longer before reporting download start and progress, as normal
 *              parsing and download activities will be delayed until the DRM license can be confirmed.
 */
@property (nonatomic,assign) Boolean requireDRMLicensePriorToAssetParse;

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
 *              The Penthera SDK swizzles code into the AppDelegate chain to receive the push token and provide it to VirtuosoSettings.  Under normal conditions your app does not need to access or set the token here in VirtuosoSettings.  If your app disables our SDK swizzle but you still wish to use APNS with our SDK, your code will need to provide the push token to VirtuosoSettings as soon as your AppDelegate receives it.  If your app cannot access the push token (e.g. the user disabled push notifications for the device), then this value should be nil.
 */
@property (nonatomic,readonly,nullable) NSString* devicePushToken;

/*!
 *  @abstract Sets the device push token used for remote push notices
 *
 *  @discussion Virtuoso uses push notifications in various ways.
 *              The Penthera SDK swizzles code into the AppDelegate chain to receive the push token and provide it to VirtuosoSettings.  Under normal conditions your app does not need to access or set the token here in VirtuosoSettings.  If your app disables our SDK swizzle but you still wish to use APNS with our SDK, your code will need to provide the push token to VirtuosoSettings as soon as your AppDelegate receives it.  If your app cannot access the push token (e.g. the user disabled push notifications for the device), then this value should be nil.
 *
 *  @param pushToken The APNS push token.
 *
 */
- (void)setDevicePushToken:(NSData* _Nullable)pushToken;

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
 *              The default is LONG_LONG_MAX MB.
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
 *  @abstract How many assets the SDK will attempt to download after the app is suspended.
 *
 *  @discussion Under most conditions, it is desirable to download all assets in the queue when the
 *              application is suspended.  Under certain scenarios, it may be desirable to restrict
 *              the number of downloads the SDK will transfer to the iOS download system.  If this value
 *              is 0, then background downloading is disabled.  If this value is greater than 0, the SDK will
 *              only startup that many background downloads.  The default is INT_MAX.
 *
 *              Note that when the SDK transitions to background downloading, a notification is sent to the
 *              application which indicates the assets that were transferred to background download and the assets
 *              that were paused and which won't download until the app returns to the foreground.
 */
@property (nonatomic,assign) NSUInteger maximumAssetsForBackgroundDownload;

/*!
 *  @abstract When downloading without the packager, the number of direct-download segments to startup for
 *            background download at a time.  The default is 300.  Values less than 50 or greater than 500 are
 *            invalid.
 */
@property (nonatomic,assign) NSUInteger numberOfSegmentsPerDirectDownloadBatch;

/*!
 *  @abstract Whether or not the engine stops downloading if an error occurs while downloading individual segments.
 *
 *  @discussion If this value is zero, then any errors encountered while downloading segments will be treated
 *              as errors, and the documented download error handling rules will be followed.  The download
 *              of the individual segment will be retried three times before the SDK moves on to download other
 *              assets in the queue.  The asset will retry downloading 3 times before being marked with a
 *              permanent error.  If this value is greater than zero, then the SDK will permit a maximum 
 *              of this number of segment errors without counting them as an error against the asset. A 
 *              warning will be issued instead, and downloading will continue past the failed segment.  This setting
 *              only applies to segmented assets (E.G. HLS, HSS, etc).  The default value is 0.
 */
@property (nonatomic,assign) NSUInteger permittedSegmentDownloadErrors;

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
@property (nonatomic,assign,nullable) NSDictionary* additionalNetworkHeaders;

/*!
 *  @abstract An explicit device ID to use when authenticating and syncing with the Backplane.
 *
 *  @discussion By default, Virtuoso will use an internally generated UUID to authenticate
 *              with the Backplane.  To use a different device ID value, set it here.
 *
 *  @warning Since Virtuoso uses this value during startup, you must supply this value before
 *           calling any other Virtuoso methods.
 */
@property (nonatomic,strong,nullable) NSString* manualDeviceUDID;


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
 *              is 60 minutes.
 */
@property (nonatomic,assign) NSTimeInterval minimumBackplaneSyncInterval;

/*!
 *  @abstract The permitted MIME types for a particular asset and segment type
 *
 *  @discussion When an asset is downloaded, the server returns a MIME type for each invidually downloaded
 *              unit of data.  This could be the file itself (in the case of single-file downloads), the manifest
 *              file (in the case of streaming video types like HLS or HSS), or individual segment types (video,
 *              closed captioning files, or audio).  If the server returns a MIME type that is not contained
 *              in this list, then the download will be marked in error.  This behavior is useful for blocking
 *              invalid downloads that may occur when devices are on captive networks, as well as other networking-
 *              related issues.
 *
 *  @warning    An empty array means that all MIME types are valid.  This may be an issue on captive networks where
 *              the response returned from the server may not match the requested resource.
 *
 *  @param assetType The asset type to validate
 *  @param dataType The data type to validate
 *
 *  @return An array of strings representing MIME types Virtuoso will allow for download
 */
- (nonnull NSArray*)permittedMimeTypesForAssetType:(kVDE_AssetType)assetType
                                       andDataType:(kVF_DownloadDataType)dataType;

/*!
 *  @abstract Configures additional MIME types for asset manifest and segment file validation
 *
 *  @discussion Values provided via this method will be added to the internal default list of permitted MIME types.
 *              If you pass nil, then only the default list of permitted MIME types will be used.
 *
 *  @param additionalMimeTypes An array of string MIME type values add to the default list, or nil
 *  @param assetType The asset type to validate
 *  @param dataType The data type to validate
 */
- (void)allowAdditionalMimeTypes:(nonnull NSArray*)additionalMimeTypes
                    forAssetType:(kVDE_AssetType)assetType
                     andDataType:(kVF_DownloadDataType)dataType;

/*!
 *  @abstract Configures which audio languages will be downloaded from assets that contain multiple
 *            audio versions
 *
 *  @discussion Some asset types allow multiple versions of the audio track to be included in the asset.  It is
 *              usually desirable to provide every language available in the streaming asset, to provide customers
 *              a wide choice in language options.  It is not usually desirable to download every available language,
 *              however, as this increases the download size and bandwidth usage.  If you set this property to nil, 
 *              then the SDK will download every available audio language.  If you set this property to
 *              an empty array, then the SDK will not download any additional audio tracks that are not included
 *              in the main video file.  If you provide an array of language codes, then the SDK will only download
 *              audio tracks matching the indicated language.  The default value is nil.
 */
@property (nonatomic,strong,nullable) NSArray* audioLanguagesToDownload;

/*!
 *  @abstract Configures which audio codecs will be downloaded from assets that contain multiple
 *            audio codecs in the master manifest
 *
 *  @discussion Some asset types allow multiple versions of the audio track to be included in the asset.  A video may
 *              contain multiple audio languages as well as multiple audio codecs for extended device support.  While
 *              it is generally desirable to download many language options, it is only necessary to download the one
 *              audio codec that the device will use for playback.  Since "the best" codec may be different, depending
 *              on your particular requirements, the SDK allows you to configure exactly which codecs to download, if
 *              multiple codecs are present.  In order to download only the desired codecs, specify the specific audio
 *              codecs here (E.G. ec-3, ac-3, mp4a.40.2, etc).  If you set this property to nil or an empty array,
 *              then all available codecs will be downloaded.
 *
 *              When selecting which rendition to download, multiple factors are applied.  First, codec filters remove any
 *              renditions that do not match the global filter settings.  Second, resolution filters are applied so that only
 *              renditions with the requested resolution are considered.  Finally, the maximumBitrate selection is applied,
 *              to insure we only download a bitrate that most closely matches the target value.
 *
 *  @warning In order for this feature to be supported, your master manifests must properly specify the audio codecs
 *           in the CODECS field of the #EXT-X-STREAM-INF definitions.
 *
 *  @warning It is possibe to configure a download with values that are not natively supported on the Device. To protect
 *           against this, always test against the actual device.
 *
 */
@property (nonatomic,strong,nullable) NSArray* audioCodecsToDownload;

/*!
 *  @abstract Configures which subtitle languages will be downloaded from assets that contain subtitles
 *
 *  @discussion Some asset types allow subtitles to be included in the asset.  It is usually desirable to provide
 *              every language available in the streaming asset, to provide customers a wide choice in language options.
 *              It is not usually desirable to download every available language, however, as this increases the download
 *              size and bandwidth usage.  If you set this property to nil, then the SDK will download every available 
 *              subtitle track.  If you set this property to an empty array, then the SDK will not download any subtitles.
 *              If you provide an array of language codes, then the SDK will only download subtitles matching the indicated 
 *              language.  The default value is nil.
 */
@property (nonatomic,strong,nullable) NSArray* subtitleLanguagesToDownload;

/*!
 *  @abstract Configures the download engine to allow restricted MIME types
 *
 *  @discussion By default, the download engine explicitly disallows the MIME types text/html and text/xml
 *              for encryption keys.  This is because these MIME types are commonly used in responses for
 *              server errors and captive network pages, and the encryption keys should not use these types.
 *              The default value for this setting is NO.
 *             
 *  @warning If you enable this option, the download engine will not be able to differentiate between 
 *           downloaded encryption keys and other types of network content.  It is possible and, in fact, likely
 *           that your users will eventually attempt a download in these conditions and end up with unplayable
 *           content.
 *
 *  @param allow Whether to allow restricted MIME types for encryption key downloads
 */
- (void)allowRestrictedMimeTypesForEncryptionKeys:(Boolean)allow;

/*!
 *  @abstract Whether restricted MIME types are allowed for encryption keys
 */
- (Boolean)restrictedMimeTypesForEncryptionKeysAllowed;


/**---------------------------------------------------------------------------------------
 * @name HTTP Proxy Configuration
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark HTTP Proxy Configuration
#pragma mark

/*!
 *  @abstract Configures proxy playback behavior when errored segments are requested.
 *
 *  @discussion By default, the SDK stops download and marks the asset with errors if it
 *              cannot download an asset segment.  If you have configured 
 *              permittedSegmentDownloadErrors with a non-zero value, then the SDK will,
 *              instead, skip over a configured number of segment errors and continue downloading.
 *              These downloads will report errors, but will be marked as completed and
 *              can be played.  By default, the SDK HTTP Proxy will return HTTP 200 status
 *              for these files with zero length.  This allows most video players to continue
 *              playing over the error.  If desired, you can use this setting to configure
 *              the proxy to return 404 NOT FOUND instead.
 *
 *              Note that this behavior only applies for segments that are missing due to 
 *              errors.  If you play an asset that has not finished downloading, the proxy
 *              will always return 404 NOT FOUND for segments that have not downloaded yet.
 */
@property (nonatomic,assign) Boolean sendHTTPErrorForErroredSegments;


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
@property (nonatomic,strong,nullable) NSString* clientSSLCertificatePath;

/*!
 *  @abstract The password required to use the client SSL cert.  Can be nil.
 */
@property (nonatomic,strong,nullable) NSString* clientSSLCertificatePassword;

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
@property (nonatomic,strong,nullable) NSString* drmUserName;

/*!
 *  @abstract The password to use with the DRM system.
 *
 *  @discussion Depending on the DRM system being used, this property may be ignored.  You only need to set
 *              this value if you know your DRM system requires it.
 */
@property (nonatomic,strong,nullable) NSString* drmPassword;

/**---------------------------------------------------------------------------------------
  * @name MediaMelon Settings
  *  ---------------------------------------------------------------------------------------
  */

 #pragma mark
 #pragma mark MediaMelon Settings
 #pragma mark

 /*!
  *  @abstract MediaMelon Service URL
  *
  *  @discussion For asset downloads that make use of MediaMelon, this property provides the MediaMelon ServiceURL
  */
 @property (nonatomic,copy,nullable) NSString* mediaMelonServiceURL;

 /*!
  *  @abstract MediaMelon Customer ID
  *
  *  @discussion For asset downloads that make use of MediaMelon, this property provides the default CustomerID
  */
 @property (nonatomic,copy,nullable) NSString* mediaMelonCustomerID;

@end

#endif
