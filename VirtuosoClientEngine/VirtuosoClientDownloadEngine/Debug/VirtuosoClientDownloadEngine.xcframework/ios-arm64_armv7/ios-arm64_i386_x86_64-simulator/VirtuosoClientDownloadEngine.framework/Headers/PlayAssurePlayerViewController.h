//
//  PlayAssurePlayerViewController.h
//  VirtuosoClientEngineDemo
//
//  Created by dev on 5/24/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayAssurePlayerViewController : UIViewController
@property (nonatomic, strong)NSString* manifestURL;
@property (nonatomic, assign)Boolean streaming;
@property (nonatomic, strong)NSString* videoDescription;
@property (nonatomic, assign)Boolean displayStatus;
@end

NS_ASSUME_NONNULL_END

