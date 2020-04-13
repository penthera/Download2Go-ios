//
//  WidevineLicenseProcessingDelegate.swift
//  Example8.4
//
//  Created by Penthera on 2/6/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class WidevineLicenseProcessingDelegate: NSObject, VirtuosoLicenseProcessingDelegate {
    
    func extractCID(for asset: VirtuosoAsset, fromFairPlayRequest fpRequest: URL) -> String? {
        // IMPORTANT:
        // Custom code may be required to support this on your DRM implmentation
        print("Custom code may be required to support this on your DRM implmentation.")
        return nil
    }
    
    func prepareSPC(for asset: VirtuosoAsset, inLicenseRequest spc: Data) -> Data? {
        // IMPORTANT:
        // Custom code may be required to support this on your DRM implmentation
        print("Custom code may be required to support this on your DRM implmentation.")
        return spc
    }
    
    func extractCKC(for asset: VirtuosoAsset, inLicenseResponse response: Data) -> Data? {
        // IMPORTANT:
        // Custom code may be required to support this on your DRM implmentation
        print("Custom code may be required to support this on your DRM implmentation.")
        return response
    }
}
