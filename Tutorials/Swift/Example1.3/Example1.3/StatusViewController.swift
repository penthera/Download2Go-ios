//
//  StatusViewController.swift
//  Example2
//
//  Created by Penthera on 1/23/19.
//  Copyright © 2019 penthera. All rights reserved.
//

import UIKit

//
// Overview:
// This view is best opened during a download. It will update as the download happens,
// reporting bandwidth, disk usage, and status as the download process runs.
//
class StatusViewController: UITableViewController {
    
    private enum Constants {
        static let RowCount = 10
        static let CellIdentifier = "Cell"
    }

    // Important:
    // This object connects the view with Engine notifications. This view implements the
    // required delegate methods for VirtuosoDownloadEngineNotificationManager. This methods
    // are called as the Engine state changes and download is processing.
    private var downloadEngineNotifications: VirtuosoDownloadEngineNotificationManager!

    private var formatter: DateFormatter?;
    private var engineStatus :VirtuosoEngineStatusInfo?;
    
    // Important:
    // The following properties are updated as the Engine delegate (downloadEngineNotifications) is notified
    var usedStorage = "0 MB"
    var downloadBandWidth = "0 MBps"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.formatter = DateFormatter()
        self.formatter?.timeStyle = .medium
        self.formatter?.dateStyle = .medium
        
        title = "Status"
        downloadEngineNotifications = VirtuosoDownloadEngineNotificationManager.init(delegate: self)
        
        self.updateStatusInfo()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constants.RowCount
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Engine Status"
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
        
        switch indexPath.section {
        case 0:
            renderEngineStatus(cell, indexPath: indexPath)
            
        default:
            cell.textLabel?.text = "unhandled-section"
            cell.detailTextLabel?.text = ""
            break
        }
        return cell
    }
    
    // Important:
    // Shows how to fetch Engine status and then demonstrates what that status means.
    func renderEngineStatus(_ cell : UITableViewCell, indexPath : IndexPath) {
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "SDK Version"
            cell.detailTextLabel?.text = "\(VirtuosoDownloadEngine.versionString())"
        case 1:
            cell.textLabel?.text = "Engine Status"
            cell.detailTextLabel?.text = engineStatusString()
        case 2:
            cell.textLabel?.text = "Network Status"
            cell.detailTextLabel?.text = engineStatus?.isNetworkOK ?? false ? "OK" : "Blocked"
        case 3:
            cell.textLabel?.text = "Storage Status"
            cell.detailTextLabel?.text = engineStatus?.isDiskOK ?? false ? "OK" : "Blocked"
        case 4:
            cell.textLabel?.text = "Disk Usage"
            cell.detailTextLabel?.text = usedStorage
        case 5:
            cell.textLabel?.text = "Download Queue"
            cell.detailTextLabel?.text = engineStatus?.isQueueOK ?? false ? "OK" : "Blocked"
        case 6:
            cell.textLabel?.text = "Account Status"
            cell.detailTextLabel?.text = engineStatus?.isAccountOK ?? false ? "OK" : "Blocked"
        case 7:
            cell.textLabel?.text = "Authentication Status"
            cell.detailTextLabel?.text = engineStatus?.authenticationOK ?? false ? "OK" : "Blocked"
        case 8:
            cell.textLabel?.text = "Download Band Width"
            cell.detailTextLabel?.text = downloadBandWidth
        case 9:
            cell.textLabel?.text = "Secure Time"
            cell.detailTextLabel?.text = self.formatSecureDate()
            
        default:
            cell.textLabel?.text = "unhandled-engine-status"
            cell.detailTextLabel?.text = ""
            break
        }
    }
    
    // Important:
    // Penthera provides a secure clock. This method shows how to access it
    func formatSecureDate() -> String {
        guard let formatter = self.formatter else { return "" }
        guard let date = VirtuosoSecureClock.instance().secureDate else { return "" }
        return formatter.string(from: date)
    }
    
    func engineStatusString() -> String {
        switch VirtuosoDownloadEngine.instance().status {
        case .vde_Idle:
            return "Idle"
        case .vde_Errors:
            return "Blocked(Errors)"
        case .vde_Blocked:
            return "Blocked on Environment"
        case .vde_Disabled:
            return "Disabled"
        case .vde_Downloading:
            return "Downloading"
        case .vde_AuthenticationFailure:
            return "Blocked on License"
        default:
            return ""
        }
    }
    
    /*
     *  This method is called upon receipt of all download-related notifications.
     *  It is called fairly frequently, and since we're querying on overall file storage
     *  statistics, that might take a short while, so we'll pass off the method calls and
     *  calculations to a background thread and then update the UI in the main thread.  These
     *  methods won't take a great deal of time, but due to the frequency of the calls we are
     *  making in THIS example, doing it this way prevents choppiness in the UI.
     */
    func updateStatusInfo() {
        DispatchQueue.global().async {
            self.engineStatus = VirtuosoDownloadEngine.instance().engineStatusInfo;
            let used = VirtuosoAsset.storageUsed()/1024/1024
            let kbps = VirtuosoDownloadEngine.instance().downloadBandwidthString
            DispatchQueue.main.async {
                self.usedStorage = String(format: "%qi MB", used)
                if (kbps.count > 0) {
                    self.downloadBandWidth = kbps
                }
                self.tableView.reloadData()
            }
        }
    }
}

// Important:
// This extension implements the required methods for VirtuosoDownloadEngineNotificationsDelegate.
// There are additional optional methods which are not shown here.
extension StatusViewController: VirtuosoDownloadEngineNotificationsDelegate
{
    func downloadEngineDidStartDownloadingAsset(_ asset: VirtuosoAsset) {
        updateStatusInfo()
    }
    
    func downloadEngineProgressUpdated(for asset: VirtuosoAsset) {
        updateStatusInfo()
    }
    
    func downloadEngineProgressUpdatedProcessing(for asset: VirtuosoAsset) {
        updateStatusInfo()
    }
    
    func downloadEngineDidFinishDownloadingAsset(_ asset: VirtuosoAsset) {
        updateStatusInfo()
    }
    
    func downloadEngineStatusChange(_ status: kVDE_DownloadEngineStatus) {
        updateStatusInfo()
    }
}
