/*!
 *  @header Virtuoso Notifications
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

#ifndef VirtuosoClientDownloadEngine_VirtuosoNotifications_h
#define VirtuosoClientDownloadEngine_VirtuosoNotifications_h

/**---------------------------------------------------------------------------------------
 * @name NSNotification UserInfo keys
 *  ---------------------------------------------------------------------------------------
 */

#pragma mark
#pragma mark NSNotification UserInfo keys
#pragma mark

/*!
 *  @constant kDownloadEngineAssetIDKey
 *
 *  @abstract Key for the assetID in the userInfo dictionary
 */
extern NSString* kDownloadEngineAssetIDKey;

/*!
 *  @constant kDownloadEngineStatusDidChangeNotificationKey
 *
 *  @abstract Key for the new download status in the userInfo dictionary
 */
extern NSString* kDownloadEngineStatusDidChangeNotificationStatusKey;

/*!
 *  @constant kDownloadEngineNotificationAssetKey
 *
 *  @abstract Key for the VirtuosoAsset object in the userInfo dictionary
 */
extern NSString* kDownloadEngineNotificationAssetKey;

/*!
 *  @constant kDownloadEngineNotificationContinuingAssetsKey
 *
 *  @abstract When the enclosing app goes to the background, Virtuoso may automatically continue downloading some
 *            of the queued assets. This key contains the keys for the queued VirtuosoAsset objects that will
 *            continue downloading in the background.
 */
extern NSString* kDownloadEngineNotificationContinuingAssetsKey;

/*!
 *  @constant kDownloadEngineNotificationPausingAssetsKey
 *
 *  @abstract When the enclosing app goes to the background, Virtuoso may automatically continue downloading some 
 *            of the queued assets. This key contains the keys for the queued VirtuosoAsset objects that will 
 *            *not* continue downloading in the background.
 */
extern NSString* kDownloadEngineNotificationPausingAssetsKey;

/*!
 *  @constant kDownloadEngineNotificationErrorKey
 *
 *  @abstract Key for the NSError object in the userInfo dictionary
 */
extern NSString* kDownloadEngineNotificationErrorKey;

/*!
 *  @constant kDownloadEngineNotificationSuccessValueKey
 *
 *  @abstract Key indicating success or failure of a particular action. Found in the userInfo dictionary.
 */
extern NSString* kDownloadEngineNotificationSuccessValueKey;

/**---------------------------------------------------------------------------------------
 * @name NSNotification Names
 *  ---------------------------------------------------------------------------------------
 */


#pragma mark
#pragma mark Download Engine NSNotification Names
#pragma mark

/*!
 *  @constant kDownloadEngineStatusDidChangeNotification
 *
 *  @abstract Fired when Virtuoso's download engine changes status.  The userInfo dictionary will
 *            contain the new status (in 'kDownloadEngineStatusDidChangeNotificationStatusKey').
 *
 *  @warning  Not reliably fired when downloads are happening in the background.
 *            Don't use this message as the only mechanism to track Virtuoso status. Be sure to
 *            check the current Virtuoso status via the appropriate property when the app is foregrounded.
 */
extern NSString* kDownloadEngineStatusDidChangeNotification;

/*!
 *  @constant kDownloadEngineDidStartDownloadingAssetNotification
 *
 *  @abstract Fired when Virtuoso starts downloading an asset.  The userInfo dictionary will contain 
 *            the asset that started downloading (in 'kDownloadEngineNotificationAssetKey').
 *
 *  @warning  Not reliably fired when downloads are happening in the background.
 *            Be prepared to handle missing download start messages and missing download progress messages.
 *            You may get no notice except for a download complete message.
 */
extern NSString* kDownloadEngineDidStartDownloadingAssetNotification;

/*!
 *  @constant kDownloadEngineProgressUpdatedForAssetNotification
 *
 *  @abstract Fired after Virtuoso has made some progress downloading an asset.  The userInfo dictionary
 *            will contain the asset (in 'kDownloadEngineNotificationAssetKey').
 *
 *  @warning  Not reliably fired when downloads are happening in the background.
 *            Be prepared to handle missing download start messages and missing download progress messages.
 *            You may get no notice except for a download complete message.
 */
extern NSString* kDownloadEngineProgressUpdatedForAssetNotification;

