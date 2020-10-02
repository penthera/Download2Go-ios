//
//  VirtuosoRefreshManager.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 7/6/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
*  @abstract Delegate interface that VirtuosoRefreshManager requires.
*
*  @discussion This delegate defines the interface that will be invoked by VirtuosoRefreshManager when processing background wake events.
*/
@protocol VirtuosoRefreshManagerDelegate <NSObject>

/*!
*  @abstract Invoked when background refresh should be performed. The callback will happen on a background thread. Do not attempt to update UI elements or otherwise use MainThread as the App user interface is not available when awakened for background processing.
*/
-(void)performRefresh;

@end

/*!
*  @abstract Manages background refreshs for Virtuoso SDK Clients.
*
*  @discussion This component can be used to wake the App from Background periodically to allow catalog updates in the background.
*
*  The App must be network connected and connected to power for the wake to happen. Must also enable "Background Processing" capablities and then add identifier "com.virtuoso.wake.refres" to info.plist setting "Permitted background task scheduler identifiers"
*
* Internally this component uses BGProcessingTask to schedule and then invoke the delegate. This capability is supported starting with iOS 13.  
*
*/
@interface VirtuosoRefreshManager : NSObject

/*!
*  @abstract Delegate that will be invoked during the background wake.
*/
@property (nonatomic, strong, readonly)id<VirtuosoRefreshManagerDelegate> _Nonnull delegate;

/*!
*  @abstract Wake interval in seconds for minimum interval before which the App should be awaked for background processing. iOS uses an undocumented set of heuristics for determining exactly when the App will be awaked. There is no guarantee provided by iOS for exactly when the App will be awakened after this minimum interval.
*/
@property (nonatomic, assign, readonly)NSTimeInterval wakeInterval;

/*!
 *  @abstract Creates an instance
 *
 *  @param delegate Delegate that will be called
 *
 *  @return Instance of this component, nil on failure.
 *
 */
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoRefreshManagerDelegate> _Nonnull)delegate;

/*!
*  @abstract Creates an instance
*
*  @param delegate Delegate that will be called
*
*  @param wakeInterval Wake interval specified in seconds. Must be greater than zero and less than a week.
*
*  @return Instance of this component, nil on failure.
*
*/
-(instancetype _Nullable)initWithDelegate:(id<VirtuosoRefreshManagerDelegate> _Nonnull)delegate wakeInterval:(NSTimeInterval)wakeInterval;

@end

NS_ASSUME_NONNULL_END
