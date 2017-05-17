//
//  Entitlements.swift
//  ProvisioningProfileExplorer
//
//  Created by Juan J. Collas on 5/16/2017.
//

import Foundation

struct Entitlements {

    struct JSON {
        static let keychainAccessGroups = "keychain-access-groups"
        static let taskAllow = "get-task-allow"
        static let appID = "application-identifier"
        static let teamID = "com.apple.developer.team-identifier"
    }

    var entitlements: [String: Any] = [:]

    init(_ entitlements: [String: Any]) {
        self.entitlements = entitlements
    }

    var keychainAccessGroups: [String] {
        return entitlements[JSON.keychainAccessGroups] as? [String] ?? []
    }

    var taskAllow: Bool {
        return entitlements[JSON.taskAllow] as? Bool ?? false
    }

    var appID: String? {
        return entitlements[JSON.appID] as? String
    }

    var teamID: String? {
        return entitlements[JSON.teamID] as? String
    }

}
