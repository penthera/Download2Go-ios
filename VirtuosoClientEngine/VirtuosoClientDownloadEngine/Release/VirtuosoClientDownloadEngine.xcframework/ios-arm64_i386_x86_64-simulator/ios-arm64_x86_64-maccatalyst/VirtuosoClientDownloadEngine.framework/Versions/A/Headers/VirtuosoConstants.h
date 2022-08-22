/*!
 *  @header Virtuoso Constants
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

#ifndef VirtuosoClientDownloadEngine_VirtuosoConstants_h
#define VirtuosoClientDownloadEngine_VirtuosoConstants_h

#import <Foundation/Foundation.h>

@class VirtuosoAsset;

/**---------------------------------------------------------------------------------------
 * @name Download engine Data Types
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Virtuoso Download Engine Data Types
#pragma mark

/*!
 *
 *  @typedef kVDE_NetworkStatus
 *
 *  @abstract Engine-local versions of Reachability status.
 */
typedef NS_ENUM(NSInteger, kVDE_NetworkStatus)
{
    /** The network is not currently reachable */
    kVDE_NotReachable     = 0,
    
    /** The network is currently reachable via WiFi */
    kVDE_ReachableViaWiFi = 2,
    
    /** The network is currently reachable via cellular */
    kVDE_ReachableViaWWAN = 1
};

/*!
 *  @typedef kVDE_DownloadEngineStatus
 *
 *  @abstract Current activity status of Virtuoso's download engine.
 */
typedef NS_ENUM(NSInteger, kVDE_DownloadEngineStatus)
{
    /** Virtuoso hasn't finished starting up; status isn't determined */
    kVDE_Unknown = -1,
    
    /** Virtuoso is actively downloading */
    kVDE_Downloading = 0,
    
    /** Downloading is enabled, but queue is empty */
    kVDE_Idle = 1,
    
    /** You have disabled downloading, or the backplane has disabled download for this device */
    kVDE_Disabled = 2,
    
    /** Downloading is enabled and the queue is non-empty, but environmental conditions 
        (power/network/disk) prevent download. */
    kVDE_Blocked = 3,
    
    /** Errors occurred while downloading. There are pending downloads, but Virtuoso cannot 
        proceed without manual intervention (e.g. calling reset). */
    kVDE_Errors = 4,
    
    /** SDK licensing failed.  Please contact Penthera support in this case. */
    kVDE_AuthenticationFailure = 5
};

/*!
 *  @typedef kVBP_StatusCode
 *
 *  @abstract An asynchronous status returned from various methods that access the Backplane. Typically, these are provided
 *            as the "code" property on an NSError value passed with an NSNotification or callback block.  You may also need to
 *            consult the notice and error description for details of the problem.
 */
typedef NS_ENUM(NSInteger, kVBP_StatusCode)
{
    /** Successful Backplane response */
    kVBP_Success = 0,
    
    /** Backplane encountered an internal error */
    kVBP_InternalError = -1,

    /** The client's request to Backplane was formatted incorrectly */
    kVBP_InvalidRequest = -2,

    /** The supplied credentials are invalid on the Backplane */
    kVBP_InvalidCredentials = -3,

    /** The device is already linked with a different User account on the Backplane */
    kVBP_DeviceAlreadyExists = -4,

    /** The client attempted to use the Backplane without first registering the device */
    kVBP_UnregisteredDevice = -5,

    /** The Backplane reported this User has reached the max enabled device limit */
    kVBP_DeviceLimitReached = -6,

    /** The request object to save device settings is missing some required fields */
    kVBP_InvalidDeviceSettings = -7,

    /** The client submitted an unsupported log event to the Backplane */
    kVBP_NoSuchEvent = -8,

    /** The client submitted an event with invalid format to the Backplane */
    kVBP_InvalidEventSyntax = -9,

    /** The Backplane cannot be contacted because the device is currently offline */
    kVBP_NoConnection = -10,

    /** The current sync did not get processed because another sync is already in process */
    kVBP_SyncDeferred = -11,

    /** The current sync did not get processed because a sync with the Backplane has already occurred recently */
    kVBP_SyncThrottled = -12,

    /** The Backplane reported denied due to device enablement limit reached */
    kVBP_DeviceEnablementLimitReached = -14,

    /** Permission to download an asset was denied due to maximum download per account rules */
    kVBP_DownloadDeniedForMaxDownloadsPerAccount = -61,

    /** Permission to download an asset was denied due to maximum lifetime downloads for asset rules */
    kVBP_DownloadDeniedForMaxLifetimeDownloadsPerAsset = -62,

    /** Permission to download an asset was denied due to external policy restrictions */
    kVBP_DownloadDeniedForExternalPolicy = -63,

    /** Permission to download an asset was denied due to maximum copies of asset per account rules */
    kVBP_DownloadDeniedForMaxCopiesOfAssetPerAccount = -64,
    
};

