//
//  MyVoiceCommentCell.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import UIKit

class MyVoiceCommentCell: UITableViewCell {
    
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var butPlay: UIButton!
    @IBOutlet weak var butReport: UIButton!
    @IBOutlet weak var viwPlayState: UIView!
    @IBOutlet weak var imgPlayState: UIImageView!
    
    var entity:VoiceModel! {
                    
        didSet {
//            lblCreatedDate.text = entity.created_date
        }
    }
}
