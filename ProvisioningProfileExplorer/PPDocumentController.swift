//
//  PPDocumentController.swift
//  ProvisioningProfileExplorer
//
//  Created by Collas,Juan J on 5/22/17.
//  Copyright © 2017 SAPPOROWORKS. All rights reserved.
//

import Cocoa

class PPDocumentController: NSDocumentController {

    override func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()

        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        panel.begin {  result -> Void in
            if (result == NSFileHandlingPanelOKButton) {
                let selectedURL = panel.urls[0]
                NSLog("selected URL: \(selectedURL)")
                self.openDocument(withContentsOf: selectedURL, display: true) { (document, documentWasAlreadyOpen, error) in
//                    NSLog("%spened document %@ (%@)", (documentWasAlreadyOpen? "Reo" : "O"), document, error);
                }
            }
        }
    }

}
