//
//  SettingVC.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class SettingVC: BaseVC {

    @IBOutlet weak var viwTitle: UIView!
    @IBOutlet weak var swiNotification: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    
    // MARK: - custom action
    @IBAction func didTapBack(_ sender: Any) {
        doDismiss()
    }
    
    @IBAction func didTapAboutUs(_ sender: Any) {
        self.gotoNavVC("AboutUsVC")
    }
    
    @IBAction func didTapShareApp(_ sender: UIBarButtonItem) {
        
//        guard
//          let detailBook = detailBook,
//          let url = detailBook.exportToURL()
//          else { return }
        
        let url = "Share test"
            
        let activity = UIActivityViewController(
          activityItems: ["Check out this Record! ", url],
          applicationActivities: nil
        )
        activity.popoverPresentationController?.barButtonItem = sender

        present(activity, animated: true, completion: nil)
    }
    
    @IBAction func didSwitchNotification(_ sender: UISwitch) {
        
        FirebaseAPI.setEnableNotification(sender.isOn){ isSuccess in
            
            if isSuccess == true {
                Defaults[\.enableNoti] = sender.isOn
                print("did switch", sender.isOn)
            } else {
                sender.isOn = !sender.isOn
            }
        }
    }
    
    
    //MARK:- custom function
    func setupView () {
        
        viwTitle.roundCorners([.bottomLeft], radius: 50.0)
        swiNotification.isOn = Defaults[\.enableNoti]
        
    }
    
}
