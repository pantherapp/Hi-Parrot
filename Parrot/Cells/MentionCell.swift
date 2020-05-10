//
//  MentionCell.swift
//

import UIKit

class MentionCell: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    
    var entity:MentionModel! {
            
        didSet {
            lblDate.text = getDateString(entity.created_date)
        }
    }
}
