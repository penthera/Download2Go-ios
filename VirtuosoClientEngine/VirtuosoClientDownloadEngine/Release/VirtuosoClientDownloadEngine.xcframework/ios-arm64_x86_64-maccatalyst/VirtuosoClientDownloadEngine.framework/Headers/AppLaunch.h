//
//  AppLaunch.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/5/21.
//  Copyright © 2021 Penthera. All rights reserved.
//


//
// Adopted December 1, 2021
//


#import <VirtuosoClientDownloadEngine/VirtuosoBaseEvent.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Event raised during App launch.
 *
 *  @discussion This event is raised when the App launches
 *
 *  @see VirtuosoBaseEvent.
 *
 */
@interface AppLaunch : VirtuosoBaseEvent

/*!
 *  @abstract Boolean value indicating whether SDK was debug version
 *
 */
@property (nonatomic,readonly) Boolean is_debug_sdk;

/*!
 *  @abstract Number of times the app launch event happened.
 *
 */
@property (nonatomic,readonly) NSInteger app_launch_count;

/*!
 *  @abstract Device RAM available
 *
 */
@property (nonatomic,readonly) NSInteger device_memory_available;

/*!
 *  @abstract Device RAM memory total
 *
 */
@property (nonatomic,readonly) NSInteger device_memory_total;

/*!
 *  @abstract Device available storage
 *
 */
@property (nonatomic,readonly) NSInteger device_storage_available;

/*!
 *  @abstract Device storage total
 *
 */
@property (nonatomic,readonly) NSInteger device_storage_total;

/*!
 *  @abstract String representing Penthera SDK build version
 *
 */
@property (nonatomic,readonly,nonnull) NSString* sdk_build_version;

/*!
 *  @abstract String representing Penthera SDK build date
 *
 */
@property (nonatomic,readonly,nonnull) NSString* sdk_build_date;

/*!
 *  @abstract String representing Penthera SDK build info
 *
 */
@property (nonatomic,readonly,nonnull) NSString* sdk_build_info;

/*!
 *  @abstract String representing app id
 *
 */
@property (nonatomic,readonly,nonnull) NSString* app_id;

/*!
 *  @abstract String representing app version
 *
 */
@property (nonatomic,readonly,nonnull) NSString* app_version;


@end

NS_ASSUME_NONNULL_END
