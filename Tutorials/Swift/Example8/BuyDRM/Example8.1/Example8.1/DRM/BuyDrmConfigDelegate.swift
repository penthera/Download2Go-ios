//
//  BuyDrmConfigDelegate.swift
//  Example8.1
//
//  Created by Penthera on 2/5/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

//
// This is an open source example
// of a minimal implementation for what a BuyDRM abstraction might look like.
//
class BuyDrmConfigDelegate: NSObject, VirtuosoDrmConfigDelegate {
    
    let authenticationXML: String? // required by BuyDRM
    
    init?(_ xml: String?) {
        guard let _ = xml else {
            return nil
        }
        authenticationXML = xml;
    }
    
    // IMPORTANT:
    // Creates an instance. Not sure why Asset is being provided,
    // there is no direct example for why we want to do that.
    func drmConfig(for asset: VirtuosoAsset) -> VirtuosoDrmConfig {
        let config = BuyDRMConfig()
         
        guard let xml = authenticationXML else {
            print("authenticationXML has not been properly intiailzied.")
            return config
        }
        config.authenticationXML = xml
        
        // WTF - is this all this thing needs?
        
        return config
    }

}
