//
//  VirtuosoEncryption.h
//  VirtuosoClientDownloadEngine
//
//  Created by Josh Pressnell on 6/9/16.
//  Copyright © 2016 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirtuosoEncryption : NSObject

+ (NSData*)deviceSpecificEncrypt:(NSData*)data;
+ (NSData*)deviceSpecificDecrypt:(NSData*)data;

@end
