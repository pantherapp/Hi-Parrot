//
//  AlertReportVC.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class AlertViewVC: BaseVC {

    @IBOutlet weak var viwContent: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var butOK: UIButton!
    
    var alertTitle = String()
    var alertBody = String()
    var alertButtonTitle = String()
    var buttonAction: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    //MARK:- custom function
    func setupView() {
        viwContent.roundCorners([.bottomLeft, .topRight], radius:60)
        
        lblTitle.text = alertTitle
        butOK.setTitle(alertButtonTitle, for: .normal)
    }
    
    //MARK:- action function
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapOK(_ sender: Any) {
        dismiss(animated: true)
        buttonAction?()
    }

}
