//
//  ProfileManager.swift
//  ProvisioningProfileExplorer
//
//  Created by Collas,Juan J on 5/17/17.
//  Copyright © 2017 SAPPOROWORKS. All rights reserved.
//

import Foundation

class ProfileManager {

    var profiles: [ProvisioningProfile] = []

    class var shared: ProfileManager {
        struct Static {
            static let instance: ProfileManager = ProfileManager()
        }
        return Static.instance
    }

    init() {
        let manager = FileManager.default

        let path = NSHomeDirectory() + "/Library/MobileDevice/Provisioning Profiles"
        let provisioningUrl = URL(fileURLWithPath: path)
        let profileUrls = try! manager.contentsOfDirectory(at: provisioningUrl, includingPropertiesForKeys: nil)

        for url in profileUrls {

            if url.pathExtension != "mobileprovision" {
                continue
            }

            profiles.append(ProvisioningProfile(url: url))
        }

        processDuplicates()
    }

    func processDuplicates() -> Void {
        var dups: [String: [ProvisioningProfile]] = [:]

        // group profiles by profile name
        for profile in profiles {
            guard let appID = profile.entitlements.appID else {
                continue
            }

            let name = "\(appID):\(profile.entitlements.taskAllow)"
            
            dups[name] == nil ?
                dups[name] = [profile] :
                dups[name]?.append(profile)
        }

        for key in dups.keys {
            if let values = dups[key]?.sorted(by: { $0.expirationDate > $1.expirationDate}) {
                _ = values.map { $0.setDuplicate(true) }
                values.first?.setDuplicate(false)
            }
        }

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
