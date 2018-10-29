/*!
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  The VirtuosoClientEngineDemo project has been provided as an example application
 *  that uses the Virtuoso Download SDK.  It is provided as-is with no warranties whatsoever,
 *  expressed or implied.  This project provides a working example and shows ONE possible
 *  use of the SDK for a end-to-end video download process.  Other configurations
 *  are possible.  Please contact Penthera support if you have any questions.  We
 *  are here to help!
 *
 *  @copyright (c) 2017 Penthera Inc. All Rights Reserved.
 *
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UILabel* statusLabel;
    IBOutlet UIBarButtonItem* startButton;
    IBOutlet UIBarButtonItem* editButton;
    IBOutlet UIToolbar* toolbar;
    IBOutlet UILabel* usedLabelLabel;
    IBOutlet UILabel* statusLabelLabel;
}

- (IBAction)doStart:(id)sender;
- (IBAction)doEdit:(id)sender;
- (IBAction)doSettings:(id)sender;
- (IBAction)doAddVideo:(id)sender;

@property (nonatomic,strong) IBOutlet UILabel* usedStorageLabel;
@property (nonatomic,readonly) IBOutlet UITableView* tableView;

@end
