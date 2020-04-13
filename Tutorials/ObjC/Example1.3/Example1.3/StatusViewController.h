//
//  StatusViewController.h
//  Example2
//
//  Created by Penthera on 1/29/19.
//  Copyright © 2019 penthera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusViewController : UITableViewController<VirtuosoDownloadEngineNotificationsDelegate>

@end

NS_ASSUME_NONNULL_END
