//
//  VirtuosoGoogleAdsServerProvider.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 4/29/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "VirtuosoAdsServerProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface VirtuosoGoogleAdsServerProvider : VirtuosoAdsServerProvider

@end

NS_ASSUME_NONNULL_END