/*!
 *  @typedef kVDE_ErrorCode
 *
 *  @abstract Errors or warnings encountered by Virtuoso. Included in the NSError object sent
 *            via NSNotificationCenter when issues are reported.
 */
typedef NS_ENUM(NSInteger, kVDE_ErrorCode)
{
    /** The supplied Backplane URL contains an invalid format */
    kVDE_BackplaneURLError = -10,
    
    /** Virtuoso was unable to reach the Backplane */
    kVDE_BackplaneNotReachableError = -11,
    
    /** Virtuoso was unable to move the downloaded asset to the final destination */
    kVDE_FileMoveToFinalPathError = -12,
    
    /** The observed final file size doesn't match the expected file size */
    kVDE_UnexpectedFileSizeWarning = -13,
    
    /** The userInfo dictionary contains objects that cannot be serialized */
    kVDE_UnserializableUserInfoError = -14,
};


/*!
 *  @typedef kVDE_EngineStartupCode
 *
 *  @abstract Returned by the various startup methods to indicate whether Virtuoso successfully started up.
 */
typedef NS_ENUM(NSInteger, kVDE_EngineStartupCode)
{
    /** Virtuoso successfully started up */
    kVDE_EngineStartupSuccess = 0,
    
    /** Virtuoso was already started; no action occurred */
    kVDE_EngineStartupAlreadyStarted = -1,

    /** Virtuoso started up, but couldn't reach the  Backplane */
    kVDE_EngineStartupSuccessNoBackplane = -2,

    /** Virtuoso can't start up with the parameters provided */
    kVDE_EngineStartupInvalidOptions = -4,
    
    /** Virtuoso can't change user account when invoked on MainThread */
    kVDE_EngineStartupMethodIsDeprecated = -5,

    /** Virtuoso encountered an internal exception during startup */
    kVDE_EngineStartupInternalException = -6,
    
    /** Virtuoso encountered an error initializing the CoreData database during startup */
    kVDE_EngineDataMigrationError = -7,
    

};


/*!
 *  @typedef kVDE_DownloadErrorCode
 *
 *  @abstract Virtuoso issues these codes via NSNotificationCenter when there's a problem downloading an asset.
 *            Virtuoso also marks the individual asset with an error code.
 */
