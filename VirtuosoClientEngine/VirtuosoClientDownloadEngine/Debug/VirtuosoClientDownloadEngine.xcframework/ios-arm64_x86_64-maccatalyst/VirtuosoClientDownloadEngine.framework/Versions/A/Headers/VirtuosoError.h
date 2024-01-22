//
//  VirtuosoError.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/16/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *
 *  @typedef kVE_ErrorCategory
 *
 *  @abstract Error categories for VirtuosoError codes
 *  @discussion Error categories for VirtuosoError codes
 */
typedef NS_ENUM(NSInteger, kVE_ErrorCategory)
{
    /** Beginning range for general errors  */
    kVE_CategoryGeneral = 1,
    
    /** Beginning range for download errors  */
    kVE_CategoryDownloader = 1000,
    
    /** Beginning range for Mainfest parsing errors */
    kVE_CategoryManifestParser = 2000,
    
    /** Beginning range for Proxy errrors during playback  */
    kVE_CategoryHttpProxy = 3000,
    
    /** Beginning range for  Player errors */
    kVE_CategoryPlayer = 4000,
    
    /** Beginning range for  DRM errors */
    kVE_CategoryDrm = 5000,
    
    /** Beginning range for Ads errors  */
    kVE_CategoryAds = 6000,

    /** Beginning range for Permission errors   */
    kVE_CategoryPermissions = 7000,
    
    /** Beginning range for   Backplane errors*/
    kVE_CategoryBackplane = 8000,
    
    /** Beginning range for Playlist errors  */
    kVE_CategoryPlaylist = 9000,

    /** Beginning range for PlayAssure errors  */
    kVE_CategoryPlayAssure = 10000,

};

/*!
 *
 *  @typedef kVE_Error
 *
 *  @abstract Error codes for VirtuosoError
 *  @discussion Error codes for VirtuosoError
 */
