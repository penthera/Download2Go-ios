//
//  BuyDrmSetup.swift
//  Example8.1
//
//  Created by Penthera on 2/5/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class BuyDrmSetup: NSObject {

    // DRM SETUP REQUIRED
    private var certificateUrl: String!
    private var licenseUrl: String!
    private var authenticationXml: String!

    init?(certificateUrl: String?, licenseUrl: String?, authXml: String?) {
        
        guard let _ = certificateUrl else { return nil }
        guard let _ = licenseUrl else { return nil }
        guard let _ = authXml else { return nil }

        self.certificateUrl = certificateUrl
        self.licenseUrl = licenseUrl
        self.authenticationXml = authXml
    }
    
    // Sample code showing how DRM might be configured.
    func configure() ->Bool {
        
        //
        // Local function used to resolve license manager delegate
        func createLicenseConfigurationDelegate() ->VirtuosoLicenseManagerDelegate? {
            
            // Class VirtuosoLicenseDelegateHelper is provided as a helper for implementing
            // delegate VirtuosoLicenseManagerDelegate. You are welcome to provide your own
            // implentation of VirtuosoLicenseManagerDelegate and not use VirtuosoLicenseDelegateHelper
            //
            // VirtuosoLicenseDelegateHelper will automatically handle the delegate methods
            // You need to provide VirtuosoLicenseConfiguration details and VirtuosoLicenseDelegateHelper
            // will use that to implement the delegate callbacks.
            //
            // There are two options for how you setup VirtuosoLicenseDelegateHelper:
            // 1) Provide one unique instance of VirtuosoLicenseConfiguration for each unique AssetID.
            // 2) Proide one instance of VirtuosoLicenseConfiguration which is then used for all Assdets
            //
            // If you need to customize the parameters VirtuosoLicenseConfiguration for individual Assets,
            // you can do that using the following:
            // delegate.addLicense(<#T##config: VirtuosoLicenseConfiguration##VirtuosoLicenseConfiguration#>, forAssetID: <#T##String#>)
            //
            // If the parameters for VirtuosoLicenseConfiguration apply uniformly to all of your Assets,
            // you can provide a single instance as follows:
            // delegate.addLicense(<#T##config: VirtuosoLicenseConfiguration##VirtuosoLicenseConfiguration#>)
            
            let delegate = VirtuosoLicenseDelegateHelper()

            // One of the following calls is required for this code to work.
            // delegate.addLicense(<#T##config: VirtuosoLicenseConfiguration##VirtuosoLicenseConfiguration#>)
            // delegate.addLicense(<#T##config: VirtuosoLicenseConfiguration##VirtuosoLicenseConfiguration#>, forAssetID: <#T##String#>)
            
            if (!delegate.isConfigured()) {
                // IMPORTANT
                // Code will fail here until you uncomment one of the above lines and initialize by adding a license.
                print("Code will fail here until you uncomment one of the above lines and initialize by adding a license.")
                return nil
            }
            
            return delegate
        }

        VirtuosoLicenseManager.downloadClientAppCertificate(fromURL: self.certificateUrl, for: .vlm_FairPlay)
        VirtuosoLicenseManager.setLicenseServerURL(self.licenseUrl, for: .vlm_FairPlay)
        
        guard let delegate = createLicenseConfigurationDelegate() else {
            print("failed to initialize VirtuosoLicenseManager delegate")
            return false
        }
        
        VirtuosoLicenseManager.setDelegate(delegate)
        
        VirtuosoLicenseManager.register(BuyDRMAVAssetResourceLoaderDelegate.self)
        
        guard let drmConfig = BuyDrmConfigDelegate(self.authenticationXml) else {
            print("failed to initialize BuyDrmConfigDelegate")
            return false
        }
        
        BuyDRMAVAssetResourceLoaderDelegate.setDrmConfig(drmConfig)
        return true
    }

}
