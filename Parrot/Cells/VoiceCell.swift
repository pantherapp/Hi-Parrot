//
//  VoiceCell.swift
//

import UIKit

class VoiceCell: UITableViewCell {
    
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var butPlay: UIButton!
    @IBOutlet weak var butReport: UIButton!
    @IBOutlet weak var butLike: UIButton!
    @IBOutlet weak var butComment: UIButton!
    
    @IBOutlet weak var imgPlayState: UIImageView!
    @IBOutlet weak var viwPlayState: UIView!
    @IBOutlet weak var viwMain: UIView!


    var entity:VoiceModel! {
            
        didSet {
            lblCreatedDate.text = getDateString(entity.created_date)
            lblCommentCount.text = "@ \(entity.comment_count)"
            lblAddress.text = entity.user_address
            lblAddress.numberOfLines = 0
            lblLikeCount.text = "\(entity.like_users.count)"
            lblCommentCount.isHidden = true
            
            if entity.user_udid != myUDID {
                if entity.is_like == true {
                    butLike.setImage(UIImage(named: "ic_like_fill")!, for: .normal)
                } else {
                    butLike.setImage(UIImage(named: "ic_like")!, for: .normal)
                }
            }
            
        }
    }
}
