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
 *  @copyright (c) 2018 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VSETTINGS_BASE
#define VSETTINGS_BASE

#import <Foundation/Foundation.h>

@interface VirtuosoSettingsBase : NSObject

-(Boolean)isVirtuosoKey:(NSString* _Nonnull)key;

-(void)registerDefaults:(NSDictionary<NSString *,id>* _Nonnull)registrationDictionary;

-(NSArray* _Nonnull)objectsForKeyContainingString:(NSString* _Nonnull)substring;
-(id _Nullable)objectForKey:(NSString* _Nonnull)key;
-(void)removeObjectForKey:(NSString*  _Nonnull)key;
-(void)setObject:(id _Nonnull)object forKey:(NSString*  _Nonnull)key;

-(BOOL)boolForKey:(NSString* _Nonnull)key;
-(void)setBool:(BOOL)value forKey:(NSString* _Nonnull)key;

-(NSInteger)integerForKey:(NSString* _Nonnull)key;
-(void)setInteger:(NSInteger)value forKey:(NSString* _Nonnull)key;

-(double)doubleForKey:(NSString* _Nonnull)key;
-(void)setDouble:(double)value forKey:(NSString* _Nonnull)key;

-(float)floatForKey:(NSString* _Nonnull)key;
-(void)setFloat:(float)value forKey:(NSString* _Nonnull)key;

-(void)setURL:(NSURL* _Nonnull)url forKey:(NSString* _Nonnull)key;
-(NSURL* _Nullable)URLForKey:(NSString* _Nonnull)key;

-(Boolean)synchronize;

@end


#endif

