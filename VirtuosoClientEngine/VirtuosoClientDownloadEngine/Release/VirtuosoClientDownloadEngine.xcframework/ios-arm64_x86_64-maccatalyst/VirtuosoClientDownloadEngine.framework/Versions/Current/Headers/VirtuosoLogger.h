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
 *  @copyright (c) 2019 Penthera Inc. All Rights Reserved.
 *
 */

#ifndef VLOGGER
#define VLOGGER

#import <Foundation/Foundation.h>

#define INCLUDE_DEV_LOGGING 0

@class VirtuosoAsset;
@class VirtuosoBaseEvent;

/*!
 *  @typedef kVL_LoggingLevel
 *
 *  @abstract Log levels available to filter log output.  
 */
typedef NS_ENUM(NSInteger, kVL_LoggingLevel)
{
    /** Only log errors */
    kVL_LogError = 0,
    
    /** Log errors and warnings */
    kVL_LogWarning = 1,
    
    /** Log errors, warnings, and information */
    kVL_LogInformation = 2,
    
    /** Log errors, warnings, information, and debug */
    kVL_LogDebug = 3,
    
    /** Full logging */
    kVL_LogVerbose = 4,
};

/*!
 *  @typedef kVL_BearerType
 *
 *  @abstract Type of network the device was on when the log event was created.
 */
typedef NS_ENUM(NSInteger, kVL_BearerType)
{
    /** A wifi network */
    kVL_BearerWifi = 2,
    
    /** A cellular network */
    kVL_BearerCellular = 1,
    
    /** No network detected */
    kVL_BearerNone = 0,
    
    /** Used for events that don't relate to network state */
    kVL_Invalid = -1
};

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
 *  @param event An object with base type VIrtuosoBaseEvent.  The event itself may be any one of the classes
 *              derived from VirtuosoBaseEvent.
 */
- (void)virtuosoEventOccurred:(nonnull VirtuosoBaseEvent*)event;

/*!
 *  @abstract Reports console logs
 *
 *  @discussion For non-debug builds and when verbose console option is  off, Virtuoso won't send debug output 
 *              to the console. Use this method to access all console log output.
 *
 *  @param line NSString containing the console log line
 *  @param level The severity level of the log item
 */
- (void)virtuosoConsoleLogLine:(nonnull NSString*)line atLevel:(kVL_LoggingLevel)level;

@end


/*!
 *  @discussion A static package responsible for managing all Virtuoso logging.
 *
 *  @warning You must never instantiate an object of this type directly.
 *           Only the static methods provided with this interface should be used.
 *
 */
@interface VirtuosoLogger : NSObject

/*!
 *  @abstract Class property to globally enable / disable Virtuoso logging.
 *
 *  @discussion Global Logging enable switch.
 *              Examples:
 *                  VirtuosoLogger.enable = true;  // enables logging
 *                  VirtuosoLogger.enable = false; // disables logging
 *
 *              Default is true
 *              This setting does not persist across App restarts.
 *              Recommend setting in AppDelegate as early as possible if disable is required.
 */
@property (nonatomic, assign, class)Boolean enable;

/*!
 *  @abstract Class property to globally enable / disable Backplane logging.
 *
 *  @discussion Global Backplane logging
 *              Examples:
 *                  VirtuosoLogger.backplaneLoggingEnabled = true;  // enables logging
 *                  VirtuosoLogger.backplaneLoggingEnabled = false; // disables logging
 *
 *              Default is true
 *              This setting persist's across App restarts.
 *              Recommend setting in AppDelegate as early as possible if disable is required.
 */
@property (nonatomic, assign, class)Boolean backplaneLoggingEnabled;

/*!
 *  @abstract Class property to globally enable / disable Proxy logging.
 *
 *  @discussion Global Proxy logging
 *              Examples:
 *                  VirtuosoLogger.proxyLoggingEnabled = true;  // enables logging
 *                  VirtuosoLogger.proxyLoggingEnabled = false; // disables logging
 *
 *              Default is true
 *              This setting persist's across App restarts.
 *              Recommend setting in AppDelegate as early as possible if disable is required.
 */
@property (nonatomic, assign, class)Boolean proxyLoggingEnabled;

/*!
 *  @abstract Class property to globally enable / disable Stream Assured logging.
 *
 *  @discussion Global Proxy logging
 *              Examples:
 *                  VirtuosoLogger.playAssureLoggingEnabled = true;  // enables logging
 *                  VirtuosoLogger.playAssureLoggingEnabled = false; // disables logging
 *
 *              Default is false
 *              This setting persist's across App restarts.
 *              Recommend setting in AppDelegate as early as possible if disable is required.
 */
@property (nonatomic, assign, class)Boolean playAssureLoggingEnabled;



/*!
 *  @abstract Queue used to post Logger delegate notifications. Default is MainThread.
 *
 *  @discussion If you need Notifications on a different thread from the default (MainThread), set
 *              this class property with the NSOperationQueue you want to receive Logger delegate notifications.
 */
@property (nonatomic, strong, class)NSOperationQueue* _Nonnull notificationQueue;

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
 *              Default is kVL_LogVerbose for debug builds and kVL_LogWarning for production builds.
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
 * @name Manually Generated Events
 *  ---------------------------------------------------------------------------------------
 */

/*!
 *  @abstract Logs "expire" event for an asset
 *
 *  @discussion Virtuoso cannot always detect immediately when an asset has expired.  This method
 *              allows you to log this event.
 *
 *  @param asset The expired asset
 */
+ (void) logAssetExpired:(nonnull VirtuosoAsset*)asset;

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
