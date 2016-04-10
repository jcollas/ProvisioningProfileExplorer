//
//  ProvisioningProfile.swift
//  ProvisioningProfileExplorer
//
//  Created by hirauchi.shinichi on 2016/04/10.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import Cocoa

class ProvisioningProfile: NSObject {

    private var _path = ""

    private var _name: NSString? = nil
    var name:NSString {
        get{
            return _name!
        }
    }

    var uuid: NSString? = nil
    var teamName: NSString? = nil



    private var _expirationDate: NSDate? = nil
    var expirationDate:NSString{
        get{
            return LocalDate(_expirationDate!)
        }
    }

    private var _createDate: NSDate? = nil
    var createDate:NSString{
        get{
            return LocalDate(_createDate!)
        }
    }


    init(path:String){
        super.init()

        _path = path
        Interpretation()
    }


    func Interpretation(){

        // ファイルの読み込み
        guard let encryptedData = NSData(contentsOfFile: _path) else {
            return
        }
        // データの復号
        guard let plistData = decode(encryptedData) else{
            return
        }
        //プロパティリストへの変換
        guard let plist = try? NSPropertyListSerialization.propertyListWithData(plistData, options: NSPropertyListMutabilityOptions.MutableContainersAndLeaves, format: nil) as! NSDictionary else {
            return
        }

        // DEBUG
        for key in plist.allKeys {
            //print("key:\(key) value:\(plist.objectForKey(key))")
        }

        // 名前
        _name = plist.objectForKey("Name") as! NSString

        // 作成年月日
        _createDate = plist.objectForKey("CreationDate") as! NSDate

        // 有効期限
        _expirationDate = plist.objectForKey("ExpirationDate") as! NSDate

        // UUID
        uuid = plist.objectForKey("UUID") as! NSString

        // TeamName
        teamName = plist.objectForKey("TeamName") as! NSString

//        id creationDate = [propertyList objectForKey:@"CreationDate"];
//        if ([creationDate isKindOfClass:[NSDate class]]) {
//            NSDate *date = (NSDate *)value;
//            //synthesizedValue = [dateFormatter stringFromDate:date];
//            //[synthesizedInfo setObject:synthesizedValue forKey:@"CreationDateFormatted"];
//
//            NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
//            if (dateComponents.day == 0) {
//                synthesizedValue = @"Created today";
//            } else {
//                synthesizedValue = [NSString stringWithFormat:@"Created %zd day%s ago", dateComponents.day, (dateComponents.day == 1 ? "" : "s")];
//            }
//            //[synthesizedInfo setObject:synthesizedValue forKey:@"CreationSummary"];
//        }




    }

    // 暗号データの復号
    func decode(encryptedData:NSData) -> NSData? {
        var decoder: CMSDecoder?;
        var decodedData: CFData?;

        CMSDecoderCreate(&decoder);
        CMSDecoderUpdateMessage(decoder!, encryptedData.bytes, encryptedData.length);
        CMSDecoderFinalizeMessage(decoder!);
        CMSDecoderCopyContent(decoder!, &decodedData);
        return decodedData
    }

    // ローカルタイムでのNSDate表示
    func LocalDate(date: NSDate) -> NSString {
        let calendar = NSCalendar.currentCalendar()

        //let calendar = NSCalendar(identifier: NSGregorianCalendar)
        //let calendar = NSCalendar(identifier: NSJapaneseCalendar)

        let comps = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate:date)
        let year = comps.year
        let month = comps.month
        let day = comps.day
        let hour = comps.hour
        let minute = comps.minute
        _ = comps.second

        return NSString(format: "%04d/%02d/%02d %02d:%02d", year,month,day,hour,minute)
//        return "\(year)/\(month)/\(day) \(hour):\(minute)"
    }

    func generateHTML() -> String {
        let html = NSMutableString()

        html.appendString("<html>")
        html.appendString("<style>")
//        html.appendString(".name{ color:ff0000; background-color:#FFCACA }")
        html.appendString("body{ color:000000; font-size:12px; font-family: \"Hiragino Kaku Gothic ProN\", sans-serif;}")
//        html.appendString("ul{ list-style-type: none;margin: 0 0 0 1.5em;}")
        html.appendString(".name{ color:006600; font-size:16px;margin:20,0;font-weight: bold;}")
        html.appendString("</style>")

        html.appendString(String(format: "<br><span class=\"name\">%@</span>",_name!))
        html.appendString(String(format: "<br>Profile UUID: %@",uuid!))
        html.appendString(String(format: "<br>Profile Team: %@",teamName!))
        html.appendString(String(format: "<br>Creation Date: %@",LocalDate(_createDate!)))
        html.appendString(String(format: "<br>Expiretion Date: %@",LocalDate(_expirationDate!)))
        html.appendString("</html>")

        return html as String
    }
}
