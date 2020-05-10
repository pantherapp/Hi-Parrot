//
//  AboutUsVC.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class AboutUsVC: BaseVC {

    @IBOutlet weak var viwTitle: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    //MARK:- custom function
    func setupView () {
        
        viwTitle.roundCorners([.bottomLeft], radius: 50.0)
    }
    
    // MARK: - custom action
    @IBAction func didTapBack(_ sender: Any) {
        doDismiss()
    }
    
}
