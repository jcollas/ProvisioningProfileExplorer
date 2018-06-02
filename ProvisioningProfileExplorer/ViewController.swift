//
//  ViewController.swift
//  ProvisioningProfileExplorer
//
//  Created by hirauchi.shinichi on 2016/04/10.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import Cocoa
import WebKit

import SecurityFoundation
import SecurityInterface

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var statusLabel: NSTextField!

    let dateFormatter = DateFormatter()

    var profiles: [ProvisioningProfile] = [] {
        didSet {
            search("")
        }
    }
    var viewProfiles: [ProvisioningProfile] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "yyyy/MM/dd"

        search("")

        // 一番上を選択する
        let indexSet = IndexSet(integer: 0)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: true)

        let profileDisplay = ProvisioningProfileDisplay(profile: viewProfiles.first)
        webView.mainFrame.loadHTMLString(profileDisplay.generateHTML(),baseURL: nil)
    }

    //search
    func search(_ searchText: String) {
        print("Search(\(searchText))")

        viewProfiles = profiles.filter { $0.match(searchText) }

        statusLabel.stringValue = "\(viewProfiles.count) provisioning Profiles"

        // Update UI.
        tableView.reloadData()

        let indexSet = IndexSet(integer: 0)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)

        let notification = Notification(name: Notification.Name(""))
        tableViewSelectionDidChange(notification)
    }

    @IBAction func changeSearchField(_ sender: NSSearchFieldCell) {
        search(sender.stringValue)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

}

extension ViewController: NSTableViewDataSource {

    // tableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewProfiles.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let profile = viewProfiles[row]

        switch tableColumn!.identifier.rawValue {
        case "teamName":
            return profile.teamName

        case "name":
            return profile.name

        case "expirationDate":
            let dateValue = dateFormatter.string(from: profile.expirationDate)
            let last = profile.lastDays < 0 ? "expiring" : "(\(profile.lastDays)days)"
            return "\(dateValue) \(last)"

        case "createDate":
            return profile.creationDate

        case "bundleID":
            return profile.entitlements.bundleID

        case "teamID":
            return profile.entitlements.teamID

        case "status":
            return profile.status.description

        default:
            return "ERROR"
        }
    }

}

extension ViewController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow

        if 0 <= row && row < viewProfiles.count {
            let profileDisplay = ProvisioningProfileDisplay(profile: viewProfiles[row])

            webView.mainFrame.loadHTMLString(profileDisplay.generateHTML(), baseURL: nil)
        } else {
            webView.mainFrame.loadHTMLString("", baseURL: nil)
        }
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {

        for sortDescriptor in tableView.sortDescriptors {
            let key = sortDescriptor.key!
            switch key {
            case "name":
                if sortDescriptor.ascending {

                    viewProfiles.sort { $0.name < $1.name }
                } else {
                    viewProfiles.sort { $0.name > $1.name }
                }

            case "teamName":
                if sortDescriptor.ascending {
                    viewProfiles.sort { $0.teamName < $1.teamName }
                } else {
                    viewProfiles.sort { $0.teamName > $1.teamName }
                }

            case "expirationDate":
                if sortDescriptor.ascending {
                    viewProfiles.sort { $0.expirationDate.timeIntervalSince1970 < $1.expirationDate.timeIntervalSince1970 }
                } else {
                    viewProfiles.sort { $0.expirationDate.timeIntervalSince1970 > $1.expirationDate.timeIntervalSince1970 }
                }

            case "status":
                if sortDescriptor.ascending {
                    viewProfiles.sort { $0.status.description < $1.status.description }
                } else {
                    viewProfiles.sort { $0.status.description > $1.status.description }
                }

            case "teamID":
                if sortDescriptor.ascending {
                    viewProfiles.sort { $0.entitlements.teamID < $1.entitlements.teamID }
                } else {
                    viewProfiles.sort { $0.entitlements.teamID > $1.entitlements.teamID }
                }

            case "bundleID":
                if sortDescriptor.ascending {
                    viewProfiles.sort { $0.entitlements.bundleID < $1.entitlements.bundleID }
                } else {
                    viewProfiles.sort { $0.entitlements.bundleID > $1.entitlements.bundleID }
                }

            default:
                break
            }
            break // 一回でいい
        }

        tableView.reloadData()
    }

}
