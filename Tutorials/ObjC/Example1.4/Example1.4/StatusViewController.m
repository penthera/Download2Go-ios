//
//  StatusViewController.m
//  Example2
//
//  Created by Penthera on 1/29/19.
//  Copyright © 2019 penthera. All rights reserved.
//

//
// Engine Status and Perfomance Settings Tutorial -
// This view demonstrates how to read and change various Penthera SDK Engine Settings.
// See the various calls to service didSelectRowAtIndexPath.
//

#import "StatusViewController.h"


enum PerformanceSettings : int {
taskRefillLimit,
taskRefillSize,
timeout,
maxHTTPConnections,
maxPackagerSegments,
backgroundSetupTime,
headroom,
maxStorage,
enableIFrames,
cellDownload,
proxyLogging,
backplaneLogging,
itemCount,
};

static NSString* CellIdentifier = @"Cell";

typedef void (^TextValidationClosure)(NSString*);
typedef void (^BooleanValidationClosure)(Boolean);

@interface StatusViewController ()

@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Engine Status";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return itemCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        switch (indexPath.row) {
            case taskRefillLimit:
                cell.textLabel.text = @"Task Refill Limit";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_TaskRefillLimit"] ];
                break;
                
            case taskRefillSize:
                cell.textLabel.text = @"Task Refill Size";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_TaskRefillSize"] ];
                break;
                
            case timeout:
                cell.textLabel.text = @"Timeout";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(instance.networkTimeout)];
                break;
                
            case maxPackagerSegments:
                cell.textLabel.text = @"Max Packager Segments";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_MaxPackagerSegments"]];
                break;
                
            case backgroundSetupTime:
                cell.textLabel.text = @"Packager Setup Time";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(MAX(20,[instance integerForKey:@"VFM_BackgroundSetupTime"]))];
                break;
                
            case maxStorage:
                cell.textLabel.text = @"Max Storage (MB)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [instance maxStorageAllowed] == NSIntegerMax ? @"Unlimited" : @([instance maxStorageAllowed]) ];
                break;
                
            case headroom:
                cell.textLabel.text = @"Headroom (MB)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(instance.headroom)];
                break;
                
            case enableIFrames:
                cell.textLabel.text = @"Enable IFRAMES";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", instance.iframeSupportEnabled ? @"Yes" : @"No"];
                break;
                
            case cellDownload:
                cell.textLabel.text = @"Enable Cellular Download";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", instance.downloadOverCellular ? @"Yes" : @"No"];
                break;
                
            case proxyLogging:
                cell.textLabel.text = @"Enable Proxy Logging";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", VirtuosoLogger.proxyLoggingEnabled ? @"Yes" : @"No"];
                break;
                
            case backplaneLogging:
                cell.textLabel.text = @"Enable Backplane Logging";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", VirtuosoLogger.backplaneLoggingEnabled ? @"Yes" : @"No"];
                break;
                
            case maxHTTPConnections:
                cell.textLabel.text = @"Max HTTP Connections";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_MaxHTTPConn"]];
                break;
                
            default:
                cell.textLabel.text = @"<missing value>";
                cell.detailTextLabel.text = nil;
                break;
        }
        
    }];
 
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case taskRefillSize:
            [self setTaskRefillSize:indexPath];
            break;
            
        case taskRefillLimit:
            [self setTaskRefillLimit:indexPath];
            break;
            
        case timeout:
            [self setTimeout:indexPath];
            break;
            
        case maxHTTPConnections:
            [self setMaxHTTPConnections:indexPath];
            break;
            
        case maxPackagerSegments:
            [self setMaxPackagerSegments:indexPath];
            break;
            
        case backgroundSetupTime:
            [self setBackgroundSetupTime:indexPath];
            break;
            
        case headroom:
            [self setMaxHeadroom:indexPath];
            break;
            
        case maxStorage:
            [self setMaxStorage:indexPath];
            break;
            
        case enableIFrames:
            [self setEnableIFrames:indexPath];
            break;
            
        case cellDownload:
            [self setCellularDownload:indexPath];
            break;
            
        case proxyLogging:
            [self setProxyLogging:indexPath];
            break;

        case backplaneLogging:
            [self setBackplaneLogging:indexPath];
            break;
            
        default:
            break;
    }
}

