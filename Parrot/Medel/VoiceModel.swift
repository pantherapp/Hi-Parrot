
//
//  VoiceModel.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import SwiftyJSON

class VoiceModel {
    var doc_rowid           = ""
    var user_udid           = ""
    var user_device_name    = ""
    var user_system_name    = ""
    var user_system_version = ""
    var user_token          = ""
    var created_date        = ""
    var voice_url           = ""
    var comment_count       = 0
    var comment_users       = [String]()
    var like_users          = [String]()
    var is_like             = false
    var report_users        = [String]()
    var is_report           = false
    var user_address        = ""
    
    var is_playing          = false
    
    
    
    init(doc_rowid: String, user_udid: String, user_device_name: String, user_system_name: String, user_system_version: String,
         user_token: String, created_date: String, voice_url: String, comment_users: [String], like_users: [String], report_users: [String], user_address: String){
        
        self.doc_rowid          = doc_rowid
        self.user_udid          = user_udid
        self.user_device_name   = user_device_name
        self.user_system_name   = user_system_name
        self.user_system_version = user_system_version
        self.user_token         = user_token
        self.created_date       = created_date
        self.voice_url          = voice_url
//        self.comment_count      = comment_count
        self.comment_users      = comment_users
        self.like_users         = like_users
        self.is_like            = like_users.contains(myUDID)
        self.report_users       = report_users
        self.is_report          = report_users.contains(myUDID)
        self.user_address       = user_address
    }

}
