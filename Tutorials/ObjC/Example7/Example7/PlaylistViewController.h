//
//  PlaylistViewController.h
//  Example7
//
//  Created by Penthera on 7/15/19.
//  Copyright © 2019 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
NS_ASSUME_NONNULL_BEGIN

@interface PlaylistViewController : UITableViewController

@property (nonatomic, strong)VirtuosoPlaylist* playlist;

@end

NS_ASSUME_NONNULL_END
