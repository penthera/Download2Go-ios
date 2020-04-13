//
//  CastDrmConfigDelegate.swift
//  Example8.2
//
//  Created by Penthera on 2/5/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class CastDrmConfigDelegate: NSObject, VirtuosoDrmConfigDelegate {
    
    let userID: String?
    let sessionID: String?
    let customerName: String?
    
    init?(_ userID: String?, sessionID: String?, customerName: String?) {
        guard let _ = userID else {
            return nil
        }
        guard let _ = sessionID else {
            return nil
        }
        guard let _ = customerName else {
            return nil
        }
        
        self.userID = userID;
        self.sessionID = sessionID;
        self.customerName = customerName;
    }
    
    func drmConfig(for asset: VirtuosoAsset) -> VirtuosoDrmConfig {
        let config = CastLabsDrmConfig()
         
        guard let user = userID else {
            print("userID has not been properly intiailzied.")
            return config
        }
        guard let session = sessionID else {
            print("sessionID has not been properly intiailzied.")
            return config
        }
        guard let customer = customerName else {
            print("customerName has not been properly intiailzied.")
            return config
        }
        config.clUserID = user
        config.clCustomerName = customer
        config.clSessionID = session
        
        return config
    }
    
    

}
