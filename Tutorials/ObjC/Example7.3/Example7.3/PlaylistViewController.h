//
//  PlaylistViewController.h
//  Example7
//
//  Created by Penthera on 3/3/21.
//

#import <UIKit/UIKit.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

NS_ASSUME_NONNULL_BEGIN
@class VirtuosoPlaylist;

@interface PlaylistViewController : UITableViewController

@property (nonatomic, strong)VirtuosoPlaylist* playlist;

@end

NS_ASSUME_NONNULL_END
