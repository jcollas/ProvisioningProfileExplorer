//
//  Entitlements.swift
//  ProvisioningProfileExplorer
//
//  Created by Juan J. Collas on 5/16/2017.
//

import Foundation

struct Entitlements: CustomStringConvertible {

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

    var isEmpty: Bool {
        return entitlements.count == 0
    }

    var description: String {
        let buffer = NSMutableString()
        displayEntitlements(0, key: "", value: entitlements, buffer: buffer)
        return buffer as String
    }

    func displayEntitlements(_ tab: Int,  key: String, value: Any, buffer: NSMutableString) {

        if value is NSDictionary {
            if key.isEmpty {
                buffer.append("\(space(tab)){\n")
            } else {
                buffer.append("\(space(tab))\(key) = {\n")
            }

            let dictionary = value as! NSDictionary
            var keys = dictionary.allKeys as! [String]
            keys.sort()

            for key in keys {
                displayEntitlements(tab + 1, key: key, value: dictionary.value(forKey: key)! as AnyObject, buffer: buffer)
            }
            buffer.append("\(space(tab))}\n")

        } else if value is NSArray {
            let array = value as! NSArray
            buffer.appendFormat("%@%@ = (\n", space(tab), key)
            for value in array {
                displayEntitlements(tab + 1, key: "", value: value as! NSObject, buffer: buffer)
            }
            buffer.append("\(space(tab)))\n")

        } else if value is Data {
            let data = value as! Data
            if key.isEmpty {
                buffer.appendFormat("%@%d bytes of data\n", space(tab), data.count)
            } else {
                buffer.appendFormat("%@%@ = %d bytes of data\n", space(tab), key, data.count)
            }
        } else {
            let valueText = (value as AnyObject).description
            if key.isEmpty {
                buffer.appendFormat("%@%@\n", space(tab), valueText!)
            } else {
                buffer.appendFormat("%@%@ = %@\n", space(tab), key, valueText!)
            }
        }
    }

    func space(_ num: Int) -> String {
        var tmp = ""
        for _ in 0..<num {
            tmp = tmp + "    "
        }
        return tmp
    }
    

}