/*!
 *  @constant kDownloadEngineProgressUpdatedForAssetProcessingNotification
 *
 *  @abstract Fired after Virtuoso has made some progress finalizing (copying to its final location)
 *            a previously-downloaded asset. It will also be sent when processing has completed.
 *            Only relevant for assets downloaded in the background.  You can determine progress by 
 *            checking the fractionComplete property on the asset.
 *
 *            The userInfo dictionary will contain the asset (in 'kDownloadEngineNotificationAssetKey').
 */
extern NSString* kDownloadEngineProgressUpdatedForAssetProcessingNotification;

/*!
 *  @constant kDownloadEngineInternalQueueUpdateNotification
 *
 *  @abstract Fired when Virtuoso reorders the queue due to internal business logic.
 *
 *  @discussion Sometimes, due to internal processing, Virtuoso may reorder the download queue.  In
 *              response to this message, you should check the state of the queue and update your
 *              user interface, if needed.  This message is NOT sent if another message indicating 
 *              queue changes has already been sent, such as kDownloadEngineDidFinishDownloadingAssetNotification.
 */
extern NSString* kDownloadEngineInternalQueueUpdateNotification;

/*!
 *  @constant kDownloadEngineDidFinishDownloadingAssetNotification
 *
 *  @abstract Fired when an asset download completes.  The userInfo dictionary will contain the asset (in
 *            'kDownloadEngineNotificationAssetKey').
 */
extern NSString* kDownloadEngineDidFinishDownloadingAssetNotification;

/*!
 *  @constant kDownloadEngineDidEncounterErrorNotification
 *
 *  @abstract Fired when a download error is encountered.
 *
 *  @discussion The error localizedDescription will contain a reason for the failure.  This event DOES NOT mean
 *              Virtuoso has given up on the download.  Virtuoso will continue attempting to download
 *              this asset until the state changes to kVDE_Errors. The notice userInfo dictionary will contain
 *              both the error (kDownloadEngineNotificationErrorKey) and the asset that encountered 
 *              the error (kDownloadEngineNotificationAssetKey).
 */
extern NSString* kDownloadEngineDidEncounterErrorNotification;

/*!
 *  @constant kDownloadEngineDidEncounterWarningNotification
 *
 *  @abstract Fired when a download warning occurs.
 *
 *  @discussion The error localizedDescription will contain the reason.  This event DOES NOT mean 
 *              Virtuoso has given up on the download.  It suggests a potential issue, such as a mismatch 
 *              between the final downloaded file size and the expected file size reported by the server.
 *              The notice userInfo dictionary will contain both the error (kDownloadEngineNotificationErrorKey) 
 *              and the asset that encountered the error (kDownloadEngineNotificationAssetKey).
 */
extern NSString* kDownloadEngineDidEncounterWarningNotification;

/*!
 *  @constant kDownloadEngineIsEnteringBackgroundNotification
 *
 *  @abstract Fired when Virtuoso enters background mode.
 *            Typically occurs a few minutes after the user backgrounds or closes the enclosing app.
 *
 *  @discussion 'kDownloadEngineNotificationContinuingAssetsKey' and 'kDownloadEngineNotificationPausingAssetsKey'
 *              contain pending downloads. If both of these arrays are empty, then all queued downloads have completed.
 */
extern NSString* kDownloadEngineIsEnteringBackgroundNotification;

/*!
 *  @constant kBackplaneDidUnregisterDeviceNotification
 *
 *  @abstract Fired when Backplane acknowledges completing the 'unregister device' command.
 *
 *  @discussion The userInfo dictionary will contain the success flag (in 'kDownloadEngineNotificationSuccessValueKey')
 *              and NSError objects (in 'kDownloadEngineNotificationErrorKey').
 */
extern NSString* kBackplaneDidUnregisterDeviceNotification;

/*!
 *  @constant kBackplaneDeviceLimitReachedNotification
 *
 *  @abstract Fired when Backplane startup fails because user has reached their device limit.
 */
extern NSString* kBackplaneDeviceLimitReachedNotification;

/*!
 *  @constant kBackplaneInvalidCredentialsNotification
 *
 *  @abstract Fired when Backplane startup fails because the supplied credentials are invalid.
 */
extern NSString* kBackplaneInvalidCredentialsNotification;

