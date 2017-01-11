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

#import "VirtuosoMoviePlayerViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+HLS.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+HSS.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayerViewController.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

NSString* kMoviePlayerDidExitNotification = @"kMoviePlayerDidExit";

@interface AVPlayerVirtuosoViewController : VirtuosoPlayerViewController<VirtuosoAVAssetResourceLoaderDelegateErrorHandler>
{
    
}
@end

@implementation AVPlayerVirtuosoViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMoviePlayerDidExitNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self play];
    
    // Redirect errors from FairPlay licensing here so we can handle reporting errors to the user.
    AVURLAsset* asset = (AVURLAsset*)self.playerView.player.currentItem.asset;
    if( [[asset.resourceLoader.delegate class]conformsToProtocol:@protocol(VirtuosoAVAssetResourceLoaderDelegate)] )
    {
        id<VirtuosoAVAssetResourceLoaderDelegate> loader = (id<VirtuosoAVAssetResourceLoaderDelegate>)asset.resourceLoader.delegate;
        loader.errorHandler = self;
    }
}

- (void)resourceLoaderDelegate:(id<VirtuosoAVAssetResourceLoaderDelegate>)delegate generatedError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc]initWithTitle:@"License Error"
                                   message:@"An error was encountered playing this content.  Please try again later."
                                  delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    });
}

@end

@interface VirtuosoMoviePlayerViewController ()

@end

@implementation VirtuosoMoviePlayerViewController

+ (UIViewController*)playerForAssetType:(kVDE_AssetType)assetType
{
    if( assetType == kVDE_AssetTypeHLS || assetType == kVDE_AssetTypeNonSegmented || assetType == kVDE_AssetTypeDASH )
    {
        NSLog(@"Returning AVPlayerVirtuosoViewController");
        return [[AVPlayerVirtuosoViewController alloc]init];
    }
    return nil;
}

+ (UIViewController*)playerForAsset:(VirtuosoAsset*)asset withURL:(NSURL*)url
{
    if( [url.absoluteString rangeOfString:@".m3u8"].location != NSNotFound || // HLS or MP4 or DASH
        [url.absoluteString rangeOfString:@".mp4"].location != NSNotFound ||
        [url.absoluteString rangeOfString:@".mpd"].location != NSNotFound )
    {
        NSLog(@"Returning AVPlayerVirtuosoViewController");
        AVPlayerVirtuosoViewController* newPlayer = [[AVPlayerVirtuosoViewController alloc]init];
        
        if( url != nil )
        {
            newPlayer.asset = asset;
            newPlayer.contentURL = url;
            newPlayer.allowsExternalPlayback = YES;
        }
        return newPlayer;
    }
    return nil;
}

@end