typedef NS_ENUM(NSInteger, kVDE_DownloadErrorCode)
{
    /** The file length advertised by the HTTP server doesn't match the expected size.
        If file size validation is off, then the download proceeds anyway. If it's on,
        Virtuoso aborts the download and sets the appropriate error codes. */
    kVDE_ServerFileSizeDisagreesWithExpectedFileSize = -1,

    /** If the MIME type returned from the HTTP server doesn't match the required MIME types
        whitelist you provided earlier, then Virtuoso aborts the download. */
    kVDE_InvalidMimeType = -4,

    /** Some network issue (HTTP 404,416,etc) caused the download to fail. */
    kVDE_NetworkError = -5,

    /** The asset was configured with an invalid protection type. */
    kVDE_InvalidProtectionType = -8,

    /** There was an internal error.  Please contact Penthera support. */
    kVDE_InternalError = -9,

    /** Virtuoso was unable to obtain permission to download the asset because the lifetime download limit for this asset was reached. */
    kVDE_PermissionsErrorLifetimeDownloadLimit = -10,

    /** Virtuoso was unable to obtain permission to download the asset because the account has reached its maximum download limit. */
    kVDE_PermissionsErrorMaximumDownloadsPerAccount = -11,

    /** Virtuoso was unable to obtain permission to download the asset because the external policy service denied permission. */
    kVDE_PermissionsErrorExternalPolicyServiceDenied = -12,

    /** Virtuoso was unable to create the VirtuosoAsset due to configuration restrictions. */
    kVDE_InvalidConfigurationOptions = -13,

    /** Virtuoso was unable to obtain permission to download the asset because too many copies of this asset are already in the account. */
    kVDE_PermissionsErrorMaximumCopiesPerAccount = -14,

    /** Virtuoso was unable to create the VirtuosoAsset due to invalid manifest. */
    kVDE_InvalidManifest = -15,

    /** Virtuoso was unable to create the VirtuosoAsset due to asset being deleted. */
    kVDE_AssetDeleted = -16,

    /** Virtuoso was unable to create a VirtuosoSegment. */
    kVDE_CreateSegmentFailed = -17,
    
    /** User has exceeded the simultaneous access limit. */
    kVirtuosoDownloadEngineErrorTooManySimultaneousDownloads = -18,

    /** User has exceeded the simultaneous access limit. */
    kVirtuosoDownloadEngineErrorAdsRefreshError = -19,
    
    /** Virtuoso API received invalid parameter  */
    kVDE_InvalidParameter = -20,

    /** Virtuoso timeout waiting  */
    kVDE_TimeOutWaiting = -21,

    /** Asset was created for FastPlay download only */
    kVDE_FastPlayDownloadOnly = -22,

    /** Asset has invalid MediaHintUrl configuration */
    kVDE_InvalidMediaHintConfiguration = -23,
    
    /** An audio codec could not be matched to any video rendition with the specified audio codecs*/
    kVDE_AudioCodecNotFoundAmongSpecifiedCodecs = -24,
    
    /** A resolution could not be matched to any video rendition with the specified resolutions*/
    kVDE_ResolutionNotFoundAmongSpecifiedResolutions = -25,

    /** An audio codec could not be matched to any video rendition with the specified audio codecs and resolutions*/
    kVDE_AudioCodecNotAmongSpecifiedCodecsAndResolution = -26,
    
    /** A resolution could not be matched to any video rendition with the specified audio codecs and resolutions*/
    kVDE_ResolutionNotAmongSpecifiedCodecsAndResolution = -27,

    /** Neither an audio codec nor a resolution could not be matched to any video rendition with the specified audio codecs and resolutions*/
    kVDE_AudioCodecNorResolutionAmongSpecifiedCodecsAndResolution = -28,
    
    /** An audio codec and a resolution could not be matched to any video rendition with the specified audio codecs and resolutions*/
    kVDE_AudioCodecAndResolutionNotAmongSpecifiedCodecsAndResolution = -29,
};


/*!
 *  @typedef kVDE_ProxyErrorCode
 *
 *  @abstract Errors issued from VirtuosoClientHTTPServer during instantiation.  Issued via
 *            NSNotificationCenter. These codes are included in the NSError that is sent.
 */
typedef NS_ENUM(NSInteger, kVDE_ProxyErrorCode)
{
    /** For downloaded assets to remain playable, Virtuoso must sync with the Backplane at least every N seconds.
        When this time is exceeded, Virtuoso will issue this error every time you set up a proxy to play a downloaded asset. */
    kVDE_BackplaneAuthorizationTimedOut = -6,
    
    /** You attempted to play an asset outside its availability window. */
    kVDE_PlayedAssetOutsideViewingWindow = -7,
    
    /** You attempted to play an expired asset. */
    kVDE_PlayedAssetExpired = -8,
    
    /** The VirtuosoAsset used to initialize the proxy wasn't an invalid asset or the asset protection type was not
        kVDE_AssetProtectionTypePassthrough. */
    kVDE_InvalidAsset = -9,
    
    /** The HTTP server was unable to listen on the selected port */
    kVDE_PortInUse = -10,
    
    /** You attempted to play an asset with ads that have expired. */
    kVDE_PlayedAssetWithAdExpired = -11,
};

/*!
 *  @typedef kVDE_PlayerErrorCode
 *
 *  @abstract Errors issued from VirtuosoAVPlayer and associated classes.  Will be reported via the AVPlayer
 *            error property when the status property changes to AVPlayerStatusFailed.
 *
 *  @see VirtuosoAVPlayer
 */
