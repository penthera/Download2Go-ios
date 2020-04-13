//
//  FairPlayDrmConfigDelegate.swift
//  Example8.3
//
//  Created by Penthera on 2/5/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class FairPlayDrmConfigDelegate: NSObject, VirtuosoDrmConfigDelegate {
    let authenticationXML: String?
    
    init?(_ xml: String?) {
        guard let _ = xml else {
            return nil
        }
        authenticationXML = xml;
    }
    
    func drmConfig(for asset: VirtuosoAsset) -> VirtuosoDrmConfig {
        let config = BuyDRMConfig()
         
        guard let xml = authenticationXML else {
            print("authenticationXML has not been properly intiailzied.")
            return config
        }
        config.authenticationXML = xml
        return config
    }
    
    

}
