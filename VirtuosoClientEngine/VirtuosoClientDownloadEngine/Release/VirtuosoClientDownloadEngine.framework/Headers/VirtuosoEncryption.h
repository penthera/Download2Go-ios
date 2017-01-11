/*!
 *  @header VirtuosoEncryption
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

@interface VirtuosoEncryption : NSObject

+ (NSData*)deviceSpecificEncrypt:(NSData*)data;
+ (NSData*)deviceSpecificDecrypt:(NSData*)data;

@end