typedef NS_ENUM(NSInteger, kVDE_PlayerErrorCode)
{
    /** VirtuosoAVPlayer supports playback of MP4, HLS, and MPEG-DASH assets.  FairPlay and Widevine DRM is 
        directly supported.  Integration with other DRM systems is possible, but may require additional integration. 
        Attempts to play any other asset type will result in this error. */
    kVDE_PlayerErrorAssetTypeNotSupported = -10,
    
    /** VirtuosoAVPlayer was unable to play the asset */
    kVDE_UnableToPlayAsset = -11,
};


#pragma mark
#pragma mark Virtuoso Asset Data Types
#pragma mark

/*!
 *  @constant kAssetPermissionErrorAssetDataKey
 *
 *  @abstract The key in the NSError userInfo dictionary containing information about current asset download state
 *            when Virtuoso fails to acquire download permission
 */
extern NSString* kAssetPermissionErrorAssetDataKey;


/*!
 *  @constant kAssetPermissionErrorAccountDataKey
 *
 *  @abstract The key in the NSError userInfo dictionary containing information about current account download state
 *            when Virtuoso fails to acquire download permission
 */
extern NSString* kAssetPermissionErrorAccountDataKey;

/*!
 *  @constant kAssetPermissionErrorServerResponseDataKey
 *
 *  @abstract The key in the NSError userInfo dictionary containing the raw server response to the permissions request.
 *            In the case where an external download policy service is used, this may be accessed to determine specific
 *            responses from that service.
 */
extern NSString* kAssetPermissionErrorServerResponseDataKey;

/*!
 *  @typedef kVF_SegmentType
 *
 *  @abstract Allowable Virtuoso types for segments
 */
typedef NS_ENUM(NSInteger, kVF_SegmentType)
{
    /** The file is of unknown type (default) */
    kVF_SegmentTypeUnknown = 0,
    
    /** The file is a sub-range of a larger monolithic file (MP4) */
    kVF_SegmentTypeSubRange = 1,
    
    /** The file is a video stream encryption key (HLS/HSS) */
    kVF_SegmentTypeStreamEncryptionKey = 3,
    
    /** The file is a video stream segment (HLS/HSS/DASH) */
    kVF_SegmentTypeStreamSegment = 4,
    
    /** The file is a video stream audio segment (HLS/HSS/DASH) */
    kVF_SegmentTypeStreamAudio = 5,
    
    /** The file is a video stream closed captioning segment (HLS/HSS/DASH) */
    kVF_SegmentTypeStreamCC = 6,
    
    /** The file is a ancillary */
    kVF_SegmentTypeAncillary = 7,

};

/*!
 *  @typedef kVF_DownloadDataType
 *
 *  @abstract A convenience type to define potential data Virtuoso will download.  This includes segment types as well as manifest data.
 */
typedef NS_ENUM(NSInteger, kVF_DownloadDataType)
{
    /** The data is for a segmented asset (HLS/HSS/DASH/etc) manifest */
    kVF_DataTypeManifest = 0,
    
    /** The data is for a video stream encryption key (HLS/HSS) */
    kVF_DataTypeStreamEncryptionKey = kVF_SegmentTypeStreamEncryptionKey,
    
    /** The data is for a video stream segment (HLS/HSS/DASH) */
    kVF_DataTypeStreamSegment = kVF_SegmentTypeStreamSegment,
    
    /** The data is for a audio stream audio segment (HLS/HSS/DASH) */
    kVF_DataTypeStreamAudio = kVF_SegmentTypeStreamAudio,
    
    /** The data is for a video stream closed captioning segment (HLS/HSS/DASH) */
    kVF_DataTypeStreamCC = kVF_SegmentTypeStreamCC,
};


/*!
 *  @typedef kVDE_AssetType
 *
 *  @discussion Allowable types for a VirtuosoAsset.
 *  "Non-segmented" represents a single file (E.G. MP4), and HLS and HSS are two segmented streaming video formats.
 */
