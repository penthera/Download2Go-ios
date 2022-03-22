/*!
 *  @header Virtuoso Client Download Engine
 *
 *  PENTHERA CONFIDENTIAL
 *
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VirtuosoClientDownloadEngine_Master_h
#define VirtuosoClientDownloadEngine_Master_h

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
//! Project version number for VirtuosoClientDownloadEngine.
FOUNDATION_EXPORT double VirtuosoClientDownloadEngineVersionNumber;

//! Project version string for VirtuosoClientDownloadEngine.
FOUNDATION_EXPORT const unsigned char VirtuosoClientDownloadEngineVersionString[];
#endif

#pragma mark
#pragma mark Downloads
#pragma mark

#import <VirtuosoClientDownloadEngine/VirtuosoConstants.h>
#import <VirtuosoClientDownloadEngine/VirtuosoNotifications.h>
#import <VirtuosoClientDownloadEngine/VirtuosoDownloadEngine.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAncillaryFile.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+SegmentedVideo.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+HLS.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+HSS.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAsset+DASH.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientHTTPServer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoDevice.h>
#import <VirtuosoClientDownloadEngine/VirtuosoEventHandler.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoEncryption.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSettings.h>
#import <VirtuosoClientDownloadEngine/VirtuosoLicenseManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSecureClock.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/VirtuosoDefaultAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/VirtuosoLicenseDefaultDelegate.h>

#import <VirtuosoClientDownloadEngine/PlayAssureManager.h>
#import <VirtuosoClientDownloadEngine/PlayAssureConfig.h>
#import <VirtuosoClientDownloadEngine/PlayAssureStatusDelegate.h>
#import <VirtuosoClientDownloadEngine/PlayAssurePlayerViewController.h>

#import <VirtuosoClientDownloadEngine/VirtuosoEngineConfig.h>

#import <VirtuosoClientDownloadEngine/VirtuosoAdsProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAdsClientProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientAdsPlaybackProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientAdInfo.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientAdMedia.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientAdTracking.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAdsServerProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoGoogleAdsClientProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoGoogleAdsServerProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoFreewheelAdsClientProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoVerizonAdsServerProvider.h>

#import <VirtuosoClientDownloadEngine/VirtuosoDownloadEngineNotificationsManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoBackplaneNotificationsManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAdsNotificationsManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAssetConfig.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSettingsBase.h>

#import <VirtuosoClientDownloadEngine/VirtuosoPlaylistManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlaylist.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlaylistItem.h>
#import <VirtuosoClientDownloadEngine/VirtuosoPlaylistConfig.h>
#import <VirtuosoClientDownloadEngine/VirtuosoEngineStatusInfo.h>

#pragma mark
#pragma mark DRM Integrations
#pragma mark

#import <VirtuosoClientDownloadEngine/BuyDRMAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/CastLabsAVAssetResourceLoaderDelegate.h>

#pragma mark
#pragma mark Common
#pragma mark

#import <VirtuosoClientDownloadEngine/VirtuosoLogger.h>

/*
#import <VirtuosoClientDownloadEngine/VirtuosoBaseEvent.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAssetEvent.h>
#import <VirtuosoClientDownloadEngine/AppLaunch.h>
#import <VirtuosoClientDownloadEngine/QueueForDownload.h>
#import <VirtuosoClientDownloadEngine/AssetRemovedFromQueue.h>
#import <VirtuosoClientDownloadEngine/DownloadStart.h>
#import <VirtuosoClientDownloadEngine/DownloadComplete.h>
#import <VirtuosoClientDownloadEngine/DownloadError.h>
#import <VirtuosoClientDownloadEngine/DownloadWarning.h>
#import <VirtuosoClientDownloadEngine/MaxErrorReset.h>
#import <VirtuosoClientDownloadEngine/AssetDelete.h>
#import <VirtuosoClientDownloadEngine/AssetExpire.h>
#import <VirtuosoClientDownloadEngine/PlayStart.h>
#import <VirtuosoClientDownloadEngine/PlayStop.h>
#import <VirtuosoClientDownloadEngine/Reset.h>
#import <VirtuosoClientDownloadEngine/DownloadLimitReached.h>
#import <VirtuosoClientDownloadEngine/PlaybackInitiated.h>
*/

#endif
