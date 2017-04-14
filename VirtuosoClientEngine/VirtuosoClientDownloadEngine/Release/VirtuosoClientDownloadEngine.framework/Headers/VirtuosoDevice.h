/*!
 *  @header Virtuoso Device
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

#ifndef VDEVICE
#define VDEVICE

#import <Foundation/Foundation.h>

/*!
 *
 *  @typedef DeviceUpdateResultBlock
 *
 *  @discussion The result of a device update.  If unsuccessful, the error parameter will contain a detailed error.
 *
 *  @param success Whether the request succeeded
 *
 *  @param error Detailed information on the error. Nil if call was successful.
 */
typedef void(^DeviceUpdateResultBlock)(Boolean success,  NSError* _Nullable  error);


/*!
 *  @abstract Represents a specific device known to Virtuoso
 *
 *  @discussion A convenience class to access device-related values.
 *
 *  @warning You must never instantiate an object of this type directly.
 *           You can access a VirtuosoDevice instance via VirtuosoDownloadEngine's retrieval methods.
 */
@interface VirtuosoDevice : NSObject

/*!
 *  @abstract This device's nickname. Same as the device ID, by default.
 *
 */
@property (nonatomic,readonly,nonnull)   NSString* nickname;

/*!
 *  @abstract Sets a new nickname for this device.
 *
 *  @warning You can only call this method from the device itself.
 *           If you try to call this method from a different device, it will have no effect.
 *
 *  @param newNickname The new nickname for this device
 *
 *  @param onComplete A callback block indicating the result of the update
 */
- (void) updateNickname:(nonnull NSString*)newNickname onComplete:(nullable DeviceUpdateResultBlock)onComplete;

/*!
 *  @abstract Whether this device should allow downloads
 *
 *  @discussion The Backplane enforces a limit on the number of devices permitted
 *              to download per user account.
 *              The Backplane communicates the 'downloadEnabled' value to the SDK during a sync.
 *              This property is the most recent value received from the Backplane.
 */
@property (nonatomic,readonly)   Boolean   downloadEnabled;

/*!
 *  @abstract Enables (or disables) downloads for this device
 *
 *  @discussion The Backplane maintains this value.
 *              This method connects to the Backplane and requests a change to the value.
 *
 *  @param enabled The requested new 'download-enabled' flag for this device.
 *
 *  @param onComplete A callback block indicating the result of the update
 */
- (void) updateDownloadEnabled:(Boolean)enabled onComplete:(nullable DeviceUpdateResultBlock)onComplete;

/*!
 *  @abstract Virtuoso automatically generates a unique ID for each device.
 *            This UUID is not tied to any iOS-defined UUID.  It will persist across application
 *            upgrades and reinstalls, but will not persist across device restores.
 */
@property (nonatomic,readonly,nonnull) NSString* deviceID;

/*!
 *  @abstract When you call the VirtuosoDownloadEngine's startupWithBackplane method,
 *            you may supply your own, optional, external device ID.
 *            Virtuoso reports this value to the Backplane, which maintains this
 *            value along with the Virtuoso-assigned device ID.
 */
@property (nonatomic,readonly,nullable) NSString* externalDeviceID;

/*!
 *  @abstract The Virtuoso version reported by the CFBundleVersion info.plist entry.
 */
@property (nonatomic,readonly,nonnull) NSString* clientVersion;

/*!
 *  @abstract The device model reported by the operating system (e.g. "iPhone5")
 */
@property (nonatomic,readonly,nonnull) NSString* deviceModel;

/*!
 *  @abstract The OS version reported by the operating system (e.g. "6.1")
 */
@property (nonatomic,readonly,nonnull) NSString* deviceVersion;

/*!
 *  @abstract When this device last synced with the Backplane
 */
@property (nonatomic,readonly,nonnull) NSDate*   lastSyncDate;

/*!
 *  @abstract When this device's info was last changed
 */
@property (nonatomic,readonly,nonnull) NSDate*   lastModifiedDate;

/*!
 *  @abstract When the Backplane created a record for this device
 */
@property (nonatomic,readonly,nonnull) NSDate*   createdDate;

/*!
 *  @abstract The current push token associated with this device
 */
@property (nonatomic,readonly,nullable) NSString* pushToken;

/*!
 *  @abstract Whether this object represents the device we're running on now
 */
@property (nonatomic,readonly) Boolean   isThisDevice;

/*!
 *  @abstract Unregisters this device from the Backplane.
 *
 *  @discussion Removes the device record from the Backplane. Removes all downloaded assets from Device.
 *  If you wish to use this device again, you must call startup in VirtuosoDownloadEngine.
 *
 *  @param onComplete A callback block indicating the result of the update
 *
 *  @warning You can only unregister the current device, as opposed to other devices for the same userID.
 *           Attempts to unregister other devices will have no effect.
 */
- (void) unregisterOnComplete:(nullable DeviceUpdateResultBlock)onComplete;

@end

#endif
