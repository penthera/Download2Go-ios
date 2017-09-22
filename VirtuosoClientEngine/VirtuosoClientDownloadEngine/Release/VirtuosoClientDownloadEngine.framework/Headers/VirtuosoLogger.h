/*!
 *  @header VirtuosoLogger
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
 *  @copyright (c) 2016 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VLOGGER
#define VLOGGER

#import <Foundation/Foundation.h>

#define VLog(level, fmt, ...) [VirtuosoLogger addDebugEvent:[NSString stringWithFormat:(@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__] atLevel:level]

#define INCLUDE_DEV_LOGGING 0

@class VirtuosoAsset;

/*!
 *  @typedef kVL_LoggingLevel
 *
 *  @abstract Log levels available to filter log output.  
 */
typedef NS_ENUM(NSInteger, kVL_LoggingLevel)
{
    kVL_LogError = 0,
    kVL_LogWarning = 1,
    kVL_LogInformation = 2,
    kVL_LogDebug = 3,
    kVL_LogVerbose = 4,
};

/*!
 *  @typedef VirtuosoDownloadEvent
 *
 *  @abstract Complete list of events that Virtuoso captures and delivers to the Backplane.
 *            You may use the "user custom" event for other events you wish to record.
 */
typedef NS_ENUM(NSInteger, kVL_LogEvent)
{
    /** The enclosing app has launched */
    kVLE_AppLaunch = 0,
    
    /** Virtuoso has queued a new VirtuosoAsset for download */
    kVLE_QueueForDownload = 1,
    
    /** Virtuoso has removed a VirtuosoAsset from the download queue */
    kVLE_FileRemovedFromQueue = 2,
    
    /** Virtuoso has begun to download a VirtuosoAsset */
    kVLE_DownloadStart = 3,
    
    /** Virtuoso successfully finished downloading a VirtuosoFile */
    kVLE_DownloadComplete = 4,
    
    /** Virtuoso detected an error during download */
    kVLE_DownloadError = 5,
    
    /** A VirtuosoAsset was deleted */
    kVLE_AssetDeleted = 6,
    
    /** A VirtuosoAsset reached the expired state */
    kVLE_FileExpired = 7,
    
    /** Virtuoso successfully synced with the Backplane */
    kVLE_SyncWithServer = 8,
    
    /** The enclosing app played a video asset */
    kVLE_PlayStart = 9,
    
    /** The enclosing app stopped playing a video asset */
    kVLE_PlayStop = 10,
    
    /** The User subscribed to a Feed */
    kVLE_Subscribe = 11,
    
    /** The User canceled a subscription to a Feed */
    kVLE_Unsubscribe = 12,
    
    /** The app either started the first time after installation, or is starting up after a remote wipe */
    kVLE_Reset = 13,
    
    /** An asset which had exceeded it's maximum error count has been reset and will retry download */
    kVLE_MaxErrorsReset = 14,
    
    /** The download limit imposed by the rules for either MDA or MAD has been reached and the asset with asset_id
        cannot be downloaded. */
    kVLE_DownloadLimitReached = 15,
};

/*!
 *  @typedef kVL_BearerType
 *
 *  @abstract Type of network the device was on when the log event was created.
 */
typedef NS_ENUM(NSInteger, kVL_BearerType)
{
    /** A wifi network */
    kVL_BearerWifi,
    
    /** A cellular network */
    kVL_BearerCellular,
    
    /** No network detected */
    kVL_BearerNone,
    
    /** Used for events that don't relate to network state */
    kVL_Invalid
};

extern NSString* _Nonnull kVDE_AssetDeletedByUser;
extern NSString* _Nonnull kVDE_AssetDeletedByRemote;
extern NSString* _Nonnull kVDE_AssetDeletedInternal;

/*!
 *  @constant kLoggerDataValueInvalid
 *
 *  @abstract A value to be used for numeric parameters when a value is not required.
 */
extern long long kLoggerDataValueInvalid;

