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
#import "ModalAlert.h"

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
    
    self.logCHProd = @[@"http://wp24-vod-ch.horizon.tv/shss/9b508ab6-2bb6-41e5-96a1-a8e63e4604d1/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp8-vod-ch.horizon.tv/shss/22532f5f-d3fb-44c9-9733-227806e44d66/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp19-vod-ch.horizon.tv/shss/507000a1-59fd-4ffa-aff8-df7ca8a955da/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp26-vod-ch.horizon.tv/shss/b0cb110f-e49f-4a82-bb5f-ccf877fd4185/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp15-vod-ch.horizon.tv/shss/de8445c4-2cc9-49de-a8a9-3240598f72a8/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp16-vod-ch.horizon.tv/shss/db349daa-3def-431b-adf0-46eb364c5eb9/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp22-vod-ch.horizon.tv/shss/333f16d9-4c9c-466f-8ba2-fe1637266eaf/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp23-vod-ch.horizon.tv/shss/24e44d79-a511-4acb-b2d0-2ebb4ced2a99/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp23-vod-ch.horizon.tv/shss/260e2546-fa74-46f0-8a32-2049562b41eb/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp27-vod-ch.horizon.tv/shss/3a8efcf8-f6dd-4486-9844-eb839c138e7d/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp18-vod-ch.horizon.tv/shss/f2b1d178-3480-425f-994e-a4047a75ed80/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp8-vod-ch.horizon.tv/shss/d260a73d-3836-43a2-83b7-370413d2e362/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp3-vod-ch.horizon.tv/shss/b799f4bf-5d08-464c-8322-ab16a9d9abec/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp9-vod-ch.horizon.tv/shss/aa36d772-58d0-4ccc-a352-cb9a3eb94709/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp22-vod-ch.horizon.tv/shss/12c4733f-dca2-4a19-a3ab-1dc53d3a1bd0/3.ism/Manifest?start=0&end=-1&device=Orion-HSS",
                       @"http://wp22-vod-ch.horizon.tv/shss/277666d7-28a1-4e40-9617-15cec8d04294/3.ism/Manifest?start=0&end=-1&device=Orion-HSS",
                       @"http://wp22-vod-ch.horizon.tv/shss/af23c97d-3598-4b04-86d6-d7f05275b9e0/3.ism/Manifest?start=0&end=-1&device=Orion-HSS",
                       @"http://wp22-vod-ch.horizon.tv/shss/c5dfec18-13d5-4e9a-a89c-11abe210b244/3.ism/Manifest?start=0&end=-1&device=Orion-HSS",
                       @"http://wp6-vod-ch.horizon.tv/shss/66d1b699-4a42-4429-b7f4-9ca16c2d4d21/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS",
                       @"http://wp5-vod-ch.horizon.tv/shss/7a6e4a9f-0d0b-4925-aed7-05f2f320abb6/2.ism/Manifest?start=0&end=-1&device=Orion-Replay-HSS"];
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
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Manual HSS Asset";
            break;
            
        case 1:
            return @"LGI Lab Assets";
            break;
            
        case 2:
            return @"LGI CH Prod Assets";
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
            return 1;
            break;
            
        case 1:
            return 10;
            break;

        case 2:
            return 20;
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
        cell.textLabel.text = @"Add Custom Asset";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if( indexPath.section == 1 )
    {
        switch (indexPath.row ) {
            case 0:
                cell.textLabel.text = @"LGI Asset 1";
                break;
                
            case 1:
                cell.textLabel.text = @"LGI Asset 2";
                break;
                
            case 2:
                cell.textLabel.text = @"LGI Asset 3";
                break;
                
            case 3:
                cell.textLabel.text = @"LGI Asset 4";
                break;
                
            case 4:
                cell.textLabel.text = @"LGI Asset 5";
                break;
                
            case 5:
                cell.textLabel.text = @"LGI Asset 6";
                break;
                
            case 6:
                cell.textLabel.text = @"LGI Asset 7";
                break;
                
            case 7:
                cell.textLabel.text = @"LGI Asset 8";
                break;
                
            case 8:
                cell.textLabel.text = @"LGI Asset 9";
                break;

            case 9:
                cell.textLabel.text = @"LGI Asset 10";
                break;
                
            default:
                break;
        }
    }
    else if( indexPath.section == 2 )
    {
        if( indexPath.row < 14) {
            cell.textLabel.text = [NSString stringWithFormat:@"LGI Replay Asset %li",indexPath.row+1];
        }
        else if( indexPath.row < 19 ) {
            cell.textLabel.text = [NSString stringWithFormat:@"LGI VOD Asset %li",indexPath.row+1-14];
        }
        else {
            cell.textLabel.text = [NSString stringWithFormat:@"LGI Series Asset %li",indexPath.row+1-18];
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
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HSS Download"
                                                                       message:@"Please enter the information for your download:" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Manifest URL";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Asset ID";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Asset Description";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];

        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSArray* textFields = alert.textFields;
            UITextField* manifest = textFields[0];
            UITextField* assetID = textFields[1];
            UITextField* desc = textFields[2];
            if( manifest.text.length > 0 && assetID.text.length > 0 && desc.text.length > 0 )
            {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Adding item to queue...";

                [VirtuosoAsset assetWithAssetID:assetID.text
                                    description:desc.text
                                    manifestUrl:manifest.text
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
                                 NSLog(@"Finished parsing %@", parsedAsset);
                                 if( error != nil )
                                 {
                                     NSLog(@"Detected error creating new asset: %@",error);
                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }
                             }];
            }
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if( indexPath.section == 1 )
    {
        // All of these options are various error modes for test and example purposes.
        switch (indexPath.row) {
            case 0:
            {
                [VirtuosoAsset assetWithAssetID:@"LGI1"
                                    description:@"LGI Asset 1"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/16d5a3c7-5038-41d1-a308-df670bce2316/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI2"
                                    description:@"LGI Asset 2"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/9ef0602c-1861-4338-8a95-4131bddfee9c/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI3"
                                    description:@"LGI Asset 3"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/b152e010-0ca9-48c4-94c4-09b8904eba59/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI4"
                                    description:@"LGI Asset 4"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/6180b095-1620-4b53-9e39-6fe5dd0e08cb/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI5"
                                    description:@"LGI Asset 5"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/69f511c5-1ef7-4dfd-b725-c1e4d2ceae64/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI6"
                                    description:@"LGI Asset 6"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/a44d5ef3-8a04-405e-b8e8-990648daf454/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI7"
                                    description:@"LGI Asset 7"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/cc843a0d-a775-4ab5-b56c-878c1d15b8d2/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI8"
                                    description:@"LGI Asset 8"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/161ca21d-a5d7-44ca-b72f-d48c37f6f1d2/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                [VirtuosoAsset assetWithAssetID:@"LGI9"
                                    description:@"LGI Asset 9"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/171a0b98-f64c-424c-aef5-b2ebc6314cc6/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
                
            case 9:
            {
                [VirtuosoAsset assetWithAssetID:@"LGI10"
                                    description:@"LGI Asset 10"
                                    manifestUrl:@"http://wp1.lab2.vod.upclabs.com/shss/0daa6f5d-c1e3-439a-8916-28f6644dafb4/index.ism/Manifest?&device=Orion-Replay-HSS"
                            maximumVideoBitrate:LONG_LONG_MAX
                            maximumAudioBitrate:LONG_LONG_MAX
                                    publishDate:nil
                                     expiryDate:nil
                             assetDownloadLimit:-1
                                 enableFastPlay:NO
                                       userInfo:nil
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                 NSLog(@"Item is ready for download: %@",parsedAsset);
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
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
        // All of these options are various error modes for test and example purposes.
        NSString* assetID = @"";
        NSString* manifestURL = @"";
        NSString* desc = @"";
        
        if( indexPath.row < 14) {
            desc = [NSString stringWithFormat:@"LGI Replay Asset %li",indexPath.row+1];
            assetID = [NSString stringWithFormat:@"LGIPRODCHREPLAY-%li",indexPath.row+1];
            manifestURL = self.logCHProd[indexPath.row];
        }
        else if( indexPath.row < 19 ) {
            desc = [NSString stringWithFormat:@"LGI VOD Asset %li",indexPath.row+1-14];
            assetID = [NSString stringWithFormat:@"LGIPRODCHVOD-%li",indexPath.row+1-14];
            manifestURL = self.logCHProd[indexPath.row];
        }
        else {
            desc = [NSString stringWithFormat:@"LGI Series Asset %li",indexPath.row+1-18];
            assetID = [NSString stringWithFormat:@"LGIPRODCHSERIES-%li",indexPath.row+1-18];
            manifestURL = self.logCHProd[indexPath.row];
        }

        [VirtuosoAsset assetWithAssetID:assetID
                            description:desc
                            manifestUrl:manifestURL
                    maximumVideoBitrate:LONG_LONG_MAX
                    maximumAudioBitrate:LONG_LONG_MAX
                            publishDate:nil
                             expiryDate:nil
                     assetDownloadLimit:-1
                         enableFastPlay:NO
                               userInfo:nil
                     onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                         NSLog(@"Item is ready for download: %@",parsedAsset);
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:nil];
                         [self dismissViewControllerAnimated:YES completion:nil];
                     } onParseComplete:^(VirtuosoAsset *parsedAsset, NSError *error) {
                         NSLog(@"Finished parsing %@", parsedAsset);
                         if( error != nil )
                         {
                             NSLog(@"Detected error creating new asset: %@",error);
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }
                     }];
    }
}

@end
