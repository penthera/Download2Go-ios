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

#import "AddNewItemViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"

/*
 * NOTE: These are for test/demo purposes only and you should NEVER access these directly.  They are used here
 *       only to create files with pre-configured error states to demo SDK capabilities.
 */
@interface VirtuosoAsset()
- (void)_setDownloadRetryCount:(int)newCount;
- (void)_setError:(kVDE_DownloadErrorType)error;
- (void)_setMaximumRetriesExceeded:(Boolean)exceeded;
@end

/*
 * NOTE: This method is for test/demo purposes only and you should NEVER access it.
 */
@interface VirtuosoSubscriptionManager()
- (void)generatePushUpdate:(NSDictionary*)data;
@end


@interface AddNewItemViewController ()
@end


/*
 *  NOTE: This view provides an example of how to add new download content to the Engine.  These files are hosted by Penthera
 *        and are for DEMO/EXAMPLE purposes only.  Penthera makes no warranty as to the usability or availability of this content.
 *        Some content types may be experimental and not supported in the official SDK release.  These content types will be marked
 *        as such below.
 */
@implementation AddNewItemViewController

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

    self.title = @"Add New Item";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doCancel)];
}

- (void)doCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Subscriptions";
            break;
            
        case 1:
            return @"Autoparsed HLS Video";
            break;

        case 2:
            return @"Autoparsed DASH Video";
            break;
            
        case 3:
            return @"Single MP4 Files";
            break;

        case 4:
            return @"Failure Modes";
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 3;
            break;

        case 2:
            return 3;
            break;
            
        case 3:
            return 3;
            break;

        case 4:
            return 9;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
        {
            // Normally, you'd keep track of subscription status in your own data store.  Since we're only supporting one
            // test feed in this demo app, it's just a basic setting value
            if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"TestFeedSubscribed"] )
            {
                cell.textLabel.text = @"Subscribe To Test Feed";
            }
            else
            {
                cell.textLabel.text = @"Unsubscribe From Test Feed";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if( indexPath.row == 1 )
        {
            cell.textLabel.text = @"Manual Sync With Subscriptions";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if( indexPath.row == 2 )
        {
            cell.textLabel.text = @"Trigger Demo Feed Episode";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if( indexPath.section == 1 )
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"The Boy In The Plastic Bubble (Large HLS)";
                break;

            case 1:
                cell.textLabel.text = @"Return Of The Kung Fu Dragon (Medium HLS)";
                break;

            case 2:
                cell.textLabel.text = @"Night Club Stock Video (Small HLS)";
                break;

            default:
                break;
        }
    }
    else if( indexPath.section == 2 )
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Google Widevine (Small)";
                break;
                
            case 1:
                cell.textLabel.text = @"Google Widevine (Large)";
                break;
                
            case 2:
                cell.textLabel.text = @"Google Widevine (A+V)";
                break;
                
            default:
                break;
        }
    }
    else if( indexPath.section == 3 )
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"The Boy In The Plastic Bubble MP4 (Large)";
                break;

            case 1:
                cell.textLabel.text = @"Return Of The Kung Fu Dragon MP4 (Medium)";
                break;

            case 2:
                cell.textLabel.text = @"Night Club Stock Video MP4 (Small)";
                break;

            default:
                break;
        }
    }
    else if( indexPath.section == 4 )
    {
        switch (indexPath.row ) {
            case 0:
                cell.textLabel.text = @"File Returning HTTP 404";
                break;
                
            case 1:
                cell.textLabel.text = @"File With Invalid Mime";
                break;
                
            case 2:
                cell.textLabel.text = @"File Exceeding Max Errors+Loops";
                break;
                
            case 3:
                cell.textLabel.text = @"File With Some Pre-Errors";
                break;
                
            case 4:
                cell.textLabel.text = @"File with publishDate 5 minutes from now";
                break;
                
            case 5:
                cell.textLabel.text = @"File with expiryDate 5 minutes from now";
                break;
                
            case 6:
                cell.textLabel.text = @"File with expiryAfterDownload at 5 minutes";
                break;
                
            case 7:
                cell.textLabel.text = @"File with expiryAfterPlay at 5 minutes";
                break;
                
            case 8:
                cell.textLabel.text = @"HLS File with Expiry 5 minutes from now";
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section > 1 )
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Adding item to queue...";
    }
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"TestFeedSubscribed"] )
            {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Subscribing to feed...";

                [[VirtuosoSubscriptionManager instance] registerForSubscription:@"CLIENT_ADD_ITEM_TEST_FEED" onComplete:^(Boolean success, NSError *error) {
                    if( success )
                    {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TestFeedSubscribed"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    hud.labelText = success?@"Success...":@"Failed...";
                    [hud hide:YES afterDelay:2.0];
                    [tableView reloadData];
                }];
            }
            else
            {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Unsubscribing from feed...";
                
                [[VirtuosoSubscriptionManager instance] unregisterForSubscription:@"CLIENT_ADD_ITEM_TEST_FEED" onComplete:^(Boolean success, NSError *error) {
                    if( success )
                    {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TestFeedSubscribed"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    hud.labelText = success?@"Success...":@"Failed...";
                    [hud hide:YES afterDelay:2.0];
                    [tableView reloadData];
                }];
            }
        }
        else if( indexPath.row == 1 )
        {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Syncing subscriptions...";
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            [[VirtuosoSubscriptionManager instance] syncSubscriptionsWithBackplaneNowOnComplete:^(Boolean success, NSArray *subscriptions, NSError *error) {
                hud.labelText = @"Sync complete...";
                [hud hide:YES afterDelay:2.0];
            }];
        }
        else if( indexPath.row == 2 )
        {
            // This private method calls a backplane endpoint that creates a new episode and adds it to Penthera's fixed constant "test feed".
            // If you have subscribed to the test feed and authorized push notices, then the server will post a silent push notice that causes
            // the subscription manager to sync and manage downloads.  This will result in a new item going into the download queue.  This is
            // a PRIVATE API and should not be used in production code.  It is for demo/testing ONLY.
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            // Append a persistently incrementing test number to these items so we can tell them apart.
            NSInteger testNum = [[NSUserDefaults standardUserDefaults]integerForKey:@"TestNum"];
            testNum++;
            [[NSUserDefaults standardUserDefaults] setInteger:testNum forKey:@"TestNum"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[VirtuosoSubscriptionManager instance] generatePushUpdate:@{@"title":[NSString stringWithFormat:@"Dilbert - Pirate's Booty: Test %li",(long)testNum],
                                                                         @"desc":@"Dilbert Test Push Item",
                                                                         @"contentSize":@(1576292),
                                                                         @"contentSizeIsEstimate":@(NO),
                                                                         @"duration":@(30),
                                                                         @"downloadURL":@"http://josh-push-test.s3.amazonaws.com/Dilbert_1000.m4v",
                                                                         @"streamURL":@"http://josh-push-test.s3.amazonaws.com/Dilbert_1000.m4v",
                                                                         @"downloadEnabled":@(YES),
                                                                         @"contentType":@"video/x-m4v"}];
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"New subscription item posted...";
            [hud hide:YES afterDelay:2.0];
        }
    }
    else if( indexPath.section == 1 )
    {
        // HLS content can autoparse the required files for download asynchronously.  This is the preferred method for adding HLS content to the system.
        // The completion block will be called when everything is complete.
        switch (indexPath.row) {
            case 0:
            {
                [VirtuosoAsset assetWithAssetID:@"TBITPBHLS"
                                    description:@"The Boy In The Plastic Bubble (Large HLS)"
                                    manifestUrl:@"http://hls-vbcp.s3.amazonaws.com/boy_in_bubble/prog_index.m3u8"
                                 protectionType:kVDE_AssetProtectionTypePassthrough
                          includeEncryptionKeys:YES
                                 maximumBitrate:INT_MAX
                                    publishDate:nil
                                     expiryDate:nil
                                 enableFastPlay:NO
                                       userInfo:nil
                                onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                    NSLog(@"Item is ready for download: %@",parsedAsset);
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                    NSLog(@"Finished parsing %@", parsedAsset);
                                    if( error != nil )
                                    {
                                        NSLog(@"Detected error creating new asset: %@",error);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }];
            }
                break;

            case 1:
            {
                [VirtuosoAsset assetWithAssetID:@"ROTKFDHLS"
                                    description:@"Return of the Kung Fu Dragon (Medium HLS)"
                                    manifestUrl:@"http://hls-vbcp.s3.amazonaws.com/dragon_ten_sec/prog_index.m3u8"
                                 protectionType:kVDE_AssetProtectionTypePassthrough
                          includeEncryptionKeys:YES
                                 maximumBitrate:INT_MAX
                                    publishDate:nil
                                     expiryDate:nil
                                 enableFastPlay:NO
                                       userInfo:nil
                                onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                    NSLog(@"Item is ready for download: %@",parsedAsset);
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                    NSLog(@"Finished parsing %@", parsedAsset);
                                    if( error != nil )
                                    {
                                        NSLog(@"Detected error creating new asset: %@",error);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }];
            }
                break;

            case 2:
            {
                [VirtuosoAsset assetWithAssetID:@"NCSVHLS"
                                    description:@"Night Club Stock Video (Small HLS)"
                                    manifestUrl:@"http://hls-vbcp.s3.amazonaws.com/night_club/prog_index.m3u8"
                                 protectionType:kVDE_AssetProtectionTypePassthrough
                          includeEncryptionKeys:YES
                                 maximumBitrate:INT_MAX
                                    publishDate:nil
                                     expiryDate:nil
                                 enableFastPlay:NO
                                       userInfo:nil
                                onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                    NSLog(@"Item is ready for download: %@",parsedAsset);
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                    NSLog(@"Finished parsing %@", parsedAsset);
                                    if( error != nil )
                                    {
                                        NSLog(@"Detected error creating new asset: %@",error);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }];
            }
                break;
                
            default:
                break;
        }
    }
    else if( indexPath.section == 2 )
    {
        // DASH files can be downloaded as well.
        switch (indexPath.row)
        {
            case 0:
            {
                [VirtuosoAsset assetWithAssetID:@"WIDEVINE_SMALL"
                                    description:@"Widevine Demo (Small)"
                                         mpdUrl:@"https://storage.googleapis.com/wvtemp/tejal/deluxe_content/test/deluxe_single.mpd"
                                 protectionType:kVDE_AssetProtectionTypeWidevine
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                 {
                     NSLog(@"Item is ready for download: %@",parsedAsset);
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                     [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
                                onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error)
                 {
                     NSLog(@"Finished parsing %@", parsedAsset);
                     if( error != nil )
                     {
                         NSLog(@"Detected error creating new asset: %@",error);
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                 }];
            }
                break;
                
            case 1:
            {
                [VirtuosoAsset assetWithAssetID:@"WIDEVINE_LARGE"
                                    description:@"Widevine Demo (Large)"
                                         mpdUrl:@"http://storage.googleapis.com/wvmedia/cenc/valkaama.mpd"
                                 protectionType:kVDE_AssetProtectionTypeWidevine
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                 {
                     NSLog(@"Item is ready for download: %@",parsedAsset);
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                     [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
                                onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error)
                 {
                     NSLog(@"Finished parsing %@", parsedAsset);
                     if( error != nil )
                     {
                         NSLog(@"Detected error creating new asset: %@",error);
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                 }];
            }
                break;
                
            case 2:
            {
                [VirtuosoAsset assetWithAssetID:@"WIDEVINE_AV"
                                    description:@"Widevine Demo (A+V)"
                                         mpdUrl:@"https://storage.googleapis.com/wvtemp/tejal/deluxe_content/deluxe_tejal_encrypted/deluxe_audio_video.mpd"
                                 protectionType:kVDE_AssetProtectionTypeWidevine
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                 {
                     NSLog(@"Item is ready for download: %@",parsedAsset);
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                     [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
                                onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error)
                 {
                     NSLog(@"Finished parsing %@", parsedAsset);
                     if( error != nil )
                     {
                         NSLog(@"Detected error creating new asset: %@",error);
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                 }];
            }
                break;
                
            default:
                break;
        }
    }
    else if( indexPath.section == 3 )
    {
        // Standard MP4 files can be downloaded as well.
        switch (indexPath.row) {
            case 0:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/TheBoyInThePlasticBubble.mp4"
                                          assetID:@"TBITPBMP4"
                                      description:@"The Boy In The Plastic Bubble MP4 (Large)"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                               onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                   NSLog(@"Item is ready for download: %@",parsedAsset);
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 1:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/ReturnoftheKungFuDragon.mp4"
                                          assetID:@"ROTKFDMP4"
                                      description:@"Return Of The Kung Fu Dragon MP4 (Medium)"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 2:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"NCSVMP4"
                                      description:@"Night Club Stock Video (Small)"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;

            default:
                break;
        }
    }
    else if( indexPath.section == 4 )
    {
        // All of these options are various error modes for test and example purposes.
        switch (indexPath.row) {
            case 0:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://www.penthera.com/dead.mp4"
                                          assetID:@"DeadLink"
                                      description:@"File with 404 Error"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 1:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"InvalidMIME"
                                      description:@"File With Invalid MIME"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 2:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"DeadFile"
                                      description:@"File Exceeding Max Retries"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        [parsedAsset _setDownloadRetryCount:4];
                                        [parsedAsset _setMaximumRetriesExceeded:YES];
                                        [parsedAsset _setError:kVDE_DownloadNetworkError];
                                        [parsedAsset saveOnComplete:nil];
                                      
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 3:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"ErroredFile"
                                      description:@"File With Some Pre-Retries"
                                      publishDate:nil
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        [parsedAsset _setDownloadRetryCount:1];
                                        [parsedAsset _setMaximumRetriesExceeded:NO];
                                        [parsedAsset _setError:kVDE_DownloadNetworkError];
                                        [parsedAsset saveOnComplete:nil];
                                      
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 4:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"PublishDate"
                                      description:@"File With Publish Date Now + 5m"
                                      publishDate:[NSDate dateWithTimeIntervalSinceNow:5.0*60.0]
                                       expiryDate:nil
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 5:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"ExpiryDate"
                                      description:@"File With Expiry Date Now + 5m"
                                      publishDate:nil
                                       expiryDate:[NSDate dateWithTimeIntervalSinceNow:5.0*60.0]
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 6:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"ExpiryAfterDownload"
                                      description:@"File With Expiry After Download 5m"
                                      publishDate:nil
                                       expiryDate:nil
                              expiryAfterDownload:5.0*60.0
                                  expiryAfterPlay:0.0
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
                
            case 7:
            {
                [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/NightClub.mp4"
                                          assetID:@"ExpiryAfterPlay"
                                      description:@"File With Expiry After Play 5m"
                                      publishDate:nil
                                       expiryDate:nil
                              expiryAfterDownload:0.0
                                  expiryAfterPlay:5.0*60.0
                                   enableFastPlay:NO
                                         userInfo:nil
                                    onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                        NSLog(@"Item is ready for download: %@",parsedAsset);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                  } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                      NSLog(@"Finished parsing %@", parsedAsset);
                                      if( error != nil )
                                      {
                                          NSLog(@"Detected error creating new asset: %@",error);
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
            }
                break;
             
            case 8:
            {
                [VirtuosoAsset assetWithAssetID:@"HLSExpiryAfterPlay"
                                    description:@"HLS File With Expiry Date Now + 2m"
                                    manifestUrl:@"http://hls-vbcp.s3.amazonaws.com/night_club/prog_index.m3u8"
                                 protectionType:kVDE_AssetProtectionTypePassthrough
                          includeEncryptionKeys:YES
                                 maximumBitrate:INT_MAX
                                    publishDate:nil
                                     expiryDate:[NSDate dateWithTimeIntervalSinceNow:2.0*60.0]
                                 enableFastPlay:NO
                                       userInfo:nil
                                onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                    NSLog(@"Item is ready for download: %@",parsedAsset);
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error) {
                                    NSLog(@"Finished parsing %@", parsedAsset);
                                    if( error != nil )
                                    {
                                        NSLog(@"Detected error creating new asset: %@",error);
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }];
            }
            default:
                break;
        }
    }
}

@end