/*!
 *  @discussion For those who wish to use their own logging system or report metrics to 
 *              non-Virtuoso locations/trackers. Virtuoso will send all log events to the registered 
 *              delegate if the VirtuosoLogger would have otherwise processed them.
 */
@protocol VirtuosoLoggerDelegate <NSObject>

@optional

/*!
 *  @abstract Reports that a tracked event was logged.
 *
 *  @param event The type of event
 *
 *  @param fileID The UUID of the relevant asset.  Nil for events that don't relate to a specific asset.
 *
 *  @param bearer The network type relating to the event.  kVL_Invalid for events that don't relate to 
 *                the network state.
 *
 *  @param data A numeric value semantically unique to the specific event.  Will be 0 when not required.
 *              Example: For the download-paused event, contains total bytes downloaded so far for this asset.
 */
- (void)virtuosoEventOccurred:(kVL_LogEvent)event
                      forFile:(nullable NSString*)fileID
                     onBearer:(kVL_BearerType)bearer
                     withData:(long long)data;

/*!
 *  @abstract Reports that a tracked event was logged.
 *
 *  @param event The type of event
 *
 *  @param fileID The UUID of the relevant asset.  Nil for events that don't relate to a specific asset.
 *
 *  @param bearer The network type relating to the event.  kVL_Invalid for events that don't relate to
 *                the network state.
 *
 *  @param data A string value semantically unique to the specific event.
 */
- (void)virtuosoEventOccurred:(kVL_LogEvent)event
                      forFile:(nullable NSString*)fileID
                     onBearer:(kVL_BearerType)bearer
               withStringData:(nullable NSString*)data;

/*!
 *  @abstract Reports on a custom event not tracked by the standard event list.
 *
 *  @param event An NSDictionary containing the logged event data
 */
- (void)virtuosoCustomEventOccurred:(nonnull NSDictionary*)event;

/*!
 *  @abstract Reports debug data.
 *
 *  @discussion For non-debug builds and when verbose console option is  off, Virtuoso won't send debug output 
 *              to the debugging console. Use this method to access log debug output.
 *
 *  @param data A string containing the debug event data
 *  @param level The severity level of the log item
 */
- (void)virtuosoDebugEventOccurred:(nonnull NSString*)data atLevel:(kVL_LoggingLevel)level;

@end


/*!
 *  @discussion A static package responsible for managing all Virtuoso logging.
 *
 *  @warning You must never instantiate an object of this type directly.
 *           Only the static methods provided with this interface should be used.
 *
 */
@interface VirtuosoLogger : NSObject

/**---------------------------------------------------------------------------------------
 * @name Startup And Configuration
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Enables/disables file-based logging.
 *
 *  @discussion If enabled, Virtuoso will save all logs to log.txt in the app's sandboxed Documents 
 *             directory. Default is NO.
 *
 *  @param enable Whether to enable file-based logging
 */
+ (void) enableLogsToFile:(Boolean)enable;

/*!
 *  @abstract Whether Virtuoso is currently logging to file
 *
 *  @return Whether Virtuoso is currently logging to file
 */
+ (Boolean)isLoggingToFile;

/*!
 *  @abstract Sets the log level for the Virtuoso logging system
 *
 *  @discussion In a debug build, this value is ignored and Virtuoso always sends all output to the console.
 *              In a release build, Virtuoso will only send debug log information to console for the chosen
 *              log level and lower.
 *
 *              Default is kVL_LogVerbose for debug builds and kVL_LogInformation for production builds.
 *
 *  @param level The filter level for log output
 */
+ (void) setLogLevel:(kVL_LoggingLevel)level;

/*!
 *  @abstract The current log filter level
 *
 *  @return The current log filter level
 */
+ (kVL_LoggingLevel)logLevel;

/**---------------------------------------------------------------------------------------
 * @name Event Log Filtering
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Sets all Virtuoso events as enabled
 *
 *  @discussion Virtuoso sends a variety of events to the Backplane for tracking.
 *              This method allows you to enable (or disable) all event logging with a single call.
*               By default, all event logging is disabled.
 *
 *  @param enabled Whether to enable all Backplane-tracked log events
 */
