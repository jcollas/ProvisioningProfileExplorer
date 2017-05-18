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

    }


    /// Returns all unique and unexpired provisioning profiles
    ///
    /// - Returns: all unique and unexpired profiles
    func active() -> [ProvisioningProfile] {
        let dups = duplicates()

        return profiles.filter { (elem) in dups.contains(elem) == false && elem.isExpired == false }
    }

    func expired() -> [ProvisioningProfile] {
        return profiles.filter { $0.isExpired }
    }

    func duplicates() -> [ProvisioningProfile] {
        var allDups: [ProvisioningProfile] = []
        var dups: [String: [ProvisioningProfile]] = [:]

        // group profiles by profile name
        for profile in profiles {
            let name = profile.name
            dups[name] == nil ?
                dups[name] = [profile] :
                dups[name]?.append(profile)
        }

        for key in dups.keys {
            if let values = dups[key]?.sorted(by: { $0.expirationDate > $1.expirationDate}) {
                allDups.append(contentsOf: Array(values[1..<values.count]))
            }
        }

        return allDups
    }

}