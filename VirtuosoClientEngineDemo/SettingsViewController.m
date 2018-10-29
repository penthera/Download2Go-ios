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


#import "SettingsViewController.h"
#import "ModalAlert.h"
#import <mach/mach.h>
#import "UIActionSheet+MKBlockAdditions.h"
#import "UIBlockSwitch.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface SettingsViewController ()
{
    NSTimer* refreshTimer;
    id<NSObject> deviceObserver;
}
@property (nonatomic,strong) NSLock* CPUUsageLock;
@end

/*
 *  This view shows extensive status on what's going on with the Engine under-the-hood, and provides several options
 *  to manually configure Engine and Backplane settings parameters.
 */

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Since we're showing on-going CPU and memory usage levels, while this view is active, we're just going to reload all the data every few seconds
    // This approach is for demo purposes only, to monitor performance levels over time
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
    self.CPUUsageLock = [[NSLock alloc] init];
    
    // When the Backplane notifies us that it finished saving our device object, reload the devices section.
    deviceObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneDeviceSaveResultNotification
                                                                       object:nil
                                                                        queue:[NSOperationQueue mainQueue]
                                                                   usingBlock:^(NSNotification * _Nonnull note) {
                                                                       Boolean success = [[note.userInfo objectForKey:kDownloadEngineNotificationSuccessValueKey]boolValue];
                                                                       NSError* err = [note.userInfo objectForKey:kDownloadEngineNotificationErrorKey];
                                                                       
                                                                       [MBProgressHUD hideHUDForView:self.view animated:YES];

                                                                       if( !success && err != nil )
                                                                       {
                                                                           [[[UIAlertView alloc]initWithTitle:@"Error"
                                                                                                      message:err.localizedDescription
                                                                                                     delegate:nil
                                                                                            cancelButtonTitle:@"OK"
                                                                                            otherButtonTitles:nil]show];
                                                                       }
                                                                       
                                                                       [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
                                                                   }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDone:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(doReset:)];
    self.navigationItem.title = @"Settings and Status";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Reset the timer.
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    // Unregister for notification
    [[NSNotificationCenter defaultCenter] removeObserver:deviceObserver];
}