typedef NS_ENUM(NSInteger, kVE_Error)
{
    /**---------------------------------------------------------------------------------------
     * @name General Errors
     *  ---------------------------------------------------------------------------------------
     */
    
    /** GeneralError code indicating invalid push token received  */
    kVE_GeneralErrorInvalidPushToken = 1,
    
    /** GeneralError code indicating invalid asset  */
    kVE_GeneralErrorInvalidAsset = 2,
    
    /** GeneralError code indicating invalid parameter  */
    kVE_GeneralErrorInvalidParameter = 3,
    
    /** GeneralError code indicating unable to request permission while offline  */
    kVE_GeneralErrorUnableToRequestPermissionsWhenOffline = 4,
    
    /** GeneralError code indicating CoreData migration error  */
    kVE_GeneralErrorDataMigrationError = 5,
    
    
    /**---------------------------------------------------------------------------------------
     * @name Download Errors
     *  ---------------------------------------------------------------------------------------
     */

    /** Reachability error, network not reachable  */
    kVE_DownloadReachabilityError = 1000,
    
    /** Http error downloading content */
    kVE_DownloadHttpError = 1001,
    
    /** Invalid MIME error  downloading segment */
    kVE_DownloadMimeError = 1002,
    
    /** IO error saving download to local disk */
    kVE_DownloadIOError = 1003,
    
    /** File size did not match expected size error  */
    kVE_DownloadFileSizeError = 1004,
        
    /** Download engine state error.  */
    kVE_DownloadEngineStateError = 1005,
    
    /** Asset deleted by  user during processing */
    kVE_DownloadAssetDeletedDuringProcessing = 1006,

    /**---------------------------------------------------------------------------------------
     * @name Manifest Errors
     *  ---------------------------------------------------------------------------------------
     */

    /** Failed to download manifest due to reachability error */
    kVE_ManifestReachabilityError = 2000,
    
    /** HTTP error while downloading manifest */
    kVE_ManifestHttpError = 2001,
    
    /** MIME error downlading manifest */
    kVE_ManifestMimeError = 2002,
    
    /** Disk IO Error while saving manifest */
    kVE_ManifestIOError = 2003,
    
    /** Mainfest format error */
    kVE_ManifestFormatError = 2004,
    
    /** Manifest empty error */
    kVE_ManifestEmptyError = 2005,
    
    /** Manifest URL invalid */
    kVE_ManifestInvalidURL = 2006,
        
    /**  Multiple copies of same AssetID error */
    kVE_ManifestMultipleCopiesOfAsset = 2007,
    
    /**  Manifest configuration error */
    kVE_ManifestConfigError = 2008,
    
    /** Manifest unknown parsing error  */
    kVE_ManifestUnknownParsingError = 2009,

    /**---------------------------------------------------------------------------------------
     * @name Proxy Errors
     *  ---------------------------------------------------------------------------------------
     */

    /** For downloaded assets to remain playable, Virtuoso must sync with the Backplane at least every N seconds.
        When this time is exceeded, Virtuoso will issue this error every time you set up a proxy to play a downloaded asset. */
    kVE_ProxyBackplaneAuthorizationTimedOut = 3000,
    
    /** You attempted to play an asset outside its availability window. */
    kVE_ProxyPlayedAssetOutsideViewingWindow = 3001,
    
    /** You attempted to play an expired asset. */
    kVE_ProxyPlayedAssetExpired = 3002,
    
    /** The VirtuosoAsset used to initialize the proxy wasn't an invalid asset or the asset protection type was not
        kVDE_AssetProtectionTypePassthrough. */
    kVE_ProxyInvalidAsset = 3003,
    
    /** The HTTP server was unable to listen on the selected port */
    kVE_ProxyPortInUse = 3004,
    
    /** You attempted to play an asset with ads that have expired. */
    kVE_ProxyPlayedAssetWithAdExpired = 3005,

    /**---------------------------------------------------------------------------------------
     * @name Player Errors
     *  ---------------------------------------------------------------------------------------
     */
    
    /** Asset type not supported by Player */
    kVE_PlayerErrorAssetTypeNotSupported = 4000,
    
    /** Asset is not playable yet */
    kVE_PlayerUnableToPlayAsset = 4001,
    

    /**---------------------------------------------------------------------------------------
     * @name DRM Errors
     *  ---------------------------------------------------------------------------------------
     */
    /** Failed to retrieve DRM */
    kVE_DrmRetrievalFailed = 5000,
    
    /**---------------------------------------------------------------------------------------
     * @name Ads Errors
     *  ---------------------------------------------------------------------------------------
     */
    /** Failed to refresh Ads */
    kVE_AdsRefreshError = 6000,
    
    
    /**---------------------------------------------------------------------------------------
     * @name Permission Errors
     *  ---------------------------------------------------------------------------------------
     */
    /** Lifetime download limit error */
    kVE_PermissionErrorLifetimeDownloadLimit = 7000,
    
    /** Max downloads per account error */
    kVE_PermissionErrorMaximumDownloadsPerAccount = 7001,
    
    /** External policy service denied error */
    kVE_PermissionErrorExternalPolicyServiceDenied = 7002,
    
    /** Max copies per account error */
    kVE_PermissionErrorMaximumCopiesPerAccount = 7003,
    
    /**---------------------------------------------------------------------------------------
     * @name Backplane Errors
     *  ---------------------------------------------------------------------------------------
     */
    /** Backplane URL was invalid */
    kVE_BackplaneUrlError = 8000,
    
    /** Backplane not reachable */
    kVE_BackplaneNotReachable = 8001,
    
    /** Backplane returned nil response */
    kVE_BackplaneNilResponse = 8002,
    
    /** Backplane credentials were invalid */
    kVE_BackplaneInvalidCredentials = 8003,
    
    /** Backplane save device error */
    kVE_BackplaneSaveDeviceError = 8004,
    
    /** Backplane permission unkown failure */
    kVE_BackplanePermissionUnknownFailure = 8005,
    
    /** Backplane registration request data was invalid */
    kVE_BackplaneRegisterRequestDataInvalid = 8006,
    
    /** Backplane request was throttled */
    kVE_BackplaneRequestThrottled = 8007,
    
    /** Backplane authentication failed */
    kVE_BackplaneAuthFailed = 8008,
    
    /** Backplane unregister device failed */
    kVE_BackplaneUnregisterDeviceStatusError = 8009,
    
    /** Backplane uregister device failed with internal error */
    kVE_BackplaneUnregisterDeviceInternalError = 8010,
    
    /** Backplane send logs failed */
    kVE_BackplaneSendLogsFailed = 8011,
    
    /** Backplane sync failed */
    kVE_BackplaneSyncFailed = 8012,

    /**---------------------------------------------------------------------------------------
     * @name Playlist Errors
     *  ---------------------------------------------------------------------------------------
     */
    /** Playlist was is no longer active error */
    kVE_PlaylistErrorNotActive = 9000,
    
    /** Playlist API invalid parameter error */
    kVE_PlaylistErrorInvalidParameter = 9001,
    
    /** Plalist internal error */
    kVE_PlaylistErrorInternal = 9002,

    /**---------------------------------------------------------------------------------------
     * @name PlayAsure Errors
     *  ---------------------------------------------------------------------------------------
     */
    /** PlayAssure API invalid parameter */
    kVE_PlayAssureInvalidParameter = 10000,
    
    /** PlayAssure  create segment failed */
    kVE_PlayAssureCreateSegmentFail = 10001,
    
    /** PlayAssure  network error */
    kVE_PlayAssureErrorNetwork = 10002,
    
    /** PlayAssure  API parameter was invalid */
    kVE_PlayAssureParameterError = 10003,
    
    /** PlayAssure  proxy startup failure */
    kVE_PlayAssureWebProxyStartFailure = 10004,
    
    /** PlayAssure  manifest parsing failure */
    kVE_PlayAssureManifestParsingFailure = 10005,
    
    /** PlayAssure  submanifest parsing failure */
    kVE_PlayAssureSubManifestParsingFailure = 10006,
    
    /** PlayAssure  not authenticated */
    kVE_PlayAssureNotAuthenticated = 10007,
    
    /** PlayAssure  playback falure */
    kVE_PlayAssurePlaybackFailure = 10008,

};


/*!
 *  @abstract Errors returned by Penthera
 *
 *  @discussion Errors emitted by Penthera are of type VirtuosoError. Domain for VirtuosoError is "Virtuoso". Error codes are defined by enum kVE_Error
 *
 *  @see kVE_Error.
 *
 */
@interface VirtuosoError : NSError

/**---------------------------------------------------------------------------------------
 * @name Properties
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark Properties
#pragma mark

/*!
 *  @abstract Penthera VirtuosoError domain
 *  @discussion Domain string for VirutosoError's
 *
 */
@property (nonatomic, class, readonly)NSString* VirtuosoErrorDomain;


/*!
 *  @abstract Penthera VirtuosoError subcode
 *  @discussion VirtuosoError subcode which depends on value of VirtuosoError.code.
 *
 */
@property (atomic, assign, readonly)NSInteger subcode;

/*!
 *  @abstract Penthera VirtuosoError submessage text
 *
 */
@property (atomic, copy, readonly)NSString* _Nullable submessage;


@end

NS_ASSUME_NONNULL_END
