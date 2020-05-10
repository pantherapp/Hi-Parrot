//
//  Splash1VC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class SplashVC: BaseVC {

    @IBOutlet weak var viwNext: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viwNext.roundCorners([.bottomLeft, .topLeft], radius: 25)
    }
    

    // MARK: - Navigation
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- tap function
    @IBAction func onTapNext(_ sender: Any) {
        gotoVC("MainpageNav")
    }
}
