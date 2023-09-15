//
//  StatusViewController.swift
//  Example2
//
//  Created by Penthera on 1/23/19.
//  Copyright © 2019 penthera. All rights reserved.
//

import UIKit

enum PerformanceSettings : Int {
    case taskRefillLimit
    case taskRefillSize
    case timeout
    case maxHTTPConnections
    case maxPackagerSegments
    case backgroundSetupTime
    case headroom
    case maxStorage
    case enableIFrames
    case cellDownload
    case proxyLogging
    case backplaneLogging
    case itemCount
}

typealias TextValidationClosure = (String?) -> Void
typealias BooleanValidationClosure = (Bool) -> Void

//
// Overview:
// This view is best opened during a download. It will update as the download happens,
// reporting bandwidth, disk usage, and status as the download process runs.
//
class StatusViewController: UITableViewController {
    
    private enum Constants {
        static let CellIdentifier = "Cell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PerformanceSettings.itemCount.rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case PerformanceSettings.taskRefillLimit.rawValue:
                cell.textLabel?.text = "Task Refill Limit"
                cell.detailTextLabel?.text = "\(instance.integer(forKey: "VFM_TaskRefillLimit"))"
            case PerformanceSettings.taskRefillSize.rawValue:
                cell.textLabel?.text = "Task Refill Size"
                cell.detailTextLabel?.text = "\(instance.integer(forKey: "VFM_TaskRefillSize"))"
            case PerformanceSettings.timeout.rawValue:
                cell.textLabel?.text = "Network Timeout"
                cell.detailTextLabel?.text = "\(instance.networkTimeout.description)"
            case PerformanceSettings.maxHTTPConnections.rawValue:
                cell.textLabel?.text = "Max HTTP Connections"
                cell.detailTextLabel?.text = "\(instance.integer(forKey: "VFM_MaxHTTPConn"))"
            case PerformanceSettings.maxPackagerSegments.rawValue:
                cell.textLabel?.text = "Max Packager Segments"
                cell.detailTextLabel?.text = "\(instance.integer(forKey: "VFM_MaxPackagerSegments"))"
            case PerformanceSettings.backgroundSetupTime.rawValue:
                cell.textLabel?.text = "Background Setup Time"
                cell.detailTextLabel?.text = "\(max(20, instance.integer(forKey: "VFM_BackgroundSetupTime")))"
            case PerformanceSettings.headroom.rawValue:
                cell.textLabel?.text = "Headroom  (MB)"
                cell.detailTextLabel?.text = "\(instance.headroom)"
            case PerformanceSettings.maxStorage.rawValue:
                cell.textLabel?.text = "Max Storage (MB)"
                cell.detailTextLabel?.text = "\((Int64.max == instance.maxStorageAllowed) ? "unlimited" : instance.maxStorageAllowed.description)"
            case PerformanceSettings.enableIFrames.rawValue:
                cell.textLabel?.text = "Enable IFRAME"
                cell.detailTextLabel?.text = instance.iframeSupportEnabled.description
            case PerformanceSettings.cellDownload.rawValue:
                cell.textLabel?.text = "Enable Cellular Download"
                cell.detailTextLabel?.text = instance.downloadOverCellular.description
            case PerformanceSettings.proxyLogging.rawValue:
                cell.textLabel?.text = "Enable Proxy Logging"
                cell.detailTextLabel?.text = VirtuosoLogger.proxyLoggingEnabled.description
            case PerformanceSettings.backplaneLogging.rawValue:
                cell.textLabel?.text = "Enable Backplane Logging"
                cell.detailTextLabel?.text = VirtuosoLogger.backplaneLoggingEnabled.description
            default:
                cell.textLabel?.text = "unhandled-engine-status"
                cell.detailTextLabel?.text = ""
            }
        })
           
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            
        case PerformanceSettings.taskRefillLimit.rawValue:
            setTaskRefillLimit(indexPath)
            
        case PerformanceSettings.taskRefillSize.rawValue:
            setTaskRefillSize(indexPath)
            
        case PerformanceSettings.timeout.rawValue:
            setTimeout(indexPath)
            
        case PerformanceSettings.maxHTTPConnections.rawValue:
            setMaxHTTPConnections(indexPath)
            
        case PerformanceSettings.maxPackagerSegments.rawValue:
            setMaxPackagerSegments(indexPath)
            
        case PerformanceSettings.backgroundSetupTime.rawValue:
            setBackgroundSetupTime(indexPath)
            
        case PerformanceSettings.headroom.rawValue:
            setHeadroom(indexPath)
            
        case PerformanceSettings.maxStorage.rawValue:
            setMaxStorage(indexPath)
            
        case PerformanceSettings.enableIFrames.rawValue:
            setEnableIFrames(indexPath)
            
        case PerformanceSettings.cellDownload.rawValue:
            setCellularDownload(indexPath)
            
        case PerformanceSettings.proxyLogging.rawValue:
            setProxyLogging(indexPath)
            
        case PerformanceSettings.backplaneLogging.rawValue:
            setBackplaneLogging(indexPath)
            
        default:
            break;
        }
    }
    
    
    // Setting: VFM_TaskRefillLimit
    // This value controls maximum number of active download tasks.
    // Default: 10
    func setTaskRefillLimit(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Setting's of zero are not allowed
                guard ival > 0 else { return }
                
                // Set new value
                
                instance.setInteger(ival, forKey: "VFM_TaskRefillLimit")
            }
            
            self.changeTextValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Task Refill Limit",
                                  settingName: "Default 10",
                                  settingValue: instance.integer(forKey:"VFM_TaskRefillLimit").description,
                                  kbdType: .numberPad)
            
            })
        }
    
    // Setting: VFM_TaskRefillSize
    // This value controls maximum number of pending segments considered when creating new download tasks.
    // Default: 40
    func setTaskRefillSize(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
        
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Setting's of zero are not allowed
                guard ival > 0 else { return }

                // Set new value
                instance.setInteger(ival, forKey: "VFM_TaskRefillSize")
            }
            
            self.changeTextValueDialog(indexPath,
                                      closure:validateInput,
                                      settingTitle: "Task Refil Size",
                                      settingName: "Default 40",
                                      settingValue: instance.integer(forKey:"VFM_TaskRefillSize").description,
                                      kbdType: .numberPad)
                
        })

    }
    
    // Setting: VirtuosoSettings.instance().timeout
    // This value controls network timeout interval
    // Default: 60 seconds
    func setTimeout(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
                
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Double(sval) else { return }
                
                // Setting's of zero are not allowed
                guard ival > 0 else { return }
                
                // Set new value
                instance.networkTimeout = ival;
            }
            
            self.changeTextValueDialog(indexPath,
                                    closure:validateInput,
                                    settingTitle: "Timeout",
                                    settingName: "Default 60 seconds",
                                    settingValue: instance.networkTimeout.description,
                                    kbdType: .numberPad)
                
        })
        
    }

    // Setting: VFM_MaxHTTPConn
    // This value controls maximum number of HTTP Connections that will be used during download.
    // Default: 20
    func setMaxHTTPConnections(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Setting's of zero are not allowed
                guard ival > 0 else { return }
                
                // Set new value
                instance.setInteger(ival, forKey: "VFM_MaxHTTPConn")
            }
            
            self.changeTextValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Max HTTP Connections",
                                  settingName: "Default 20",
                                  settingValue: instance.integer(forKey:"VFM_MaxHTTPConn").description,
                                  kbdType: .numberPad)
        })
        
    }

    // Setting: VFM_MaxPackagerSegments
    // This value controls maximum number of Packager Segments that will be requested for background download.
    // Default: 200
    func setMaxPackagerSegments(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
        
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Setting's of zero are not allowed
                guard ival > 0 else { return }
                
                // Set new value
                instance.setInteger(ival, forKey: "VFM_MaxPackagerSegments")
            }
            
            self.changeTextValueDialog(indexPath,
                                      closure:validateInput,
                                      settingTitle: "Max Packager Segments",
                                      settingName: "Default 200",
                                      settingValue: instance.integer(forKey:"VFM_MaxPackagerSegments").description,
                                      kbdType: .numberPad)
                
        })
        
    }

    // Setting: Virtuoso.instance().headroom
    // This value controls amount of storage that should remain free on the device.
    // Default: 1GB, minimum 500 MB
    func setHeadroom(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Minimum is 500 mb
                guard ival > 500 else {
                    // Important:
                    // This call shows how to reset headroom to whatever the default value is
                    instance.resetHeadroomToDefault()
                    return
                }
                
                // Important:
                // VirtuosoSettings.instance().headroom is read-only. To change this value
                // use method VirtuosoSettings.instance().overrideHeadroom(Int64(ival))
                instance.overrideHeadroom(Int64(ival))
            }
            
            self.changeTextValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Headroom (in MB)",
                                  settingName: "Default 1024",
                                  settingValue: instance.headroom.description,
                                  kbdType: .numberPad)
            
            })
      
        }
    
    // Setting: Virtuoso.instance().maxStorageAllowed
    // This value controls maximum amount of storage that can be used.
    // Default: 5GB, resets to default when zero
    func setMaxStorage(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Rest when zero
                guard ival > 0 else {
                    // Important:
                    // This call shows how to reset max storage allowed
                    instance.resetMaxStorageAllowedToDefault()
                    return
                }
                
                // Important:
                // VirtuosoSettings.instance().maxStorageAllowed is read-only. To change this value
                // use method VirtuosoSettings.instance().overrideMaxStorageAllowed(Int64(ival))
                instance.overrideMaxStorageAllowed(Int64(ival))
            }
            
            self.changeTextValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Max Storage (in MB)",
                                  settingName: "Default unlimited",
                                       settingValue: "\((Int64.max == instance.maxStorageAllowed) ? "" : (instance.maxStorageAllowed).description)",
                                  kbdType: .numberPad)
            
        })
    }

    // Setting: VFM_BackgroundSetupTime
    // This value controls number of seconds needed for background download setup
    // Default: 20 seconds
    func setBackgroundSetupTime(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure to range check input
            let validateInput: TextValidationClosure = {
                (val1: String?) -> Void in
                guard let sval = val1 else { return }
                guard let ival = Int(sval) else { return }
                
                // Minimum value is 20 seconds
                guard ival >= 20 else { return }
                
                // Set new value
                instance.setInteger(ival, forKey: "VFM_BackgroundSetupTime")
            }
            
            self.changeTextValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Packager Setup Time",
                                  settingName: "Default 20 seconds",
                                  settingValue: instance.integer(forKey:"VFM_BackgroundSetupTime").description,
                                  kbdType: .numberPad)
        })
    }

    // Setting: VirtuosoSettings.instance().iframeSupportEnabled
    // This value controls enable/disable downloading of HLS IFRAME's
    // Default: false
    func setEnableIFrames(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure update setting
            let validateInput: BooleanValidationClosure = {
                (val1: Bool) -> Void in
                instance.iframeSupportEnabled = val1;
            }
            
            self.changeBooleanValueDialog(indexPath,
                                     closure:validateInput,
                                     settingTitle: "Enble IFRAMES",
                                     settingName: "Default No",
                                     settingValue: instance.iframeSupportEnabled.description)
        })
    }

    // Setting: VirtuosoSettings.instance().downloadOverCellular
    // This value controls enable/disable downloading over Cellular connection
    // Default: false
    func setCellularDownload(_ indexPath: IndexPath) {
        
        VirtuosoSettings.instance(onReady: {(instance:VirtuosoSettings)->Void in
            
            // Closure update setting
            let validateInput: BooleanValidationClosure = {
                (val1: Bool) -> Void in
                instance.overrideDownloadOverCellular(val1)
            }
            
            self.changeBooleanValueDialog(indexPath,
                                     closure:validateInput,
                                     settingTitle: "Enable Cellular Download",
                                     settingName: "Default No",
                                     settingValue: instance.downloadOverCellular.description)
        })
    }
        
    // This value controls enable/disable downloading over Cellular connection
    // Default: false
    func setProxyLogging(_ indexPath: IndexPath) {
        
        // Closure update setting
        let validateInput: BooleanValidationClosure = {
            (val1: Bool) -> Void in
            VirtuosoLogger.proxyLoggingEnabled = val1
        }
        
        changeBooleanValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Enable Proxy Logging",
                                  settingName: "Default No",
                                  settingValue: VirtuosoLogger.proxyLoggingEnabled.description)
    }
    
    // This value controls enable/disable downloading over Cellular connection
    // Default: false
    func setBackplaneLogging(_ indexPath: IndexPath) {
        
        // Closure update setting
        let validateInput: BooleanValidationClosure = {
            (val1: Bool) -> Void in
            VirtuosoLogger.backplaneLoggingEnabled = val1
        }
        
        changeBooleanValueDialog(indexPath,
                                  closure:validateInput,
                                  settingTitle: "Enable Backplane Logging",
                                  settingName: "Default No",
                                  settingValue: VirtuosoLogger.backplaneLoggingEnabled.description)
    }
    
    func changeTextValueDialog(_ indexPath: IndexPath, closure : TextValidationClosure?, settingTitle: String, settingName: String, settingValue: String, kbdType: UIKeyboardType) {
        
        var inputTextField: UITextField?
        
        let alertView = UIAlertController(title: settingTitle, message: settingName, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let tf = inputTextField else { return }
            guard let cl = closure else { return }
            cl(tf.text)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(ok)
        alertView.addAction(cancel)
        alertView.addTextField { (tf) in
            tf.text = settingValue
            tf.keyboardType = kbdType
            inputTextField = tf
        }
        
        self.present(alertView, animated: true)
    }

    func changeBooleanValueDialog(_ indexPath: IndexPath, closure : BooleanValidationClosure?, settingTitle: String, settingName: String, settingValue: String) {
        
        let alertView = UIAlertController(title: settingTitle, message: settingName, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            guard let cl = closure else { return }
            cl(true)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        let no = UIAlertAction(title: "No", style: .cancel) { (action) in
            guard let cl = closure else { return }
            cl(false)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        alertView.addAction(yes)
        alertView.addAction(no)
        
        self.present(alertView, animated: true)
    }

}