+ (void) setLoggingEnabledForAllEvents:(Boolean)enabled;

/*!
 *  @abstract Enables/disables logging for a specific event
 *
 *  @param enabled Whether to enable logging for this event
 *
 *  @param event The event
 */
+ (void) setLoggingEnabled:(Boolean)enabled forEvent:(kVL_LogEvent)event;

/*!
 *  @abstract Whether a particular Backplane-tracked event is enabled
 *
 *  @param event The event
 *
 *  @return Returns whether a particular Backplane-tracked event is enabled
 */
+ (Boolean) isLoggingEnabledForEvent:(kVL_LogEvent)event;

/**---------------------------------------------------------------------------------------
 * @name Manually Generated Events
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Adds a arbitrary logging event.
 *
 *  @param eventName The name of your custom log event
 *  @param eventData A string containing arbitrary data related to your log event
 */
+ (void) addCustomLogEvent:(nonnull NSString*)eventName withStringData:(nonnull NSString*)eventData;

/*!
 *  @abstract Adds a arbitrary logging event.
 *
 *  @param eventName The name of your custom log event
 *  @param eventData A long value containing arbitrary data related to your log event
 */
+ (void) addCustomLogEvent:(nonnull NSString*)eventName withNumericData:(long)eventData;

/*!
 *  @abstract Adds a debug event.
 *
 *  @discussion Virtuoso does not post these events to the Backplane. 
 *              However, Virtuoso will show them on the console if verbose console is enabled. 
 *              Virtuoso will write them to the log file, if file logging is enabled.
 *
 *  @param eventData A string containing arbitrary debug data for logging
 *  @param level     The log level this event is associated with
 */
+ (void) addDebugEvent:(nonnull NSString*)eventData atLevel:(kVL_LoggingLevel)level;


/*!
 *  @abstract Logs "expire" event for an asset
 *
 *  @discussion Virtuoso cannot always detect immediately when an asset has expired.  This method
 *              allows you to log this event.
 *
 *  @param asset The expired asset
 */
+ (void) logAssetExpired:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Logs "play" event for an asset
 *
 *  @discussion Virtuoso cannot automatically detect a 'play' event, since this occurs at the app 
 *              level, "above" Virtuoso. This method allows you to log the event.  
 *              Note that a "pause" event is equivalent to a stop event followed by a start event.
 *
 *  @param asset The played asset
 */
+ (void) logPlaybackStartedForAsset:(nonnull VirtuosoAsset*)asset;

/*!
 *  @abstract Logs "stop-play" event for an asset
 *
 *  @discussion Virtuoso cannot automatically detect a 'stop play' event, since this occurs at the app 
 *              level, "above" Virtuoso. This method allows you to log the event. 
 *              Note that a "pause" event is equivalent to a stop event followed by a start event.
 *
 *  @param asset The stopped asset
 *
 *  @param seconds The number of seconds the asset was played before it was stopped or paused
 *                 (e.g. play time since 'start' was reported)
 */
+ (void) logPlaybackStoppedForAsset:(nonnull VirtuosoAsset*)asset withSecondsSinceLastStart:(long long)seconds;


/**---------------------------------------------------------------------------------------
 * @name Log Monitoring
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Adds an object that follows the VirtuosoLoggerDelegate protocol to the delegate list.
 *
 *  @discussion If you add the same delegate twice, Virtuoso will ignore the second request.
  *
 *  @param delegate An object that follows the VirtuosoLoggerDelegate protocol
 */
+ (void) addDelegate:(nonnull id<VirtuosoLoggerDelegate>) delegate;

/*!
 *  @abstract Removes a delegate from the delegate list.
 *
 *  @param delegate An object to be removed from the delegate list
 */
+ (void) removeDelegate:(nonnull id<VirtuosoLoggerDelegate>) delegate;

/*!
 *  @abstract Returns a current list of logging delegates.
 *
 *  @return The current list of logging delegates.
 */
+ (nonnull NSArray*) delegates;

@end

#endif
