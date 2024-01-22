//
//  PlayAssureABPlayerViewController.h
//  VirtuosoClientEngineDemo
//
//  Created by Penthera on 5/24/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayAssureABPlayerViewController : UIViewController

-(instancetype)initWithManifestURL:(NSString*)url
                     targetBitrate:(long long)targetBitrate
                     displayStatus:(Boolean)displayStatus
                  videoDescription:(NSString*)videoDescription;

@end

NS_ASSUME_NONNULL_END

