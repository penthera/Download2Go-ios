//
//  DemoPlayerViewController.h
//  Example15
//
//  Created by Penthera on 7/20/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayerViewController.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoPlayerViewController : VirtuosoPlayerViewController<VirtuosoAVAssetResourceLoaderDelegateErrorHandler>

@end

NS_ASSUME_NONNULL_END