// Setting: VFM_TaskRefillLimit
// This value controls maximum number of active download tasks.
// Default: 10
-(void)setTaskRefillLimit:(NSIndexPath*)indexPath {
    
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal <= 0) {
                return;
            }
            
            [instance setInteger:iVal forKey:@"VFM_TaskRefillLimit"];
            [instance synchronize];
            
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Task Refill Limit"
                        settingName:@"Default 10"
                       settingValue:[NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_TaskRefillLimit"]]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}

// Setting: VFM_TaskRefillSize
// This value controls maximum number of pending segments considered when creating new download tasks.
// Default: 40
-(void)setTaskRefillSize:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal <= 0) {
                return;
            }
            
            [instance setInteger:iVal forKey:@"VFM_TaskRefillSize"];
            [instance synchronize];
            
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Task Refill Size"
                        settingName:@"Default 40"
                       settingValue:[NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_TaskRefillSize"]]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}

// Setting: VirtuosoSettings.instance.networkTimeout
// This value controls network timeout interval
// Default: 60 seconds
-(void)setTimeout:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal <= 0) {
                return;
            }
            
            instance.networkTimeout = iVal;
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Timeout"
                        settingName:@"Default 60 seconds"
                       settingValue:[NSString stringWithFormat:@"%@", @(instance.networkTimeout)]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}


// Setting: VFM_MaxHTTPConn
// This value controls maximum number of HTTP Connections that will be used during download.
// Default: 20
-(void)setMaxHTTPConnections:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal <= 0) {
                return;
            }
            
            [instance setInteger:iVal forKey:@"VFM_MaxHTTPConn"];
            [instance synchronize];
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Max HTTP Connections"
                        settingName:@"Default 20"
                       settingValue:[NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_MaxHTTPConn"]]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}


// Setting: VFM_MaxPackagerSegments
// This value controls maximum number of Packager Segments that will be requested for background download.
// Default: 200
-(void)setMaxPackagerSegments:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal <= 0) {
                return;
            }
            
            [instance setInteger:iVal forKey:@"VFM_MaxPackagerSegments"];
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Max Packager Segments"
                        settingName:@"Default 200"
                       settingValue:[NSString stringWithFormat:@"%@", [instance objectForKey:@"VFM_MaxPackagerSegments"]]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}


// Setting: Virtuoso.instance().headroom
// This value controls amount of storage that should remain free on the device.
// Default: 1GB, minimum 500 MB
-(void)setMaxHeadroom:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal < 500) {
                // Important:
                // This call shows how to reset headroom to whatever the default value is
                [instance resetHeadroomToDefault];
                return;
            }
            
            // Important:
            // VirtuosoSettings.instance().headroom is read-only. To change this value
            // use method VirtuosoSettings.instance().overrideHeadroom(Int64(ival))
            [instance overrideHeadroom:iVal];
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Max Headroom (in MB)"
                        settingName:@"Default 1024"
                       settingValue:[NSString stringWithFormat:@"%@", @(instance.headroom)]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}

// Setting: Virtuoso.instance().maxStorageAllowed
// This value controls maximum amount of storage that can be used.
// Default: unlimited
-(void)setMaxStorage:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal <= 0) {
                // Reset to unlimited
                [instance resetMaxStorageAllowedToDefault];
                return;
            }
            // Override unlimited with specific limit
            [instance overrideMaxStorageAllowed:iVal];
        };
        
        NSString* currentValue;
        if ([instance maxStorageAllowed] == NSIntegerMax) {
            currentValue = @"";
        } else {
            currentValue = [NSString stringWithFormat:@"%@", @([instance maxStorageAllowed])];
        }
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Max Storage (in MB)"
                        settingName:@"Default unlimited"
                       settingValue:currentValue
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}

// Setting: VFM_BackgroundSetupTime
// This value controls number of seconds needed for background download setup
// Default: 20 seconds
-(void)setBackgroundSetupTime:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        TextValidationClosure closure = ^(NSString* input) {
            if (!input.length) return;
            NSInteger iVal = [input integerValue];
            
            if (iVal < 20) { return; }
            
            [instance setInteger:iVal forKey:@"VFM_BackgroundSetupTime"];
            [instance synchronize];
            
        };
        
        [self changeTextValueDialog:indexPath
                            closure:closure
                       settingTitle:@"Packager Setup Time"
                        settingName:@"Default 20 seconds"
                       settingValue:[instance objectForKey:@"VFM_BackgroundSetupTime"]
                       keyboardType:UIKeyboardTypeNumberPad];
    }];
}
                             

