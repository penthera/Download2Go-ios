//
//  DownloadWarning.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/5/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

//
// Adopted December 9, 2021
//

#import <VirtuosoClientDownloadEngine/VirtuosoAssetEvent.h>

NS_ASSUME_NONNULL_BEGIN

@class VirtuosoError;

/*!
 *  @abstract Base classs for Download Warning Analytics Events
 *  @discussion Base classs for Download Warning Analytics Events
 */
@interface DownloadWarning : VirtuosoAssetEvent

/*!
 *  @abstract Source code file name
 */
@property (nonatomic,readonly,nullable) NSString* source_file;

/*!
 *  @abstract Source code line number
 */
@property (nonatomic,readonly) NSInteger source_line;

/*!
 *  @abstract Error code.
 *  @see kVE_ErrorCategory
 */
@property (nonatomic,readonly) NSInteger error_code;

/*!
 *  @abstract Error message
 */
@property (nonatomic,readonly,nullable) NSString* error_message;

/*!
 *  @abstract Optional Sub error code
 */
@property (nonatomic,readonly) NSInteger sub_error_code;

/*!
 *  @abstract Optional Sub error message
 */
@property (nonatomic,readonly,nullable) NSString* sub_error_message;

/*!
 *  @abstract Number of instances of this event
 */
@property (nonatomic,readwrite) NSInteger event_instances;

@end

NS_ASSUME_NONNULL_END
