//
//  MentionModel.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import SwiftyJSON

class MentionModel {
    
    var noti_docId      = ""
    var mention_docid   = ""
    var created_date    = ""
    var comment_docid   = ""
        
    init(noti_docId: String, mention_docid: String, created_date: String, comment_docid: String){
        self.noti_docId     = noti_docId
        self.mention_docid  = mention_docid
        self.comment_docid  = comment_docid
        self.created_date   = created_date
    }
    
}
