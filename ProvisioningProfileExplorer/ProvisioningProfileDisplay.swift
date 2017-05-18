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
        html.append("<br>Profile UUID: \(profile.uuid)")
        html.append("<br>Time To Live: \(profile.timeToLive)")
        html.append("<br>Profile Team: \(profile.teamName)")

        if profile.teamIdentifier.isEmpty == false {
            let teams = profile.teamIdentifier.joined(separator: " ")
            html.append(" (\(teams))")
        }

        html.append("<br>Creation Date: \(LocalDate(profile.creationDate))")
        html.append("<br>Expiration Date: \(LocalDate(profile.expirationDate))")

        if profile.lastDays < 0 {
            html.append(" expiring ")
        } else {
            html.append(" ( \(profile.lastDays) days )")
        }

        html.append("<br>App ID Name: \(profile.appIDName)")

        // DEVELOPER CRTIFICATES
        var n = 1
        if profile.certificates.isEmpty == false {
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
        var entitlements = "No Entitlements"

        if profile.entitlements.isEmpty == false {
            entitlements = "<pre>\(profile.entitlements.description)</pre>"
        }

        html.append(entitlements)

        // DEVICES
        if profile.provisionedDevices.isEmpty == false {
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
        html.append("<br>size: \(profile.fileSize/1000) Kbyte")
        html.append("<br>ModificationDate: \(LocalDate(profile.fileModificationDate))")


        html.append("</body>")
        html.append("</html>")

        return html
    }

}
