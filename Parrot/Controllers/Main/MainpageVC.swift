//
//  MainpageVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

var is_started = false

class MainpageVC: BaseVC {

    @IBOutlet weak var lblBadgeCount: PaddingLabel!
    @IBOutlet weak var viwTabbarSub: UIView!
    @IBOutlet weak var viwContent: UIView!
    
    @IBOutlet weak var imgNear: UIImageView!
    @IBOutlet weak var imgMention: UIImageView!
    @IBOutlet weak var imgMe: UIImageView!
//    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var nearbyVC: NearbyVC!
    var mentionVC: MentionVC!
    var myVoiceVC: MyVoiceVC!
    
    var oldTabIndex = 0
    var selectedTabIndex = 0
    var markImg = [UIImageView]()
    var moveDirection = CATransitionSubtype.fromLeft
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadTabContent()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateBadgeNumber), name: Notification.Name("changedBadgeCount"), object: nil)
        
        updateBadgeNumber()
        
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174" //"ca-app-pub-6735851363199770/3505163103" //
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeMade(_:)))
        leftRecognizer.direction = .left
        self.view.addGestureRecognizer(leftRecognizer)
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeMade(_:)))
        rightRecognizer.direction = .right
        self.view.addGestureRecognizer(rightRecognizer)
        
        print("MainpageVC-viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MainpageVC-viewDidAppear")
                
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("MainpageVC-viewDidDisappear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.pause()
        }
        print("MainpageVC-viewWillDisappear")
    }
    
    
    //MARK:- tap action function
    @IBAction func onTapedTabbarButton(_ sender: UIButton) {
        
        if is_started == false {
            return
        }
        
        selectedTabIndex = sender.tag
        moveDirection = oldTabIndex > selectedTabIndex ? CATransitionSubtype.fromLeft : .fromRight
        
        showSelectedTabMark(sender.tag)
        loadTabContent()
        
    }
    
    @IBAction func didTapSetting(_ sender: UIButton) {
        
        if is_started == false {
            return
        }
        
        if player?.isPlaying == true {
            player?.stop()
            player = nil
        }
        
        self.gotoNavVC("SettingVC")
    }
    
    //MARK:- custom function
    @objc func swipeMade(_ sender: UISwipeGestureRecognizer) {
        if is_started == false {
            return
        }
        
        if sender.direction == .left {
            selectedTabIndex  += 1
        }
        
        if sender.direction == .right {
            selectedTabIndex  -= 1
        }
        
        moveDirection = oldTabIndex > selectedTabIndex ? CATransitionSubtype.fromLeft : .fromRight
        if selectedTabIndex == 3 {
            selectedTabIndex = 0
        } else if selectedTabIndex == -1 {
            selectedTabIndex = 2
        }
        
        loadTabContent()
    }
    
    func setupView() {
        
        updateBadgeNumber()
        
        markImg = [imgNear, imgMention, imgMe]
        viwTabbarSub.roundCorners([.bottomLeft], radius: 50.0)
        
        let rectInfo = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        nearbyVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NearbyVC") as! NearbyVC)
        nearbyVC.view.frame = rectInfo
        
        mentionVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MentionVC") as! MentionVC)
        mentionVC.view.frame = rectInfo
        
        myVoiceVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyVoiceVC") as! MyVoiceVC)
        myVoiceVC.view.frame = rectInfo
    }
    
    @objc func updateBadgeNumber() {
        lblBadgeCount.text = "\(UIApplication.shared.applicationIconBadgeNumber)"
        if UIApplication.shared.applicationIconBadgeNumber == 0 {
            lblBadgeCount.isHidden = true
        } else {
            lblBadgeCount.isHidden = false
        }
    }
    
    func loadTabContent() {
        
        if player?.isPlaying == true {
            player?.stop()
            player = nil
        }
        
        let transition      = CATransition()
        transition.duration = 0.3;
        transition.type     = .moveIn
        transition.subtype  = moveDirection
        if oldTabIndex != selectedTabIndex {
            viwContent.layer.add(transition, forKey: nil)
        }
        
        if selectedTabIndex == 0 {
            let subVC = self.nearbyVC
            subVC!.view.frame = CGRect(x: 0, y: 0, width: viwContent.bounds.width, height: viwContent.bounds.height)
            subVC!.parentVC = self
            viwContent.addSubview(subVC!.view)
            
        }
        else if selectedTabIndex == 1 {
            
            let subVC = self.mentionVC
            subVC!.view.frame = CGRect(x: 0, y: 0, width: viwContent.bounds.width, height: viwContent.bounds.height)
            subVC!.parentVC = self
            viwContent.addSubview(subVC!.view)
        }
        else if selectedTabIndex == 2 {
            let subVC = self.myVoiceVC
            subVC!.view.frame = CGRect(x: 0, y: 0, width: viwContent.bounds.width, height: viwContent.bounds.height)
            subVC!.parentVC = self
            viwContent.addSubview(subVC!.view)
        }
        
        showSelectedTabMark(selectedTabIndex)
        
        oldTabIndex = selectedTabIndex

    }
    
    func showSelectedTabMark(_ index: Int) {
        
        for i in 0 ..< 3 {
            if i == index {
                markImg[i].isHidden = false
            } else {
                markImg[i].isHidden = true
            }
        }
    }

}


extension MainpageVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        // Add banner to view and add constraints as above.
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
