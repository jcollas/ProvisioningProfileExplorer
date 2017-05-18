//
//  Certificate.swift
//  ProvisioningProfileExplorer
//
//  Created by hirauchi.shinichi on 2016/04/16.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import Cocoa

struct Certificate {
    var summary = ""
    var expires: Date? = nil
    var lastDays = 0

    init(data: Data) {

        guard let certificateRef = SecCertificateCreateWithData(nil,data as CFData) else {
            return
        }

        summary = SecCertificateCopySubjectSummary(certificateRef) as String? ?? ""
        let options = [kSecOIDInvalidityDate] as CFArray

        let valuesDict = SecCertificateCopyValues(certificateRef, options, nil)

        let values = valuesDict as? [String: Any] ?? [:]
        if let credential = values[kSecOIDInvalidityDate as String] as? [String: Any] {

//                    CFShow(credential)
//                    <CFBasicHash 0x600000263d80 [0x7fff79f4d440]>{type = immutable dict, count = 4,
//                        entries =>
//                        1 : <CFString 0x7fff7a49fdd0 [0x7fff79f4d440]>{contents = "label"} = <CFString 0x7fff7a4a0050 [0x7fff79f4d440]>{contents = "Expires"}
//                        2 : <CFString 0x7fff7a49fe10 [0x7fff79f4d440]>{contents = "value"} = 2016-04-26 03:15:28 +0000
//                        3 : <CFString 0x7fff7a49fdf0 [0x7fff79f4d440]>{contents = "localized label"} = <CFString 0x7fff7a4a0050 [0x7fff79f4d440]>{contents = "Expires"}
//                        4 : <CFString 0x7fff7a49fdb0 [0x7fff79f4d440]>{contents = "type"} = <CFString 0x7fff7a49ff30 [0x7fff79f4d440]>{contents = "date"}
//                    }

            let label = credential["label"] as? String
            if label == "Expires" {
                expires = credential["value"] as? Date

                // 期限までの残り日数
                lastDays = (Calendar.current as NSCalendar).components([.day], from: expires!, to: Date(), options: []).day!
                lastDays *= -1
            }
        }
    }
    
}

extension Certificate: Equatable {}

func ==(lhs: Certificate, rhs: Certificate) -> Bool {
    let areEqual = lhs.summary == rhs.summary &&
            lhs.expires == rhs.expires

    return areEqual
}