/*!
 *  @constant kBackplaneDeviceAlreadyRegisteredNotification
 *
 *  @abstract Fired when Backplane startup fails because this device has already been registered.
 */
extern NSString* kBackplaneDeviceAlreadyRegisteredNotification;

/*!
 *  @constant kBackplaneCommunicationsFailureNotification
 *
 *  @abstract Fired when a communications error occurrs while syncing with the Backplane.  The userInfo
 *            dictionary will contain the error (in 'kDownloadEngineNotificationErrorKey').
 */
extern NSString* kBackplaneCommunicationsFailureNotification;

/*!
 *  @constant kBackplaneSyncResultNotification
 *
 *  @abstract Fired when Backplane sync completes.
 *
 *  @discussion The userInfo dictionary will contain the success flag (in 'kDownloadEngineNotificationSuccessValueKey')
 *              and NSError objects (in 'kDownloadEngineNotificationErrorKey').
 */
extern NSString* kBackplaneSyncResultNotification;

/*!
 *  @constant kBackplaneDeviceSaveResultNotification
 *
 *  @abstract Fired when Backplane acknowledges saving device data
 *
 *  @discussion The userInfo dictionary will contain the success flag (in 'kDownloadEngineNotificationSuccessValueKey')
 *              and NSError objects (in 'kDownloadEngineNotificationErrorKey').
 */
extern NSString* kBackplaneDeviceSaveResultNotification;

/*!
 *  @constant kBackplaneLogsSentNotification
 *
 *  @abstract Fired when Virtuoso finishes sending log data to the Backplane.
 *
 *  @discussion The userInfo dictionary will contain the success flag (in 'kDownloadEngineNotificationSuccessValueKey')
 *              and NSError objects (in 'kDownloadEngineNotificationErrorKey').
 */
extern NSString* kBackplaneLogsSentNotification;

/*!
 *  @constant kBackplaneRemoteKillNotification
 *
 *  @abstract Fired after Virtuoso receives a remote-wipe command from Backplane and has performed the wipe.
 *
 *  @discussion When Virtuoso receives a remote wipe command, it will delete all VirtuosoAsset
 *              objects, de-register the device from the Backplane, and reset Virtuoso to its virgin state,
 *              with no stored User or Group credentials.  You'll need to call startup again before you can
 *              perform any Virtuoso function.
 */
extern NSString* kBackplaneRemoteKillNotification;

/*!
 *  @constant kBackplaneAssetDeletedNotification
 *
 *  @abstract Fired after Virtuoso receives a remote delete command from the Backplane and has performed the delete.
 *
 *  @discussion The userInfo dictionary will contain the asset of the deleted object (kDownloadEngineAssetIDKey)
 */
extern NSString* kBackplaneAssetDeletedNotification;

/*!
 *  @constant kProxyDidEncounterErrorNotification
 *
 *  @abstract Fired when Virtuoso encounters an error attempting to playback an asset via the HLS proxy.
 *            The userInfo dictionary will contain the error (kDownloadEngineNotificationErrorKey).
 */
extern NSString* kProxyDidEncounterErrorNotification;

/*!
 *  @constant kDownloadEngineDidResetExpiredAssetsNotification
 *
 *  @abstract Fires when Virtuoso detects that a downloaded asset has expired.  An asset may expire
 *            because it has reached its expireAfterDownload or expireAfterPlay timeouts, or its expiryDate,
 *            or because you called forceExpire.
 *            The userInfo dictionary will contain the expired asset (in 'kDownloadEngineNotificationAssetKey').
 */
extern NSString* kDownloadEngineDidResetExpiredAssetsNotification;

/*!
 *  @constant kDownloadEngineDidBeginDataStoreUpgradeNotification
 *
 *  @abstract Fires when Virtuoso begins a data store upgrade from a previous version.  During this process,
 *            previously downloaded assets will not be available.
 */
extern NSString* kDownloadEngineDidBeginDataStoreUpgradeNotification;

/*!
 *  @constant kDownloadEngineDidFinishDataStoreUpgradeNotification
 *
 *  @abstract Fires when Virtuoso finishes a data store upgrade from a previous version.  Once this notice
 *            fires, all previously downloaded assets are available.  You may choose to refresh the UI or
 *            provide notice to the user at this time.
 */
extern NSString* kDownloadEngineDidFinishDataStoreUpgradeNotification;

#endif
