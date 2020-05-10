//
//  AppConstant.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

let APP_NAME = "Parrot"
let kColorOrange = UIColor(hex: "FDB913")

let COMMENTS         = "comments"
let REPORTS          = "reports"
let MENTIONS         = "mentions"



let DOC_ROWID                   = "doc_rowid"
let USER_UDID                   = "user_udid"
let USER_DEVICE_NAME            = "user_device_name"
let USER_SYSTEM_NAME            = "user_device_systemName"
let USER_SYSTEM_VERSION         = "user_device_systemVersion"
let USER_TOKEN                  = "user_token"
let USER_LOCATION               = "location"
let CREATED_TIMESTAMP           = "created_timestamp"
let VOICE_URL                   = "voice_url"
let COMMENT_COUNT               = "comment_count"
let COMMENT_USERS               = "comment_users"
let LIKE_COUNT                  = "like_count"
let IS_LIKE                     = "is_like"
let LIKE_USERS                  = "like_users"
let REPORT_USERS                = "report_users"
let ADDRESS                     = "address"

let ENABLE_NOTI                 = "state"
let COMMENTTED_DOCID            = "comment_docid"
let BADGE_COUNT                 = "badge_count"



let NON_REGISTER_NOTI_SETTING  = "non register notification setting"

struct CONSTANT {
    static let APP_NAME         = "Parrot"
    static let MAIL_SUBJECT     = "Parrot Link"
    static let MAIL_BODY        = "Please follow the below link to get your voice from Parrot.\n\n"
    static let NOTI_BODY        = "Someone has commented on your voice."

}

//enum ListenerType : String {
//    case added      = "you moved forward"
//    case chanaged   = "you moved backwards"
//    case remove     = "you moved to the left"
//    
//    func printDirection() -> String {
//        return self.rawValue
//    }
//}

//var action = MoveDirection.right;
//print(action.printDirection())// this will print out "you moved to the right"