typedef NS_ENUM(NSInteger, kVDE_AssetType)
{
    /** A single-file asset (E.G. MP4) */
    kVDE_AssetTypeNonSegmented = 0,
    
    /** A HTTP Live Streaming (HLS) asset */
    kVDE_AssetTypeHLS = 1,
    
    /** DEPRECATED  starting in v4.0, do not use.  A MPEG-DASH asset */
    kVDE_AssetTypeDASH = 3,
    
    /** DEPRECATED  starting in v4.0, do not use. A HTTP Smooth Streaming (HSS) asset
     This attribute is deprecated starting v4.0 */
    kVDE_AssetTypeHSS = 2,

};

/*!
 * @typedef kVDE_AssetProtectionType
 *
 * @discussion Allowable types for VirtuosoAssetProtection
 **/
typedef NS_ENUM(NSInteger, kVDE_AssetProtectionType)
{
    /** The asset is not protected, is protected by an external DRM system, or is protected by some form of 
        native encryption.  This value indicates that no special handling is required for download or playback
        of this asset, and is the default value. */
    kVDE_AssetProtectionTypePassthrough = 0,
    
    /** The asset is protected by Apple FairPlay DRM. */
    kVDE_AssetProtectionTypeFairPlay = 1,
    
    /** The asset is protected by Google Widevine DRM. */
    kVDE_AssetProtectionTypeWidevine = 2,    
};

/*!
 * @typedef kVDE_AssetPlaybackType
 *
 * @discussion Allowable options for asset playback
 **/
typedef NS_ENUM(NSInteger, kVDE_AssetPlaybackType)
{
    /** The asset will play using downloaded version */
    kVDE_AssetPlaybackTypeLocal = 0,
    
    /** The asset will play using the online stream */
    kVDE_AssetPlaybackTypeStream = 1,
    
    /** The asset will play using FastPlay, a mix of local and online data */
    kVDE_AssetPlaybackTypeFastPlay = 2,
};

/*!
 * @typedef kVDE_AssetPermissionType
 *
 * @discussion Available account or global asset permissions
 **/
typedef NS_ENUM(NSInteger, kVDE_AssetPermissionType)
{
    /** Permissions have not yet been requested for the asset */
    kVDE_AssetPermissionNotRequested = 0,
    
    /** Permission has been granted for the asset to download */
    kVDE_AssetPermissionGranted = 1,
    
    /** Permission to download has been denied because the account has reached is maximum limit */
    kVDE_AssetPermissionDeniedAccountMaxReached = 2,
    
    /** Permission to download has been denied because the global asset download limit has been reached */
    kVDE_AssetPermissionDeniedLifetimeLimitReached = 3,
    
    /** Permission to download has been denied because too many copies of this asset already exist on
        devices in this account */
    kVDE_AssetPermissionDeniedAssetCopiesPerAccountMaxReached = 4,
};

/*!
 *  @defined kInvalidExpiryTimeInterval
 *
 *  @abstract Defines an invalid expiry time interval.  If this value is provided to constructors that accept
 *            expiry after play or expiry after download values, then the backplane defaults for these properties
 *            will be applied.
 */
extern NSTimeInterval kInvalidExpiryTimeInterval;

/*!
 *  @defined kInfiniteExpiryTimeInterval
 *
 *  @abstract Defines an expiry time interval that is infinite, e.g the asset never expires.
 */
extern NSTimeInterval kInfiniteExpiryTimeInterval;

/*!
 *  @defined kInvalidDuration
 *
 *  @abstract Represents an invalid or unknown asset duration.
 */
extern NSTimeInterval kInvalidDuration;

/*!
 *  @typedef kVDE_DownloadStatusType
 *
 *  @abstract Allowable states that a Virtuoso asset can be in.  Returned via the 'status' property.
 */
