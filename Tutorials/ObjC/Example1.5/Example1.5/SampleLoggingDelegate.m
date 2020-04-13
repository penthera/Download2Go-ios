//
//  SampleLoggingDelegate.m
//  Example1.5
//
//  Created by dev on 7/24/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "SampleLoggingDelegate.h"

@implementation SampleLoggingDelegate

- (void)virtuosoEventOccurred:(kVL_LogEvent)event
forFile:(nullable NSString*)fileID
                     onBearer:(kVL_BearerType)bearer
                     withData:(long long)data
{
    NSLog(@"SampleLoggingDelete event: %@", [VirtuosoLogger eventTypeToString:event]);
}

- (void)virtuosoEventOccurred:(kVL_LogEvent)event
                      forFile:(nullable NSString*)fileID
                     onBearer:(kVL_BearerType)bearer
               withStringData:(nullable NSString*)data
{
    NSLog( @"SampleLoggingDelete  event: %@", [VirtuosoLogger eventTypeToString:event]);
}

- (void)virtuosoCustomEventOccurred:(nonnull NSDictionary*)eventDetails
{
    NSLog( @"SampleLoggingDelete for custom event: %@", eventDetails);
}

- (void)virtuosoDebugEventOccurred:(nonnull NSString*)data atLevel:(kVL_LoggingLevel)level
{
    NSLog( @"SampleLoggingDelete for data: %@", data);
}


@end
