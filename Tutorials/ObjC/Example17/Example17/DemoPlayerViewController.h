//
//  DemoPlayerViewController.h
//  Example17
//
//  Created by Penthera on 10/8/21.
//

#import <Foundation/Foundation.h>

#import <VirtuosoClientDownloadEngine/VirtuosoPlayerViewController.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoPlayerViewController : VirtuosoPlayerViewController<VirtuosoAVAssetResourceLoaderDelegateErrorHandler>

@end

NS_ASSUME_NONNULL_END
