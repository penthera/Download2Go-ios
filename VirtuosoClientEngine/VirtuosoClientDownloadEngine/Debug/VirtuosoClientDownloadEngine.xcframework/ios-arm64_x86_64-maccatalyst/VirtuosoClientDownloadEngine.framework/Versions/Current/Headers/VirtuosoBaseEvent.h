//
//  VirtuosoBaseEvent.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 11/4/21.
//  Copyright © 2021 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract Defines types of analytics events emitted by Penthera SDK
 *
 *  @discussion This enum defines the various analytics events emitted by Penthera SDK
 *
 */
typedef NS_ENUM(NSInteger, kVL_LogEventType)
{
    /** The enclosing app has launched */
    kVL_AppLaunch = 1,
    
    /** Virtuoso has queued a new VirtuosoAsset for download */
    kVL_QueueForDownload = 2,
    
    /** Virtuoso has removed a VirtuosoAsset from the download queue */
    kVL_AssetRemovedFromQueue = 3,
    
    /** Virtuoso has begun to download a VirtuosoAsset */
    kVL_DownloadStart = 4,
    
    /** Virtuoso successfully finished downloading a VirtuosoFile */
    kVL_DownloadComplete = 5,
    
    /** Virtuoso detected an error during download */
    kVL_DownloadError = 6,

    /** Virtuoso detected a warning during download */
    kVL_DownloadWarning = 7,

    /** An asset which had exceeded it's maximum error count has been reset and will retry download */
    kVL_MaxErrorsReset = 8,

    /** A VirtuosoAsset was deleted */
    kVL_AssetDeleted = 9,
    
    /** A VirtuosoAsset reached the expired state */
    kVL_AssetExpired = 10,
        
    /** The enclosing app played a video asset */
    kVL_PlayStart = 11,
    
    /** The enclosing app stopped playing a video asset */
    kVL_PlayStop = 12,

    /** The app either started the first time after installation, or is starting up after a remote wipe */
    kVL_Reset = 13,

    /** The download limit imposed by the rules for either MDA or MAD has been reached and the asset with asset_id
        cannot be downloaded. */
    kVL_DownloadLimitReached = 14,

    /** Generated the first time SDK detects the asset has been played. */
    kVL_PlaybackInitiated = 15,
};


const static int UNUSED_VALUE = -42424242;

/*!
 *  @abstract Base class for Virtuoso Analytics Events
 *  @discussion Base class for Virtuoso Analytics Events
 *
 */
@interface VirtuosoBaseEvent : NSObject<NSCoding>

/*!
 *  @abstract Event ID.
 *
 */
@property (nonatomic,readonly) NSInteger event;

/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) NSUInteger timestamp;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) NSInteger application_state;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) NSUInteger device_created;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) NSUInteger user_created;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) NSInteger platform;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) NSInteger bearer;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly) Boolean simulator;

/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* uuid;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* user_id;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* device_type;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* operating_system;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* device_id;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* external_device_id;
/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
@property (nonatomic,readonly,nonnull) NSString* client_version;

/*!
 *  @abstract Penthera VirtuosoError domain
 *
 */
-(NSDictionary* __nonnull)jsonData;

@end


/*!
 *  @abstract Defines types of custom events emitted by Penthera SDK
 *
 *  @discussion This enum defines the various custom events emitted by Penthera SDK
 *
 */
typedef NS_ENUM(NSInteger, kVL_CustomLogEventType)
{
    /** Reserved slot for first custom event  */
    kVL_FirstCustomLogEvent = 100,
    
    /** Download requested event */
    kVL_DownloadRequested = 101,
    
    /** Download status event */
    kVL_DownloadStatus = 102,
    
    /** Download transition to background event */
    kVL_DownloadTransitionBackground = 103,
    
    /** Download transition to foreground event */
    kVL_DownloadTransitionForeground = 104,
    
    /** Fastplay triggered event */
    kVL_FastPlayTriggered = 105,
    
    /** FastPlay enabled event */
    kVL_FastPlayEnabled = 106,
    
    /** FastPlay initiated event */
    kVL_FastPlayInitiated = 107,
    
    /** General Error event */
    kVL_GeneralError = 108,
    
    /** SDK Exception event */
    kVL_SdkException = 109,
    
    /** Play session stats event */
    kVL_PlaySessionStats = 110,
    
    /** Ads refresh event */
    kVL_AdsRefresh = 111,
    
    /** Ads download complete event */
    kVL_AdsDownloadComplete = 112,
    
    /** Ads beacons reported event */
    kVL_AdsBeaconsReported = 113,
};


NS_ASSUME_NONNULL_END