// Setting: VirtuosoSettings.instance().iframeSupportEnabled
// This value controls enable/disable downloading of HLS IFRAME's
// Default: false
-(void)setEnableIFrames:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        BooleanValidationClosure closure = ^(Boolean input) {
            instance.iframeSupportEnabled = input;
        };
        
        [self changeBooleanValueDialog:indexPath
                               closure:closure
                          settingTitle:@"Enable IFRAMES"
                           settingName:@"Default No"
                          settingValue:[NSString stringWithFormat:@"%@", @(instance.iframeSupportEnabled)]];
    }];
}

// Setting: VirtuosoSettings.instance().downloadOverCellular
// This value controls enable/disable downloading over Cellular connection
// Default: false
-(void)setCellularDownload:(NSIndexPath*)indexPath {
    [VirtuosoSettings instanceOnReady:^(VirtuosoSettings * _Nonnull instance) {
        
        BooleanValidationClosure closure = ^(Boolean input) {
            [instance overrideDownloadOverCellular:input];
        };
        
        [self changeBooleanValueDialog:indexPath
                               closure:closure
                          settingTitle:@"Enable Cellular Download"
                           settingName:@"Default No"
                          settingValue:[NSString stringWithFormat:@"%@", @(instance.downloadOverCellular)]];
    }];
}

// This value controls enable/disable proxy logging
// Default: false
-(void)setProxyLogging:(NSIndexPath*)indexPath {
    BooleanValidationClosure closure = ^(Boolean input) {
        VirtuosoLogger.proxyLoggingEnabled = input;

    };
    
    [self changeBooleanValueDialog:indexPath
                           closure:closure
                      settingTitle:@"Enable Proxy Logging"
                       settingName:@"Default No"
                      settingValue:[NSString stringWithFormat:@"%@", VirtuosoLogger.proxyLoggingEnabled ? @"Yes" : @"No"]];
}

// This value controls enable/disable backplane logging
// Default: false
-(void)setBackplaneLogging:(NSIndexPath*)indexPath {
    BooleanValidationClosure closure = ^(Boolean input) {
        VirtuosoLogger.backplaneLoggingEnabled = input;

    };
    
    [self changeBooleanValueDialog:indexPath
                           closure:closure
                      settingTitle:@"Enable Backplane Logging"
                       settingName:@"Default No"
                      settingValue:[NSString stringWithFormat:@"%@", VirtuosoLogger.backplaneLoggingEnabled ? @"Yes" : @"No"]];
}

// General purpose Alert with input text box.
// When OK is clicked, the closure is called with value of the text input
-(void)changeTextValueDialog:(NSIndexPath*) indexPath
                     closure:(TextValidationClosure)closure
                settingTitle:(NSString*) settingTitle
                 settingName:(NSString*) settingName
                settingValue:(NSString*) settingValue
                keyboardType:(UIKeyboardType)keyboardType
{
    __block UITextField* inputTextField = nil;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:settingTitle message:settingName preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!inputTextField) return;
        
        closure(inputTextField.text);
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        inputTextField = textField;
        textField.keyboardType = keyboardType;
    }];
    
    [self presentViewController:alert animated:true completion:nil];
}

// General purpose Alert for yes/no option.
// When yes / no is clicked the closure is called with true (yes) / false (no)
-(void)changeBooleanValueDialog:(NSIndexPath*) indexPath
                        closure:(BooleanValidationClosure)closure
                   settingTitle:(NSString*) settingTitle
                    settingName:(NSString*) settingName
                    settingValue:(NSString*) settingValue
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:settingTitle message:settingName preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!closure) return;
        closure(true);
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    UIAlertAction* no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!closure) return;
        closure(false);
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];

    [alert addAction:yes];
    [alert addAction:no];
    
    [self presentViewController:alert animated:true completion:nil];
}

@end