typedef NS_ENUM(NSInteger, kVDE_DownloadStatusType)
{
    /** Download is complete; asset is stored locally */
    kVDE_DownloadComplete = 0,
    
    /** Asset is downloaded, and is being written to its final location on disk. */
    kVDE_DownloadProcessing = 1,
    
    /** Download is in progress for this asset */
    kVDE_DownloadActive = 2,
    
    /** Asset is in download queue, waiting its turn */
    kVDE_DownloadPending = 3,
    
    /** Asset exists, but is not in the download queue */
    kVDE_DownloadNone = 4,
    
    /** Virtuoso has marked this asset as expired */
    kVDE_DownloadExpired = 5,
    
    /** Asset has a publish date in the future, and thus unavailable */
    kVDE_DownloadNotAvailable = 6,
    
    /** Asset is being analyzed and prepared for download */
    kVDE_DownloadInitializing = 7,
    
    /** Asset is in download queue, waiting its turn, and has not been granted download permissions yet */
    kVDE_DownloadPendingOnPermission = 8,
    
    /** Asset is download complete, now scanning local content to verify everything matches manifest. */
    kVDE_DownloadConsistencyScan = 9,
    
    /** Asset is being deleted. */
    kVDE_DeleteInProcess = 10,
    
    /** Virtuoso has marked the ad for the asset as expired*/
     kVDE_DownloadAdExpired = 11,
};

/*!
 *  @typedef kVDE_DownloadErrorType
 *
 *  @abstract Error states that Virtuoso can be in when downloading an asset.  Returned via the 'error' property.
 */
typedef NS_ENUM(NSInteger, kVDE_DownloadErrorType)
{
    /** Virtuoso encountered no errors downloading this asset */
    kVDE_DownloadNoError = 0,
    
    /** Virtuoso encountered a network problem downloading asset, e.g. 404 or 416 HTTP error */
    kVDE_DownloadNetworkError = 1,
    
    /** Virtuoso failed to download this asset because it couldn't reach the remote server */
    kVDE_DownloadReachabilityError = 2,
    
    /** Virtuoso downloaded this asset, but couldn't move it to its final location on disk
    DEPRECATED  starting in v4.0, do not use. A HTTP Smooth Streaming (HSS) asset
     This attribute is deprecated starting v4.0 */
    kVDE_DownloadFileCopyError = 3,
    
    /** Virtuoso failed to download this asset because of an internal issue */
    kVDE_DownloadEngineError = 4,
    
    /** Virtuoso has attempted to download this asset the max times permitted. Will not try again 
        until you call reset or clearRetryCount */
    kVDE_DownloadMaxRetriesExceeded = 5,
    
    /** Virtuoso has received notice from the server that the user has downloaded this asset the
        maximum number of times for this account.  Downloads cannot continue for this asset. */
    kVDE_LifetimeDownloadLimitReached = 6,
    
    /** Virtuoso has attempted to start downloading an asset for which DRM is required before downloading
     and was unable to successfully retrieve a DRM license.  Downloads cannot continue for this asset. */
    kVDE_BlockedOnDRM = 7,
};

/*!
 *
 *  @typedef AsyncCompleteBlock
 *
 *  @discussion When you call an asynchronous SDK method, this callback indicates that
 *              Virtuoso has completely finished the requested action.
 */
typedef void(^AsyncCompleteBlock)(void);


#pragma mark
#pragma mark Segmented Asset Constants
#pragma mark

/*!
 *  @abstract An interface representing the basic information about an individual file segment download
 */
@protocol VirtuosoFileSegment

/*!
 *  @abstract A universally unique identifier (UUID) that Virtuoso generates when it created this segment.
 *
 */
@property (nonatomic,readonly) NSString* uuid;

/*!
 *  @abstract The universally unique identifier (UUID) of the Virtuoso asset that this segment is a part of.
 */
@property (nonatomic,readonly) NSString* assetUUID;

/*!
 *  @abstract The remote URL where this segment resides on the internet.
 */
@property (nonatomic,readonly) NSString* segmentURL;

/*!
 *  @abstract The type of segment (E.G. video, encryption key, audio)
 */
@property (nonatomic,assign) kVF_SegmentType segmentType;

/*!
 *  @abstract If this segment is a CC or Audio segment type, then this property indicates the language.
 *
 *  @discussion If this segment is a CC or Audio segment type, then the segmentSubtype property contains
 *              the value of the "NAME" attribute from the HLS manifest it was parsed from.  Otherwise, nil.
 */
@property (nonatomic,strong) NSString* segmentSubtype;

@end

/*!
 *  @typedef AssetParsingCompleteBlock
 *
 *  @discussion Fires when Virtuoso has finished parsing the asset
 *
 *  @param parsedAsset The VirtuosoAsset containing all the parsed segment objects.
 *  @param error If an error was encountered during asset creation that prevented the asset from
 *               being added to the queue, then this parameter will be non-nil.  If this parameter
 *               is non-nil, then the AssetReadyForDownloadBlock will not be called.
 */
