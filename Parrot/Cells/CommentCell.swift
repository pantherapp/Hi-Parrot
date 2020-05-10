//
//  CommentCell.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblCommentUser: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    
    @IBOutlet weak var butPlay: UIButton!
    @IBOutlet weak var butReport: UIButton!
    @IBOutlet weak var butLike: UIButton!
    
    @IBOutlet weak var viwPlayState: UIView!
    @IBOutlet weak var imgPlayState: UIImageView!
    
    var parrent_voice_udid = ""
    
    var entity:VoiceModel! {
                
        didSet {
            lblCreatedDate.text = getDateString(entity.created_date)
            lblAddress.text = entity.user_address
            lblAddress.numberOfLines = 0
            lblLikeCount.text = "\(entity.like_users.count)"
            
            
            if entity.is_like == true {
                butLike.setImage(UIImage(named: "ic_like_fill")!, for: .normal)
            } else {
                butLike.setImage(UIImage(named: "ic_like")!, for: .normal)
            }
        }
    }
}
