//
//  VirtuosoEngineStatusInfo.h
//  VirtuosoClientDownloadEngine
//
//  Created by Penthera on 2/20/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract A convenience class to define the various possible
 *            reasons the download engine might be blocked.
 */
@interface VirtuosoEngineStatusInfo : NSObject

/*!
 *  @abstract Whether current network state permits downloading
 */
@property (nonatomic, assign)Boolean isNetworkOK;

/*!
 *  @abstract Whether disk usage state permits downloading
 */
@property (nonatomic, assign)Boolean isDiskOK;

/*!
 *  @abstract Whether out of memory occured
 */
@property (nonatomic, assign)Boolean isMemoryOK;


/*!
 *  @abstract Whether queue state permits downloading
 */
@property (nonatomic, assign)Boolean isQueueOK;

/*!
 *  @abstract Whether account-level business rules permit downloading
 */
@property (nonatomic, assign)Boolean isAccountOK;

/*!
 *  @abstract Whether the Virtuoso SDK license is currently valid
 */
@property (nonatomic, assign) Boolean authenticationOK;


@end

NS_ASSUME_NONNULL_END