typedef void(^AssetParsingCompletedBlock)(VirtuosoAsset* parsedAsset, NSError* error);

/*!
 *  @typedef AssetReadyForDownloadBlock
 *
 *  @discussion Fires when Virtuoso has finished parsing enough of the asset that it is safe to add it to the download queue
 *
 *  @param parsedAsset The VirtuosoAsset ready to be added to the download queue.
 */
typedef void(^AssetReadyForDownloadBlock)(VirtuosoAsset* parsedAsset);

/*!
 *  @typedef AssetAddToQueueCompleteBlock
 *
 *  @discussion Fires when Virtuoso has finished adding an asset to the queue.  If an error was encountered while adding
 *              the asset to the queue, it will be returned.  The userInfo dictionary will contain additional details
 *              about the error.
 *
 *  @param asset The VirtuosoAsset that was added to the queue
 *  @param error Any error that was encountered while adding the asset to the queue, otherwise nil
 */
typedef void(^AssetAddToQueueCompleteBlock)(VirtuosoAsset* asset, NSError* error);

/*!
 *  @typedef kVDM_ManifestType
 *
 *  @discussion Represents different types of manifests in the HLS specification.
 */
typedef NS_ENUM(NSInteger, kVDM_ManifestType)
{
    /** The master manifest */
    hlsManifestTypeMaster = 0,
    
    /** A sub-manifest defining a video rendition */
    hlsManifestTypeBitrate = 1,
    
    /** A sub-manifest defining an audio track */
    hlsManifestTypeAudio = 2,
    
    /** A sub-manifest defining a closed caption track */
    hlsManifestTypeCC = 3,
    
    /** A sub-manifest defining I-Frames */
    hlsManifestTypeIFRAME = 4,
};


#pragma mark
#pragma mark System Constants
#pragma mark

extern NSTimeInterval kDownloadEngineSyncIntervalMinimum;

#pragma mark
#pragma mark Health Monitor Settings
#pragma mark

/*!
 *  @constant kHealthMonitor_DisableHealthMonitor
 *
 *  @abstract NSUserDefault bool value to disable Health Monitor
 */
extern NSString* kHealthMonitor_DisableHealthMonitor;

/*!
 *  @constant kHealthMonitor_DefaultMonitorSleepInSeconds
 *
 *  @abstract NSUserDefault int value for default sleep time (seconds) between Health Monitor checks
 *
 *            The default value is 60 seconds.
 */
extern NSString* kHealthMonitor_DefaultMonitorSleepInSeconds;

/*!
 *  @constant kHealthMonitor_MinimumMonitorSleepInSeconds
 *
 *  @abstract NSUserDefault int value for MIMIMUM sleep time (seconds) between Health Monitor checks.
 *            When Engine issues are detected the Health Monitor will sleep this duration which is
 *            expected to be shorter than the default (kHealthMonitor_DefaultMonitorSleepInSeconds)
 *
 *            The default value is 20 seconds.
 
 *            This value must be at least as long as kHealthMonitor_MaxInterviewBetweenDownloads.
 */
extern NSString* kHealthMonitor_MinimumMonitorSleepInSeconds;

/*!
 *  @constant kHealthMonitor_IntervalBetweenDownloadsInSeconds
 *
 *  @abstract NSUserDefault int value in seconds for the maximum expected duration between Asset segment
 *            downloads. While the Engine is actively downloading, the HealthMonitor expects to see segments
 *            downloading continuously until the download is complete. If the HealthMonitor detects a time
 *            interval greater than this value, it starts checking Engine download health.
 *
 *            The default value is 20 seconds.
 */
extern NSString* kHealthMonitor_IntervalBetweenDownloadsInSeconds;

#pragma mark
#pragma mark Engine Consistency Scan Settings
#pragma mark

/*!
 *  @constant kVFM_DisableConsistencyScan
 *
 *  @abstract NSUserDefault bool value to disable consistency scan
 */
extern NSString* kVFM_DisableConsistencyScan;


#endif
