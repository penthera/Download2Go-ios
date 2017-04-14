/*!
 *  @header VirtuosoSecureClock
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
#import <Foundation/Foundation.h>

/*!
 *  @abstract A basic secure clock implementation
 *
 *  @discussion This class is used internally to the SDK to insure that the user cannot violate expiry,
 *              licensing, and business logic by modifying the device system clock.
 */
@interface VirtuosoSecureClock : NSObject

/*!
 *  @abstract The singleton instance access method
 *
 *  @discussion You must never instantiate a local copy of the VirtuosoSecureClock object.  This object
 *              is intended to be a static singleton accessed through the instance method only.  Instantiating a local
 *              copy will throw an exception.
 *
 *  @return Returns the VirtuosoSecureClock object instance.
 */
+ (nonnull VirtuosoSecureClock*)instance;

/*!
 *  @abstract Requests an update to the secure clock time.  This method is called internal to the SDK
 *            automatically at opportune times and you should not normally need to call it manually.
 */
- (void)update;

/*!
 *  @abstract The current secure clock time, or nil if a secure time cannot be determined.
 */
@property (nonatomic,readonly,nullable) NSDate* secureDate;

/*!
 *  @abstract Similar to the secureDate property, except that this method will return the current
 *            system clock time if a secure date cannot be determined.
 */
@property (nonatomic,readonly,nonnull) NSDate* date;

@end
