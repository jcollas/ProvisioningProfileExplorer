//
//  ProvisioningProfileDisplay.swift
//  ProvisioningProfileExplorer
//
//  Created by Collas,Juan J on 5/17/17.
//  Copyright © 2017 SAPPOROWORKS. All rights reserved.
//

import Foundation

struct ProvisioningProfileDisplay {
    var profile: ProvisioningProfile

    init(profile: ProvisioningProfile) {
        self.profile = profile
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

    func displayEntitlements(_ tab: Int,  key: String, value: Any, buffer: NSMutableString) {

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
            buffer.appendFormat("%@}\n", space(tab))

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

    func generateHTML() -> String {

        var css = ""

        if let filePath = Bundle.main.path(forResource: "style", ofType: "css"){
            css = try! String(contentsOfFile: filePath)
        }

        var html = "<html>"
        html.append("<style>" + css + "</style>")

        if profile.lastDays < 0 {
            html.append("<body style=\"background-color: #ff8888;\">")
        }else{
            html.append("<body>")
        }

        html.append("<div class=\"name\">\(profile.name)</div>")
        html = appendHTML(html, key: "Profile UUID",value: profile.uuid)
        html = appendHTML(html, key: "Time To Live",value: "\(profile.timeToLive)")
        html = appendHTML(html, key: "Profile Team",value: profile.teamName)
        if profile.teamIdentifier.count>0 {
            html.append("(")
            for team in profile.teamIdentifier {
                html.append("\(team) ")
            }
            html.append(")")
        }
        html = appendHTML(html, key: "Creation Date", value: LocalDate(profile.creationDate))
        html = appendHTML(html, key: "Expiration Date",value: LocalDate(profile.expirationDate))
        if profile.lastDays < 0 {
            html.append(" expiring ")
        }else{
            html.append(" ( " + profile.lastDays.description + " days )")
        }
        html = appendHTML(html, key: "App ID Name", value: profile.appIDName)

        // DEVELOPER CRTIFICATES
        var n = 1
        if profile.certificates.count > 0 {
            html.append("<div class=\"title\">DEVELOPER CRTIFICATES</div>")
            html.append("<table>")
            for certificate in profile.certificates {
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
        var entitlements = ""

        if profile.entitlements.count > 0 {
            let buffer = NSMutableString()
            buffer.appendFormat("<pre>")
            displayEntitlements(0, key: "", value: profile.entitlements, buffer: buffer)
            buffer.appendFormat("</pre>")
            entitlements = buffer as String
        } else{
            entitlements = "No Entitlements"
        }

        html.append(entitlements)

        // DEVICES
        if profile.provisionedDevices.count > 0 {
            html.append("<div class=\"title\">DEVICES ")
            html.append("(\(profile.provisionedDevices.count) DEVICES)")
            html.append("</div>")

            html.append("<table>")
            html.append("<tr><td></td><td>UUID</td></tr>")
            var c = "*"
            for device in profile.provisionedDevices {
                html.append("<tr>")
                let firstChar = (device as NSString).substring(to: 1)
                if firstChar != c {
                    c = firstChar
                    html.append("<td>\(c)-></td>")
                } else {
                    html.append("<td></td>")
                }
                html.append("<td>\(device)</td>")
                html.append("</tr>")
            }
            html.append("</table>")
        }else{
            html.append("<div class=\"title\">DEVICES (Distribution Profile)</div>")
            html.append("<br>No Devices")
        }

        // FILE INFOMATION
        html.append("<div class=\"title\">FILE INFOMATION</div>")
        html.append("<br>Path: \(profile.fileName)")
        html.append("<br>size: \(profile.fileSize/1000)Kbyte")
        html.append("<br>ModificationDate: \(LocalDate(profile.fileModificationDate))")


        html.append("</body>")
        html.append("</html>")
        return html
    }

    func appendHTML(_ html:String, key:String, value:String) -> String {
        return "\(html)<br>\(key): \(value)"
    }

}
