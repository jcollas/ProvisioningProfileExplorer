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
    var timeToLive :NSNumber = 0
    var expirationDate = Date(timeIntervalSinceReferenceDate: 0)
    var creationDate = Date(timeIntervalSinceReferenceDate: 0)
    var lastDays = 0
    var entitlements = ""
    var certificates: [Certificate] = []
    var fileName = ""
    var fileModificationDate = Date(timeIntervalSinceReferenceDate: 0)
    var fileSize:UInt64 = 0

    init(url: URL) {

        guard let encryptedData = try? Data(contentsOf: url) else {
            return
        }

        guard let plistData = decode(encryptedData) else {
            return
        }

        guard let plist = try? PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil) as! NSDictionary else {
            return
        }

        fileName = url.path

        if let attr: NSDictionary = try! FileManager.default.attributesOfItem(atPath: fileName) as NSDictionary {
            fileModificationDate = attr.fileModificationDate()!
            fileSize = attr.fileSize()
        }

        let calendar = Calendar.current
        name = plist[JSON.name] as! String
        creationDate = plist[JSON.creationDate] as! Date
        expirationDate = plist[JSON.expirationDate] as! Date
        // 期限までの残り日数
        lastDays = (calendar as NSCalendar).components([.day], from:expirationDate, to: Date(),options: []).day!
        lastDays *= -1
        uuid = plist[JSON.uuid] as! String
        teamName = plist[JSON.teamName] as! String
        teamIdentifier = plist[JSON.teamID] as? [String] ?? []
        appIDName = plist[JSON.appIDName] as! String
        timeToLive = plist[JSON.timeToLive] as! NSNumber
        if let devices = plist[JSON.provisionedDevices] as? [String] {
            provisionedDevices = devices.sorted{ $0 < $1 }
        }
        // Certificates
        let developerCertificates = plist[JSON.developerCertificates] as! [Any]
        certificates = decodeCertificate(developerCertificates)
        certificates.sort { $0.summary < $1.summary }

        // Entitlements
        let dictionary = plist[JSON.entitlements] as! NSDictionary
        if dictionary.count > 0 {
            let buffer = NSMutableString()
            buffer.appendFormat("<pre>")
            displayEntitlements(0, key: "", value: dictionary, buffer: buffer)
            buffer.appendFormat("</pre>")
            entitlements = buffer as String
        }else{
            entitlements = "No Entitlements"
        }
    }

    func decodeCertificate(_ array: [Any]) -> [Certificate] {
        var certificates: [Certificate] = []

        for data in array {
            let certificate = Certificate(data: data as! Data)

            certificates.append(certificate)
        }

        return certificates
    }

    func displayEntitlements(_ tab:Int,  key:String, value:AnyObject, buffer:NSMutableString) {

        if value is NSDictionary {
            if key.isEmpty {
                buffer.appendFormat("%@{\n", space(tab))
            } else {
                buffer.appendFormat("%@%@ = {\n", space(tab), key)
            }

            let dictionary = value as! NSDictionary
            var keys = dictionary.allKeys as! [String]
            keys.sort()

            for key in keys {
                displayEntitlements(tab + 1, key: key, value: dictionary.value(forKey: key)! as AnyObject, buffer: buffer)
            }
            buffer.appendFormat("%@}\n", space(tab));

        } else if value is NSArray {
            let array = value as! NSArray
            buffer.appendFormat("%@%@ = (\n", space(tab), key)
            for value in array {
                displayEntitlements(tab + 1, key: "", value: value as! NSObject, buffer: buffer)
            }
            buffer.appendFormat("%@)\n", space(tab))

        } else if value is Data {
            let data = value as! Data
            if key.isEmpty {
                buffer.appendFormat("%@%d bytes of data\n", space(tab), data.count);
            } else {
                buffer.appendFormat("%@%@ = %d bytes of data\n", space(tab), key, data.count)
            }
        } else {
            if key.isEmpty {
                buffer.appendFormat("%@%@\n", space(tab), value.description)
            } else {
                buffer.appendFormat("%@%@ = %@\n", space(tab), key, value.description)
            }
        }
    }

    func space(_ num:Int) -> String {
        var tmp = ""
        for _ in 0..<num {
            tmp = tmp + "    "
        }
        return tmp
    }

    func LocalDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let comps = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from:date)
        let year = comps.year
        let month = comps.month
        let day = comps.day
        let hour = comps.hour
        let minute = comps.minute
        let second = comps.second
        return String(format: "%04d/%02d/%02d %02d:%02d:%02d", year!,month!,day!,hour!,minute!,second!)
    }

    func decode(_ encryptedData:Data) -> Data? {
        var decoder: CMSDecoder?;
        var decodedData: CFData?;

        CMSDecoderCreate(&decoder);
        CMSDecoderUpdateMessage(decoder!, (encryptedData as NSData).bytes, encryptedData.count);
        CMSDecoderFinalizeMessage(decoder!);
        CMSDecoderCopyContent(decoder!, &decodedData);
        return decodedData as? Data
    }

    func generateHTML() -> String {

        var css = ""
        if let filePath = Bundle.main.path(forResource: "style", ofType: "css"){
            css  = try! String(contentsOfFile: filePath)
        }
        var html = "<html>"
        html.append("<style>" + css + "</style>")

        if lastDays < 0 {
            html.append("<body style=\"background-color: #ff8888;\">")
        }else{
            html.append("<body>")
        }

        html.append(String(format: "<div class=\"name\">%@</div>",name))
        html = appendHTML(html,key: "Profile UUID",value: uuid)
        html = appendHTML(html,key: "Time To Live",value: "\(timeToLive)")
        html = appendHTML(html,key: "Profile Team",value: teamName)
        if teamIdentifier.count>0 {
            html.append("(")
            for team in teamIdentifier {
                html.append(String(format: "%@ ",team))
            }
            html.append(")")
        }
        html = appendHTML(html,key: "Creation Date",value: LocalDate(creationDate))
        html = appendHTML(html,key: "Expiretion Date",value: LocalDate(expirationDate))
        if lastDays < 0 {
            html.append(" expiring ")
        }else{
            html.append(" ( " + lastDays.description + " days )")
        }
        html = appendHTML(html,key: "App ID Name",value: appIDName)

        // DEVELOPER CRTIFICATES
        var n = 1
        if certificates.count > 0 {
            html.append("<div class=\"title\">DEVELOPER CRTIFICATES</div>")
            html.append("<table>")
            for certificate in certificates {
                html.append("<tr>")
                html.append("<td>\(n)</td>")
                html.append("<td>\(certificate.summary)</td>")
                if certificate.expires == nil {
                    html.append("<td>No invalidity date in certificate</td>")
                }else{

                    if certificate.lastDays < 0 {
                        html.append("<td>expiring</td>")
                    }else{
                        html.append("<td>Expires in " + certificate.lastDays.description + " days </td>")
                    }
                }
                html.append("</tr>")
                n += 1
            }
            html.append("</table>")
        }


        // ENTITLEMENTS
        html.append("<div class=\"title\">ENTITLEMENTS</div>")
        html.append(entitlements)

        // DEVICES
        if provisionedDevices.count > 0 {
            html.append("<div class=\"title\">DEVICES ")
            html.append(String(format: "(%d DEVICES)",provisionedDevices.count))
            html.append("</div>")

            html.append("<table>")
            html.append("<tr><td></td><td>UUID</td></tr>")
            var c = "*"
            for device in provisionedDevices {
                html.append("<tr>")
                let firstChar = (device as NSString).substring(to: 1)
                if firstChar != c {
                    c = firstChar
                    html.append(String(format: "<td>%@-></td>",c))
                }else{
                    html.append(String(format: "<td></td>"))
                }
                html.append(String(format: "<td>%@</td>",device))
                html.append("</tr>")
            }
            html.append("</table>")
        }else{
            html.append("<div class=\"title\">DEVICES (Distribution Profile)</div>")
            html.append("<br>No Devices")
        }

        // FILE INFOMATION
        html.append("<div class=\"title\">FILE INFOMATION</div>")
        html.append("<br>Path: \(fileName)")
        html.append("<br>size: \(fileSize/1000)Kbyte")
        html.append("<br>ModificationDate: \(LocalDate(fileModificationDate))")


        html.append("</body>")
        html.append("</html>")
        return html
    }

    func appendHTML(_ html:String, key:String, value:String) -> String{
        return String(format: "%@<br>%@: %@",html,key,value)
    }
}