- (void)dealloc
{
    // Release here, just in case
    [refreshTimer invalidate];
    refreshTimer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)doDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doReset:(id)sender
{
    [UIActionSheet actionSheetWithTitle:@"Are you sure you want to reset all settings to backplane defaults?"
                                message:@""
                                buttons:@[@"Continue"]
                             showInView:self.view
                              onDismiss:^(id item, int buttonIndex) {
                                  [[VirtuosoSettings instance] resetHeadroomToDefault];
                                  [[VirtuosoSettings instance] resetMaxStorageAllowedToDefault];
                                  [self.tableView reloadData];
                              } onCancel:^{
                                  
                              }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
        return @"Engine Status";
    
    if( section == 2 )
        return @"Device Settings";
    
    return @"Engine Settings";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( section == 0 ) // Engine/Device status
        return 8;
    
    if( section == 2 ) // Device list
        return [VirtuosoDownloadEngine instance].devices.count;
    
    if( section == 1 ) // Engine settings
        return 7;
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( cell == nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                
    // Configure the cell...
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    if( indexPath.section == 0 )
    {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"Engine Status";
                switch ([VirtuosoDownloadEngine instance].status) {
                    case kVDE_Idle:
                        cell.detailTextLabel.text = @"Idle";
                        break;
                        
                    case kVDE_Errors:
                        cell.detailTextLabel.text = @"Download Errors";
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
                        
                    default:
                        break;
                }
            }
                break;
             
            case 1:
                cell.textLabel.text = @"Network Status";
                cell.detailTextLabel.text = [VirtuosoDownloadEngine instance].networkStatusOK?@"OK":@"Blocked";
                break;
                
            case 2:
                cell.textLabel.text = @"Storage Status";
                cell.detailTextLabel.text = [VirtuosoDownloadEngine instance].diskStatusOK?@"OK":@"Blocked";
                break;
                
            case 3:
            {
                // Mem Load
                cell.textLabel.text = @"Memory";
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    
                    double memUsage = 0;
                    vm_statistics_data_t vmStats;
                    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
                    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
                    
                    if(kernReturn == KERN_SUCCESS)
                        memUsage = vmStats.wire_count/1024.0;
                    else
                        memUsage = 0;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UITableViewCell* _cell = [tableView cellForRowAtIndexPath:indexPath];
                        if( _cell )
                        {
                            _cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.02f MB Used",memUsage];
                        }
                        
                    });
                });
            }
                break;
                
            case 4:
            {
                // CPU load
                cell.textLabel.text = @"CPU Usage";
                __weak SettingsViewController* weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    
                    processor_info_array_t cpuInfo= nil, prevCpuInfo = nil;
                    mach_msg_type_number_t numCpuInfo = 0, numPrevCpuInfo = 0;
                    float coreOne = 0;
                    float coreTwo = 0;
                    
                    natural_t numCPUsU = 0U;
                    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
                    if(err == KERN_SUCCESS)
                    {
                        [weakSelf.CPUUsageLock lock];
                        for(natural_t i = 0; i < numCPUsU; ++i)
                        {
                            float inUse, total;
                            if(prevCpuInfo)
                            {
                                inUse = (
                                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                                         );
                                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
                            }
                            else
                            {
                                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
                            }
                            
                            if( i == 0 )
                                coreOne = (inUse/total);
                            else
                                coreTwo = (inUse/total);
                        }
                        [weakSelf.CPUUsageLock unlock];
                        
                        if(prevCpuInfo)
                        {
                            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
                            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
                        }
                        
                        prevCpuInfo = cpuInfo;
                        numPrevCpuInfo = numCpuInfo;
                        
                        cpuInfo = NULL;
                        numCpuInfo = 0U;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UITableViewCell* _cell = [tableView cellForRowAtIndexPath:indexPath];
                        if( _cell )
                        {
                            if( numCPUsU == 1 )
                                _cell.detailTextLabel.text = [NSString stringWithFormat:@"%02.2f%%",coreOne*100.0];
                            else
                                _cell.detailTextLabel.text = [NSString stringWithFormat:@"Core 0(%02.2f%%)  Core 1(%02.2f%%)",coreOne*100.0,coreTwo*100.0];
                        }
                        
                    });

                    
                });
            }
                break;
                
            case 5:
            {
                // Get access to a file manager as our means to perform file operations
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                // Using the application home directory, get dictionary of attributes
                NSDictionary *attributesDict = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
                
                // Print total file system size and available space
                long long freeSpace = [[attributesDict objectForKey:NSFileSystemFreeSize] longLongValue];
                long long totalSpace = [[attributesDict objectForKey:NSFileSystemSize] longLongValue];
                
                cell.textLabel.text = @"Disk Use";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%qi MB Free of %qi MB",freeSpace/1024/1024,totalSpace/1024/1024];
            }
                break;
                
            case 6:
                cell.textLabel.text = @"Backplane Max Devices";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",(int)[VirtuosoSettings instance].maxDevicesForDownload];
                break;
                
            case 7:
                cell.textLabel.text = @"Current Devices Enabled";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",(int)[VirtuosoSettings instance].numberOfDevicesEnabled];
                break;

            default:
                break;
        }
    }
    else if( indexPath.section == 1 )
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Storage Headroom";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%qi MB",[VirtuosoSettings instance].headroom];
                break;
                
            case 1:
                cell.textLabel.text = @"Allowable Storage";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%qi MB",[VirtuosoSettings instance].maxStorageAllowed];
                break;
                
            case 2:
                cell.textLabel.text = @"Download Over Cellular";
                cell.detailTextLabel.text = nil;
                cell.accessoryView = [UIBlockSwitch switchWithState:[VirtuosoSettings instance].downloadOverCellular onChange:^(Boolean newValue) {
                    [[VirtuosoSettings instance]overrideDownloadOverCellular:newValue];
                }];
                break;
                
            case 3:
                cell.textLabel.text = @"Use HLS Background Xfer";
                cell.detailTextLabel.text = nil;
                cell.accessoryView = [UIBlockSwitch switchWithState:[[NSUserDefaults standardUserDefaults] boolForKey:@"UsePackager"] onChange:^(Boolean newValue) {
                    [[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"UsePackager"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[[UIAlertView alloc]initWithTitle:@"Changes Saved"
                                               message:@"Your changes will not take effect until the next time you hard reset the test harness app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                }];
                break;
                
            case 4:
                cell.textLabel.text = @"Provide Client SSL Cert";
                cell.detailTextLabel.text = nil;
                cell.accessoryView = [UIBlockSwitch switchWithState:[[NSUserDefaults standardUserDefaults]boolForKey:@"UseClientSSL"] onChange:^(Boolean newValue) {
                    [[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"UseClientSSL"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    if( newValue )
                    {
                        [VirtuosoSettings instance].clientSSLCertificatePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
                        [VirtuosoSettings instance].clientSSLCertificatePassword = @"p3nth3ra";
                    }
                    else
                    {
                        // Reset this just in case it was saved from some previous session.  Not strictly needed, but safer to be explicit.
                        [VirtuosoSettings instance].clientSSLCertificatePath = nil;
                        [VirtuosoSettings instance].clientSSLCertificatePassword = nil;
                    }

                }];
                break;
                
            case 5:
                cell.textLabel.text = @"Max Items Per Feed";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[VirtuosoSubscriptionManager instance].maximumSubscriptionItemsPerFeed];
                break;
                
            case 6:
                cell.textLabel.text = @"Auto-Delete Old Items";
                cell.detailTextLabel.text = nil;
                cell.accessoryView = [UIBlockSwitch switchWithState:[VirtuosoSubscriptionManager instance].autodeleteOldItems onChange:^(Boolean newValue) {
                    [VirtuosoSubscriptionManager instance].autodeleteOldItems = newValue;
                }];
                break;
                
            default:
                break;
        }
    }
    else if( indexPath.section == 2 )
    {
        VirtuosoDevice* device = [[VirtuosoDownloadEngine instance].devices objectAtIndex:indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = device.nickname;
        cell.detailTextLabel.text = device.downloadEnabled?@"Enabled":@"Disabled";
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if( indexPath.section == 0 )
    {
        // Nothing to do
    }
    else if( indexPath.section == 1 )
    {
        switch (indexPath.row) {
            case 0:
            {
                [ModalAlert ask:@"New Headroom?"
                 withTextPrompt:@"Headroom (MB)"
               withKeyboardType:UIKeyboardTypeNumberPad
         withAutoCapitalization:UITextAutocapitalizationTypeNone
            withSecureTextEntry:NO
               withInitialValue:[NSString stringWithFormat:@"%qi",[VirtuosoSettings instance].headroom] onResponse:^(NSString *newHeadroom) {
                   if( newHeadroom != nil )
                   {
                       [[VirtuosoSettings instance] overrideHeadroom:[newHeadroom longLongValue]];
                       [tableView reloadData];
                   }
               }];
            }
                break;
                
            case 1:
            {
                [ModalAlert ask:@"Allowable Storage?"
                 withTextPrompt:@"Allowable Storage (MB)"
               withKeyboardType:UIKeyboardTypeNumberPad
         withAutoCapitalization:UITextAutocapitalizationTypeNone
            withSecureTextEntry:NO
               withInitialValue:[NSString stringWithFormat:@"%qi",[VirtuosoSettings instance].maxStorageAllowed] onResponse:^(NSString *newStorage) {
                   if( newStorage != nil )
                   {
                       [[VirtuosoSettings instance] overrideMaxStorageAllowed:[newStorage longLongValue]];
                       [tableView reloadData];
                   }
               }];
            }
                break;
                
            case 5:
            {
                [ModalAlert ask:@"Max Items Per Feed?"
                 withTextPrompt:@"Max Items Per Feed"
               withKeyboardType:UIKeyboardTypeNumberPad
         withAutoCapitalization:UITextAutocapitalizationTypeNone
            withSecureTextEntry:NO
               withInitialValue:[NSString stringWithFormat:@"%i",[VirtuosoSubscriptionManager instance].maximumSubscriptionItemsPerFeed] onResponse:^(NSString *newValue) {
                   if( newValue != nil )
                   {
                       [VirtuosoSubscriptionManager instance].maximumSubscriptionItemsPerFeed = [newValue intValue];
                       [tableView reloadData];
                   }
               }];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        VirtuosoDevice* device = [[VirtuosoDownloadEngine instance].devices objectAtIndex:indexPath.row];
        NSString* actionString = device.downloadEnabled?@"Disable Download":@"Enable Download";
        NSString* destructiveButtonTitle = nil;
        NSArray* actionArray = nil;
        
        // We can only unregister or update the nickname for the device we're currently on.  We can enable/disable
        // download permissions for any device.
        if( device.isThisDevice )
        {
            destructiveButtonTitle = @"Unregister Device";
            actionArray = @[actionString,@"Update Nickname"];
        }
        else
        {
            actionArray = @[actionString];
        }
        
        [UIActionSheet actionSheetWithTitle:@"Update Device"
                                    message:@""
                     destructiveButtonTitle:destructiveButtonTitle
                                    buttons:actionArray
                                 showInView:self.view
                                  onDismiss:^(id item, int buttonIndex) {
                                      
                                      // Used to simplify logic flow.  If the device we're working with is NOT this device, then
                                      // the only option they could have chosen is to toggle the download permission.
                                      if( !device.isThisDevice )
                                          buttonIndex++;
                                      
                                      if( buttonIndex == 0 ) // Unregister
                                      {
                                          [device unregisterOnComplete:^(Boolean success, NSError *error) {
                                              
                                          }];
                                      }
                                      
                                      else if( buttonIndex == 1 ) // Toggle download enable
                                      {
                                          MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                          hud.labelText = @"Saving Device...";

                                          // We toggle the permission and save the device.
                                          [device updateDownloadEnabled:!device.downloadEnabled onComplete:^(Boolean success, NSError *error) {
                                              [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          }];
                                      }
                                      
                                      else if( buttonIndex == 2 ) // Update nickname
                                      {
                                          // We set the new nickname and save the device.
                                          [ModalAlert ask:@"New Nickname" withTextPrompt:@"Nickname" withKeyboardType:UIKeyboardTypeDefault withAutoCapitalization:UITextAutocapitalizationTypeNone withSecureTextEntry:NO withInitialValue:device.nickname onResponse:^(NSString *newNick) {
                                              if( newNick != nil )
                                              {
                                                  MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                  hud.labelText = @"Saving Device...";

                                                  [device updateNickname:newNick onComplete:^(Boolean success, NSError *error) {
                                                      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  }];
                                              }
                                          }];
                                      }
                                      
                                  } onCancel:^{
                                      
                                  }];
        
    }
}

- (void)say:(NSString*)text
{
    if( text.length > 0 )
        [[[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}


@end
