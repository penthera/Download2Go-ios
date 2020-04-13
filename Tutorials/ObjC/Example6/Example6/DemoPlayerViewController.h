//
//  DemoPlayerViewController.h
//  Example6
//
//  Created by Penthera on 11/30/18.
//  Copyright © 2018 penthera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayerViewController.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoPlayerViewController : VirtuosoPlayerViewController<VirtuosoAVAssetResourceLoaderDelegateErrorHandler>

@end

NS_ASSUME_NONNULL_END
