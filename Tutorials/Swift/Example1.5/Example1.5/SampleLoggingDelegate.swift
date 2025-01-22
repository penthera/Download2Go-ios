//
//  SampleLoggingDelegate.swift
//  Example1.5
//
//  Created by Penthera on 7/24/19.
//  Copyright © 2019 Penthera. All rights reserved.
//

import UIKit

class SampleLoggingDelegate: NSObject,  VirtuosoLoggerDelegate {

    func virtuosoEventOccurred(_ event: VirtuosoBaseEvent) {
        print("virtuosoConsoleLogLine event: \(event.jsonData())")
    }
    
    func virtuosoConsoleLogLine(_ line: String, at level: kVL_LoggingLevel) {
        print("virtuosoConsoleLogLine line: \(line)")
    }
    
}


