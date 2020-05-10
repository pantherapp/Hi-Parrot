//
//  AlertService.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import UIKit

class AlertService {
    func alert(title: String, buttonTitle: String, completion: @escaping () -> Void) -> AlertViewVC {
        
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertViewVC") as! AlertViewVC
        alertVC.alertTitle = title
        alertVC.alertButtonTitle = buttonTitle
        alertVC.buttonAction = completion
        
        
        return alertVC
    }
}
