//
//  XMessage.swift
//  SecundoIOS
//
//  Created by YajieXing on 15/10/2.
//  Copyright (c) 2015年 Yajie Xing. All rights reserved.
//

import Foundation

let XMSG_SPEAK      = 0x01
let XMSG_MOVE       = 0x02
let XMSG_INIT       = 0x04
let XMSG_DISCONN    = 0x08
let XMSG_USER       = 0x10
let XMSG_ID         = 0x20

struct  Coordinate{
    var longitude: Double
    var latitude: Double
    init(){
        longitude = 0
        latitude = 0
    }
}

struct Data{
    var words: String
    var loc: Coordinate
    var skin: Int
    init(){
        words = ""
        loc = Coordinate()
        skin = 0
    }
}

//Ugh, full of ugly codes...
class XMessage{
    
    var msgType = Int()
    var userID = Int()
    var data = Data()

    
    init?(_ jsonString: String){
        if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            msgType = json["msg_type"].intValue
            userID = json["user_id"].intValue
            switch msgType {
            case XMSG_SPEAK:
                data.words = json["words"].stringValue
            case XMSG_MOVE:
                data.loc.longitude = json["loc"]["longitude"].doubleValue
                data.loc.latitude = json["loc"]["latitude"].doubleValue
            case XMSG_INIT:
                data.loc.longitude = json["loc"]["longitude"].doubleValue
                data.loc.latitude = json["loc"]["latitude"].doubleValue
                data.skin = json["skin"].intValue
            case XMSG_USER:
                data.words = json["words"].stringValue
                data.loc.longitude = json["loc"]["longitude"].doubleValue
                data.loc.latitude = json["loc"]["latitude"].doubleValue
                data.skin = json["skin"].intValue
            default:
                 break
            }
        } else{
            return nil
        }
    }
    
    func toJSON() -> String{
        var jsonString = String()
        switch msgType {
        case XMSG_SPEAK:
            let json: JSON = [
                "msg_type"  : msgType,
                "user_id"   : userID,
                "words"     : data.words
            ]
            jsonString = json.rawString()!
        case XMSG_MOVE:
            let json: JSON = [
                "msg_type"  : msgType,
                "user_id"   : userID,
                "loc"       : [
                    "longitude" : data.loc.longitude,
                    "latitude"  : data.loc.latitude
                ]
            ]
            jsonString = json.rawString()!
        case XMSG_INIT:
            let json: JSON = [
                "msg_type"  : msgType,
                "user_id"   : userID,
                "loc"       : [
                    "longitude" : data.loc.longitude,
                    "latitude"  : data.loc.latitude
                ],
                "skin"      : data.skin
            ]
            jsonString = json.rawString()!
        case XMSG_USER:
            let json: JSON = [
                "msg_type"  : msgType,
                "user_id"   : userID,
                "words"     : data.words,
                "loc"       : [
                    "longitude" : data.loc.longitude,
                    "latitude"  : data.loc.latitude
                ],
                "skin"      : data.skin
            ]
            jsonString = json.rawString()!
        default:
            let json: JSON = [
                "msg_type"  : msgType,
                "user_id"   : userID
            ]
            jsonString = json.rawString()!
        }
        return jsonString
    }
    
}





