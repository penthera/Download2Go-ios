//
//  BeaconsViewController.m
//  Example15
//
//  Created by Penthera on 07/22/20.
//  Copyright © 2020 penthera. All rights reserved.
//

#import "BeaconsViewController.h"

@interface BeaconsViewController ()

@property (nonatomic, strong) NSMutableArray* beaconSections;
@property (nonatomic, strong) NSMutableDictionary* beaconRowsBySection;

@end

@implementation BeaconsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Beacons";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.beaconSections) {
        return [self.beaconSections count];
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.beaconRowsBySection)
    {
        NSArray* beaconRows = [self.beaconRowsBySection objectForKey:@(section)];
        
        if (beaconRows)
        {
            return [beaconRows count];
        }
    }
    
    return 0;
}

- (nullable NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     
    if (section < [self.beaconSections count])
    {
        return [self.beaconSections objectAtIndex:section];
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UILabel* headerLabel = [[UILabel alloc] init];

    headerLabel.font = [UIFont boldSystemFontOfSize:10.0];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    [headerLabel sizeToFit];

    return headerLabel.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* headerLabel = [[UILabel alloc] init];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:10.0];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;

    [headerLabel sizeToFit];

    return headerLabel;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"BeaconCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( cell == nil )
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Menlo" size:8.0]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Menlo" size:8.0]];
    cell.detailTextLabel.numberOfLines = 0;
    
    cell.textLabel.text = @"";
    
    NSArray* beaconRows = [self.beaconRowsBySection objectForKey:@(indexPath.section)];
          
    if (beaconRows)
    {
        if (indexPath.row < [beaconRows count])
        {
            NSString* beaconInfo = [beaconRows objectAtIndex:indexPath.row];
           
            if (beaconInfo)
            {
                cell.detailTextLabel.text = beaconInfo;
            }
        }
    }
    
    return cell;
}

#pragma mark - Set up beacon data to display

-(void)setupBeacons:(NSArray*)beaconsReported
{
    self.beaconSections = [NSMutableArray new];
    self.beaconRowsBySection = [NSMutableDictionary new];
        
    unsigned int currentSection = 0;
    
    NSNumber* lastAdInstance = @(0);
    NSString* lastAdUUID = @"";
    
    NSMutableArray* currentBeacons = nil;
   
    for (NSUInteger i = 0; i < [beaconsReported count]; i++)
    {
        NSDictionary* beaconInfo = [beaconsReported objectAtIndex:i];
        
        if (beaconInfo)
        {
            // Sections will demarcated by ad and instance
            
            NSNumber* currentAdInstance = [beaconInfo objectForKey:@"ads_instance"];
            NSString* currentAdUUID = [beaconInfo objectForKey:@"ads_UUID"];
            
            if (currentAdUUID && currentAdInstance)
            {
                if (![currentAdInstance isEqualToNumber:lastAdInstance] || ![currentAdUUID isEqualToString:lastAdUUID])
                {
                    // New section
                    
                    if (currentBeacons)
                    {
                        [self.beaconRowsBySection setObject:currentBeacons forKey:@(currentSection++)];
                    }
                    
                    // Section info
                                   
                    NSString* adName = [beaconInfo objectForKey:@"ads_name"];
                    NSNumber* adBreak = [beaconInfo objectForKey:@"ads_break"];
                    NSString* adDurationSeconds = [beaconInfo objectForKey:@"ads_duration_seconds"];
                    
                    NSString* headerText = [NSString stringWithFormat:@"%@ - %@ seconds - Break %@ - Instance %@", adName, adDurationSeconds, adBreak, currentAdInstance];

                    [self.beaconSections addObject:headerText];
                                        
                    currentBeacons = [NSMutableArray new];
                }
                
                // Row info
                
                NSString* adEventName = [beaconInfo objectForKey:@"ads_event_name"];
                NSString* beaconData = [beaconInfo objectForKey:@"ads_beacon_data"];
                NSNumber* httpResponseCode = [beaconInfo objectForKey:@"httpResponseCode"];
                NSNumber* adTimeOffset = [beaconInfo objectForKey:@"ads_time_offset"];
                NSString* url = [beaconInfo objectForKey:@"url"];
                
                NSMutableString* detailText = [NSMutableString new];
                
                [detailText appendFormat:@"      Event: %@\n", adEventName];
                [detailText appendFormat:@"     Beacon: %@\n", beaconData];
                [detailText appendFormat:@"Time Offset: %@\n", adTimeOffset];
                [detailText appendFormat:@"   Response: %@\n", httpResponseCode];
                [detailText appendFormat:@"        URL: %@", url];
                                
                [currentBeacons addObject:detailText];
                
                lastAdInstance = currentAdInstance;
                lastAdUUID = currentAdUUID;
            }
        }
    }
    
    if (currentBeacons)
    {
        [self.beaconRowsBySection setObject:currentBeacons forKey:@(currentSection)];
    }
        
    return;
}

@end
