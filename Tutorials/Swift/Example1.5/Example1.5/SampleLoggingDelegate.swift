//
//  SampleLoggingDelegate.swift
//  Example1.5
//
//  Created by Penthera on 7/24/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

class SampleLoggingDelegate: NSObject,  VirtuosoLoggerDelegate {

    func virtuosoCustomEventOccurred(_ event: [AnyHashable : Any]) {
        // Do something with the event
        print("Logging Delegate called with event: \(event)")
    }
    
    func virtuosoDebugEventOccurred(_ data: String, at level: kVL_LoggingLevel) {
        // Do something with the event
        print("Logging Delegate called with data: \(data)")
    }
    
    func virtuosoEventOccurred(_ event: kVL_LogEvent, forFile fileID: String?, on bearer: kVL_BearerType, withData data: Int64) {
        // Do something with the event
        print("Logging Delegate called with event: \(VirtuosoLogger.eventType(toString: event))")
    }
    
    func virtuosoEventOccurred(_ event: kVL_LogEvent, forFile fileID: String?, on bearer: kVL_BearerType, withStringData data: String?) {
        // Do something with the event
        print("Logging Delegate called with event: \(VirtuosoLogger.eventType(toString: event))")
    }
    
}


