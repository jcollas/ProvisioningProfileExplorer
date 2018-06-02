//
//  PPDocument.swift
//  ProvisioningProfileExplorer
//
//  Created by Juan J. Collas on 5/17/17.
//

import Cocoa

class PPDocument: NSDocument {

    var profiles: [ProvisioningProfile] = []

    override init() {
        super.init()
    }

    func processDuplicates() -> Void {
        var dups: [String: [ProvisioningProfile]] = [:]

        // group profiles by profile name
        for profile in profiles {
            let appID = profile.entitlements.appID
            let name = "\(appID):\(profile.entitlements.taskAllow)"
            
            dups[name] == nil ?
                dups[name] = [profile] :
                dups[name]?.append(profile)
        }

        for key in dups.keys {
            if var values = dups[key]?.sorted(by: { $0.expirationDate > $1.expirationDate}) {
                for i in values.indices {
                    values[i].setDuplicate(true)
                }

                values[0].setDuplicate(false)
            }
        }

    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)

        let vc = windowController.contentViewController as! ViewController

        vc.profiles = self.profiles
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from url: URL, ofType typeName: String) throws {

        let manager = FileManager.default

        let profileUrls = try! manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

        for aUrl in profileUrls {

            if aUrl.pathExtension != "mobileprovision" {
                continue
            }

            profiles.append(ProvisioningProfile(url: aUrl))
        }
        
        processDuplicates()
    }

    /// Returns all unique and unexpired provisioning profiles
    ///
    /// - Returns: all unique and unexpired profiles
    func active() -> [ProvisioningProfile] {
        return profiles.filter { $0.isActive }
    }

    func expired() -> [ProvisioningProfile] {
        return profiles.filter { $0.isExpired }
    }

    func duplicates() -> [ProvisioningProfile] {
        return profiles.filter { $0.isDuplicate }
    }

}
