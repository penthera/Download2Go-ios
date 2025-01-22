//
//  SampleLoggingDelegate.m
//  Example1.5
//
//  Created by dev on 7/24/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

#import "SampleLoggingDelegate.h"

@implementation SampleLoggingDelegate


- (void)virtuosoConsoleLogLine:(nonnull NSString*)line atLevel:(kVL_LoggingLevel)level
{
    NSLog( @"virtuosoConsoleLogLine for line: %@", line);
}


- (void)virtuosoEventOccurred:(nonnull VirtuosoBaseEvent*)event
{
    NSLog( @"virtuosoEventOccurred for event: %@", [event jsonData]);
}

@end
