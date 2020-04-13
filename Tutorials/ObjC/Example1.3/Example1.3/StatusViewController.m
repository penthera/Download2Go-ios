//
//  StatusViewController.m
//  Example2
//
//  Created by Penthera on 1/29/19.
//  Copyright © 2019 penthera. All rights reserved.
//

#import "StatusViewController.h"

static NSInteger RowCount = 10;
static NSString* CellIdentifier = @"Cell";

@interface StatusViewController ()

@property (nonatomic, strong) VirtuosoDownloadEngineNotificationManager* downloadEngineNotifications;
@property (nonatomic, strong) NSString* usedStorage;
@property (nonatomic, strong) NSString* downloadBandWidth;
@property (nonatomic, strong) NSDateFormatter* formatter;
@property (nonatomic, strong) VirtuosoEngineStatusInfo* engineStatus;
@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Engine Status";
    self.downloadEngineNotifications = [[VirtuosoDownloadEngineNotificationManager alloc] initWithDelegate:self];
    
    self.formatter = [[NSDateFormatter alloc]init];
    self.formatter.dateStyle = NSDateFormatterMediumStyle;
    self.formatter.timeStyle = NSDateFormatterMediumStyle;
    
    [self updateStatusInfo];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return RowCount;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Fetches all current status information in the Download engine
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"SDK Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [VirtuosoDownloadEngine versionString]];
            break;
        case 1:
            cell.textLabel.text = @"Engine Status";
            switch ([VirtuosoDownloadEngine instance].status) {
                case kVDE_Idle:
                    cell.detailTextLabel.text = @"Idle";
                    break;
                    
                case kVDE_Errors:
                    cell.detailTextLabel.text = @"Blocked(Errors)";
                    break;
                    
                case kVDE_Blocked:
                    cell.detailTextLabel.text = @"Blocked on Environment";
                    break;
                    
                case kVDE_Disabled:
                    cell.detailTextLabel.text = @"Disabled";
                    break;
                    
                case kVDE_Downloading:
                    cell.detailTextLabel.text = @"Downloading";
                    break;
                    
                case kVDE_AuthenticationFailure:
                    cell.detailTextLabel.text = @"Blocked on License";
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            cell.textLabel.text = @"Network Status";
            cell.detailTextLabel.text = self.engineStatus.isNetworkOK ? @"OK":@"Blocked";
            break;
            
        case 3:
            cell.textLabel.text = @"Storage Status";
            cell.detailTextLabel.text = self.engineStatus.isDiskOK?@"OK":@"Blocked";
            break;
            
        case 4:
            cell.textLabel.text = @"Disk Usage";
            cell.detailTextLabel.text = self.usedStorage == nil? @"0 MB":self.usedStorage;
            break;
            
        case 5:
            cell.textLabel.text = @"Download Queue";
            cell.detailTextLabel.text = self.engineStatus.isQueueOK?@"OK":@"Blocked";
            break;
            
        case 6:
            cell.textLabel.text = @"Account Status";
            cell.detailTextLabel.text = self.engineStatus.isAccountOK?@"OK":@"Blocked";
            break;

        case 7:
            cell.textLabel.text = @"Authentication Status";
            cell.detailTextLabel.text = self.engineStatus.authenticationOK?@"OK":@"Blocked";
            break;
            
        case 8:
            cell.textLabel.text = @"Download Band Width";
            cell.detailTextLabel.text = self.downloadBandWidth==nil? @"0 MBps":self.downloadBandWidth;
            break;
            
        case 9:
            cell.textLabel.text = @"Secure Time";
            cell.detailTextLabel.text = [self formatSecureClock];
            break;
            
        default:
            break;
    }
 
    return cell;
}

// Important:
// Penthera provides a secure clock. This method shows how to access it
-(NSString*)formatSecureClock {
    NSDate* date = [VirtuosoSecureClock.instance secureDate];
    if (!date) { return @""; }
    
    return [self.formatter stringFromDate:date];
}

/*
 *  This method is called upon receipt of all download-related notifications.
 *  It is called fairly frequently, and since we're querying on overall file storage
 *  statistics, that might take a short while, so we'll pass off the method calls and
 *  calculations to a background thread and then update the UI in the main thread.  These
 *  methods won't take a great deal of time, but due to the frequency of the calls we are
 *  making in THIS example, doing it this way prevents choppiness in the UI.
 */
- (void)updateStatusInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.engineStatus =  [VirtuosoDownloadEngine instance].engineStatusInfo;
        long long used = [VirtuosoAsset storageUsed]/1024/1024;
        NSString* kbps = [[VirtuosoDownloadEngine instance] downloadBandwidthString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.usedStorage = [NSString stringWithFormat:@"%qi MB",used];
            if (kbps.length) {
                self.downloadBandWidth = kbps;
            }
            [self.tableView reloadData];
        });
    });
}

- (void)downloadEngineDidFinishDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self updateStatusInfo];
}

- (void)downloadEngineDidStartDownloadingAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self updateStatusInfo];
}

- (void)downloadEngineProgressUpdatedForAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self updateStatusInfo];
}

- (void)downloadEngineProgressUpdatedProcessingForAsset:(VirtuosoAsset * _Nonnull)asset
{
    [self updateStatusInfo];
}

@end
