//
//  BeaconsViewController.swift
//  Example15
//
//  Created by dev on 7/24/20.
//  Copyright © 2020 Penthera. All rights reserved.
//

import UIKit

class BeaconsViewController: UITableViewController {

    var beaconSections: [String] = []
    var beaconRowsBySection: [UInt:[String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Beacons"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.beaconSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let beaconRows = self.beaconRowsBySection[UInt(section)] else {
            return 0
        }
        
        return beaconRows.count;
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section < self.beaconSections.count)
        {
            return self.beaconSections[section]
        }
        
        return nil;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerLabel = UILabel()

        headerLabel.font = UIFont.boldSystemFont(ofSize:10.0)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.backgroundColor = .groupTableViewBackground
        headerLabel.textAlignment = .center
          
        headerLabel.sizeToFit()

        return headerLabel.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()

        headerLabel.font = UIFont.boldSystemFont(ofSize:10.0)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.backgroundColor = .groupTableViewBackground
        headerLabel.textAlignment = .center
          
        headerLabel.sizeToFit()

        return headerLabel
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell") else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "BeaconCell")
        }
        
        cell.textLabel?.font = UIFont(name: "Menlo", size: 8.0)
        cell.detailTextLabel?.font = UIFont(name: "Menlo", size: 8.0)
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.text = ""
        
        guard let beaconRows = self.beaconRowsBySection[UInt(indexPath.section)] else {
            return cell;
        }
        
        if indexPath.row < beaconRows.count
        {
            cell.detailTextLabel?.text = beaconRows[indexPath.row]
        }
        
        return cell
    }
    
     func setupBeacons(beaconsReported:[[String:Any]])
    {
        var currentSection:UInt = 0
        
        var lastAdInstance:UInt = 0
        var lastAdUUID:String = ""
        
        var currentBeacons:[String]? = nil
        
        for beaconInfo in beaconsReported
        {
            guard let currentAdInstance = beaconInfo["ads_instance"] as? UInt,
                  let currentAdUUID = beaconInfo["ads_UUID"] as? String else {
                continue;
            }
                      
            if currentAdInstance != lastAdInstance || currentAdUUID != lastAdUUID
            {
                // New section
                
                if currentBeacons != nil
                {
                    self.beaconRowsBySection[currentSection] = currentBeacons
                    
                    currentSection += 1
                }
                
                let adName = beaconInfo["ads_name"] as? String
                let adBreak = beaconInfo["ads_break"] as? UInt
                let adDurationSeconds = beaconInfo["ads_duration_seconds"] as? Double
                
                let headerText:String = "\(adName!) - \(adDurationSeconds!) seconds - Break \(adBreak!) - Instance \(currentAdInstance)"
                
                self.beaconSections.append(headerText)
                                
                currentBeacons = []
            }
            
            // Row info
            
            var detailText:String = ""
          
            let adEventName = beaconInfo["ads_event_name"] as? String
            let beaconData = beaconInfo["ads_beacon_data"] as? String
            let httpResponseCode = beaconInfo["httpResponseCode"] as? Int
            let adTimeOffset = beaconInfo["ads_time_offset"] as? Double
            let url = beaconInfo ["url"] as? String
            
            detailText += "      Event: \(adEventName!)\n"
            detailText += "     Beacon: \(beaconData!)\n"
            detailText += "Time Offset: \(adTimeOffset!)\n"
            detailText += "   Response: \(httpResponseCode!)\n"
            detailText += "        URL: \(url!)"
            
            currentBeacons?.append(detailText)
            
            lastAdInstance = currentAdInstance;
            lastAdUUID = currentAdUUID;
        }
        
        if currentBeacons != nil
        {
            self.beaconRowsBySection[currentSection] = currentBeacons
        }
        
        return
    }
}
