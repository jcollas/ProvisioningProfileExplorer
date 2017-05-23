//
//  AppDelegate.swift
//  ProvisioningProfileExplorer
//
//  Created by hirauchi.shinichi on 2016/04/10.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSResponder, NSApplicationDelegate {

    override init() {
        super.init()
        // Insert code here to initialize your application
        _ = PPDocumentController.shared()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let path = NSHomeDirectory() + "/Library/MobileDevice/Provisioning Profiles"
        let url = URL(fileURLWithPath: path)

        let documentController = PPDocumentController.shared()

        documentController.openDocument(withContentsOf: url, display: true) { (document, value, error) -> Void in
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

}

