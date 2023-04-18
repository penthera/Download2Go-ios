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
#import <VirtuosoClientDownloadEngine/VirtuosoPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVPlayer.h>
#import <VirtuosoClientDownloadEngine/VirtuosoEventHandler.h>
#import <VirtuosoClientDownloadEngine/VirtuosoEncryption.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSettings.h>
#import <VirtuosoClientDownloadEngine/VirtuosoLicenseManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSecureClock.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/VirtuosoDefaultAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/CastLabsAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAdsProvider.h>
#import <VirtuosoClientDownloadEngine/VirtuosoDownloadEngineNotificationsManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoBackplaneNotificationsManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSubscriptionNotificationsManager.h>
#import <VirtuosoClientDownloadEngine/VirtuosoAdsNotificationsManager.h>

#pragma mark
#pragma mark DRM Integrations
#pragma mark

#import <VirtuosoClientDownloadEngine/BuyDRMAVAssetResourceLoaderDelegate.h>
#import <VirtuosoClientDownloadEngine/CastLabsAVAssetResourceLoaderDelegate.h>

#pragma mark
#pragma mark Subscriptions
#pragma mark

#import <VirtuosoClientDownloadEngine/VirtuosoSubscriptionDataSource.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSubscriptionDefaultDataSource.h>
#import <VirtuosoClientDownloadEngine/VirtuosoSubscriptionManager.h>

#pragma mark
#pragma mark Common
#pragma mark

#import <VirtuosoClientDownloadEngine/VirtuosoLogger.h>

#endif
