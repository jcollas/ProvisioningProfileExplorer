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

    var _profiles: [ProvisioningProfile] = []
    var viewProfiles: [ProvisioningProfile] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let manager = FileManager.default

        let path =  NSHomeDirectory() + "/Library/MobileDevice/Provisioning Profiles"
        let provisioningUrl = URL(fileURLWithPath: path)
        let profileUrls = try! manager.contentsOfDirectory(at: provisioningUrl, includingPropertiesForKeys: nil)

        for url in profileUrls {

            if url.pathExtension != "mobileprovision" {
                continue
            }

            _profiles.append(ProvisioningProfile(url: url))
        }

        Search("")

        // 一番上を選択する
        let indexSet = IndexSet(integer: 0)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: true)

        let profileDisplay = ProvisioningProfileDisplay(profile: viewProfiles[0])
        webView.mainFrame.loadHTMLString(profileDisplay.generateHTML(),baseURL: nil)
    }

    //search
    func Search(_ searchText:String){
        print("Search(\(searchText))")
        if searchText == "" {
            viewProfiles = _profiles
        }else{
            viewProfiles = []
            for profile in _profiles {
                if profile.appIDName.lowercased().contains(searchText.lowercased()) {
                    viewProfiles.append(profile)
                }else if profile.name.lowercased().contains(searchText.lowercased()) {
                    viewProfiles.append(profile)
                }else if profile.uuid.lowercased().contains(searchText.lowercased()) {
                    viewProfiles.append(profile)
                }
            }
        }
        statusLabel.stringValue = "\(viewProfiles.count) provisioning Profiles"
        tableView.reloadData()
    }

    @IBAction func changeSearchField(_ sender: NSSearchFieldCell) {
        Search(sender.stringValue)
    }

    // ローカルタイムでのNSDate表示
    func LocalDate(_ date: Date,lastDays: Int) -> String {
        let calendar = Calendar.current
        let comps = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from:date)
        let year = comps.year
        let month = comps.month
        let day = comps.day
        var last = "expiring"
        if lastDays >= 0 {
            last = "(\(lastDays)days)"
        }
        return String(format: "%04d/%02d/%02d %@", year!,month!,day!,last)
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

        switch tableColumn!.identifier {
        case "teamName":
            return viewProfiles[row].teamName

        case "name":
            return viewProfiles[row].name

        case "expirationDate":
            return LocalDate(viewProfiles[row].expirationDate as Date,lastDays: viewProfiles[row].lastDays)

        case "createDate":
            return viewProfiles[row].creationDate

        case "uuid":
            return viewProfiles[row].uuid

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

            case "uuid":
                fallthrough

            default:
                if sortDescriptor.ascending {
                    viewProfiles.sort { $0.uuid < $1.uuid }
                } else {
                    viewProfiles.sort { $0.uuid > $1.uuid }
                }
            }
            break // 一回でいい
        }

        tableView.reloadData()
    }

}
