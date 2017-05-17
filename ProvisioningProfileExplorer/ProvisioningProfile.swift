//
//  ProvisioningProfile.swift
//  ProvisioningProfileExplorer
//
//  Created by hirauchi.shinichi on 2016/04/10.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import Cocoa
//import ServiceManagement
//import SecurityInterface
//import SecurityFoundation


struct ProvisioningProfile {

    struct JSON {
        static let name = "Name"
        static let creationDate = "CreationDate"
        static let expirationDate = "ExpirationDate"
        static let uuid = "UUID"
        static let teamName = "TeamName"
        static let teamID = "TeamIdentifier"
        static let appIDName = "AppIDName"
        static let appIDPrefix = "ApplicationIndentifierPrefix"
        static let platform = "Platform"
        static let timeToLive = "TimeToLive"
        static let provisionedDevices = "ProvisionedDevices"
        static let developerCertificates = "DeveloperCertificates"
        static let entitlements = "Entitlements"
        static let version = "Version"
    }

    var name = ""
    var uuid = ""
    var teamName = ""
    var teamIdentifier = [String]()
    var appIDName:String = ""
    var provisionedDevices = [String]()
    var timeToLive: NSNumber = 0
    var expirationDate = Date()
    var creationDate = Date()
    var lastDays = 0
    var entitlements: [String: Any] = [:]
    var certificates: [Certificate] = []
    var fileName = ""
    var fileModificationDate = Date()
    var fileSize:UInt64 = 0

    init(url: URL) {

        guard let encryptedData = try? Data(contentsOf: url) else {
            return
        }

        guard let plistData = decode(encryptedData) else {
            return
        }

        guard let plist = try? PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil) as! [String: Any] else {
            return
        }

        fileName = url.path

        if let attr: NSDictionary = try? FileManager.default.attributesOfItem(atPath: fileName) as NSDictionary {
            fileModificationDate = attr.fileModificationDate()!
            fileSize = attr.fileSize()
        }

        let calendar = Calendar.current
        name = plist[JSON.name] as! String
        creationDate = plist[JSON.creationDate] as? Date ?? Date()
        expirationDate = plist[JSON.expirationDate] as? Date ?? Date()
        // 期限までの残り日数
        lastDays = (calendar as NSCalendar).components([.day], from:expirationDate, to: Date(), options: []).day!
        lastDays *= -1
        uuid = plist[JSON.uuid] as? String ?? ""
        teamName = plist[JSON.teamName] as? String ?? "Unknown"
        teamIdentifier = plist[JSON.teamID] as? [String] ?? []
        appIDName = plist[JSON.appIDName] as? String ?? ""
        timeToLive = plist[JSON.timeToLive] as! NSNumber
        if let devices = plist[JSON.provisionedDevices] as? [String] {
            provisionedDevices = devices.sorted{ $0 < $1 }
        }

        // Certificates
        if let certs = plist[JSON.developerCertificates] as? [Data] {
            certificates = certs.map { Certificate(data: $0) }
            certificates.sort { $0.summary < $1.summary }
        }

        // Entitlements
        entitlements = plist[JSON.entitlements] as? [String: Any] ?? [:]
    }

    func decode(_ encryptedData: Data) -> Data? {
        var decoder: CMSDecoder?

        CMSDecoderCreate(&decoder)

        if let decoder = decoder {
            var decodedData: CFData?

            CMSDecoderUpdateMessage(decoder, (encryptedData as NSData).bytes, encryptedData.count)
            CMSDecoderFinalizeMessage(decoder)
            CMSDecoderCopyContent(decoder, &decodedData)
            return decodedData as Data?
        }
        
        return nil
    }

    var isExpired: Bool {
        return lastDays < 0
    }

}
