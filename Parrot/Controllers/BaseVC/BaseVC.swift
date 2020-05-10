//
//  BaseVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults
import MBProgressHUD
import CoreLocation


class BaseVC: UIViewController {
    
    var hud: MBProgressHUD?
    
    var ezPlayer: EZAudioPlayer?
    var equalizerView: DPMainEqualizerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        // to enable swiping left when back button in navigation bar customized
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //MARK:- alert function
    internal func showAlert(title: String?, message: String?, okButtonTitle: String, cancelButtonTitle: String?, okClosure: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: okButtonTitle, style: .default, handler: { (action: UIAlertAction) in
            if okClosure != nil {
                okClosure!()
            }
        })
        alertController.addAction(yesAction)
        if cancelButtonTitle != nil {
            let noAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (action: UIAlertAction) in

            })
            alertController.addAction(noAction)
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        DispatchQueue.main.async(execute:  {
            self.present(alert, animated: true, completion: nil)
        })
    }

    func showError(_ message: String!) {
        showAlertDialog(title: "", message: message, positive:"OK", negative: nil)
    }

    func showAlert(_ message: String!) {
        showAlertDialog(title: "", message: message, positive: "OK", negative: nil)
    }
   
/*
    //MARK:- Toast function
    func showToast(_ message : String) {
        self.view.makeToast(message)
    }
    
    func showToast(_ message : String, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = .center) {
        self.view.makeToast(message, duration: duration, position: position)
    }
*/
    
    //MARK:- goto navigation view controller function
    func gotoNavVC (_ nameVC: String) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        toVC!.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(toVC!, animated: true)
    }
    
    func doDismiss(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func doRootDismiss(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:- goto view controller function
    func gotoVC(_ nameVC: String){
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        toVC!.modalPresentationStyle = .fullScreen
        self.present(toVC!, animated: true, completion: nil)
    }
    
    //set dispaly effect
    func setTransitionType(_ direction : CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = direction
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.linear)
        
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    
    //MARK:- progressHUD function
    func showProgressHUD(view : UIView, mode: MBProgressHUDMode = .annularDeterminate) -> MBProgressHUD {
    
        let hud = MBProgressHUD .showAdded(to:view, animated: true)
        hud.mode = mode
        hud.label.text = "Loading";
        hud.animationType = .zoomIn
        hud.tintColor = UIColor.white
        hud.contentColor = kColorOrange
        return hud
    }
    
    func showLoadingView(label: String = "") {

        let window = UIApplication.shared.key!.rootViewController

        if window != nil {
            hud = MBProgressHUD .showAdded(to: window!.view, animated: true)
        } else {
            hud = MBProgressHUD()
        }
        
        if label != "" {
            hud!.label.text = label;
        }
        
        hud!.mode = .indeterminate
        hud!.animationType = .zoomIn
        hud!.tintColor = UIColor.gray
        hud!.contentColor = kColorOrange
    }
    
    func showLoadingView(vc: UIViewController, label: String = "") {
        
        hud = MBProgressHUD .showAdded(to: vc.view, animated: true)
        
        if label != "" {
            hud!.label.text = label;
        }
        hud!.mode = .indeterminate
        hud!.animationType = .zoomIn
        hud!.tintColor = UIColor.gray
        hud!.contentColor = kColorOrange
    }
    
    func hideLoadingView() {
       if let hud = hud {
           hud.hide(animated: true)
       }
    }
    
    // setting EqualizerView
    func addEqualizerView(parentView: UIView) {
        let rect = CGRect(x: parentView.bounds.minX,
            y: parentView.bounds.minY,
            width: parentView.bounds.width,
            height: parentView.bounds.height
        )
        
        let settings: DPEqualizerSettings = DPEqualizerSettings.create(by: .rolling)
        settings.gain                   = 6
        settings.gravity                = 10
        settings.numOfBins              = 30
        settings.maxBinHeight           = parentView.bounds.size.height * 1.5;
        settings.plotType               = .rolling;
        settings.equalizerType          = .rolling;
        settings.equalizerBackgroundColors = [UIColor.clear]
        settings.equalizerBinColors        = [UIColor.black]
        settings.fillGraph                 = true
        settings.hightFrequencyColors = [UIColor.red]
        settings.lowFrequencyColors = [UIColor.yellow]
        
        self.equalizerView = DPRollingEqualizerView(frame: rect, andSettings: settings)
        parentView.insertSubview(equalizerView!, belowSubview: self.view)
        
        
//        audioSettings.maxFrequency = 7000; //
//        audioSettings.minFrequency = 400; //
//        audioSettings.numOfBins = 40; //
//        audioSettings.padding = 2 / 10.0; //
//        audioSettings.gain = 10; //
//        audioSettings.gravity = 10; ///
//
//        audioSettings.maxBinHeight = [UIScreen mainScreen].bounds.size.height;
//        audioSettings.plotType = DPPlotTypeBuffer;
//        audioSettings.equalizerType = DPHistogram;
//
//        audioSettings.equalizerBinColors = [[NSMutableArray alloc] initWithObjects:[UIColor blueColor], nil];
//        audioSettings.lowFrequencyColors = [[NSMutableArray alloc] initWithObjects:[UIColor greenColor], nil];
//        audioSettings.hightFrequencyColors = [[NSMutableArray alloc] initWithObjects:[UIColor purpleColor], nil];
//        audioSettings.equalizerBackgroundColors = [[NSMutableArray alloc] initWithObjects:[UIColor whiteColor], nil];

    }
    
    func startEzPlayingAudioFile(audioLocalUrl: URL, completion: @escaping (_ result: Bool, _ msg: String ) -> ()) {
        
        if !(self.ezPlayer != nil) {
            
            if FileManager().fileExists(atPath: audioLocalUrl.path) {
                let audio: EZAudioFile = EZAudioFile(url: audioLocalUrl as URL)
                self.ezPlayer = EZAudioPlayer(audioFile: audio)
                self.ezPlayer?.play()
                
                completion(true, "")
            } else {
                completion(false, "No exist file, ")
            }
        }
    }
    
    func removeEzAudioPlayer() {
        
        if self.ezPlayer != nil && self.ezPlayer!.isPlaying {
            self.ezPlayer!.pause()
        }
        
        self.ezPlayer = nil
        // set timer...
    }
    
    
    //MARK:-
    func getAddressFromLatLon(lat: Double, lon: Double, handler: @escaping (String) -> Void) {
        
        let location = CLLocation(latitude: lat, longitude: lon)
        let geoCoder: CLGeocoder = CLGeocoder()

        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }

            var addressString : String = ""

            let pm = placemarks! as [CLPlacemark]
            if pm.count > 0 {
                let pm = placemarks![0]
                print(pm.country)
                print(pm.locality)
                print(pm.subLocality)
                print(pm.thoroughfare)
                print(pm.postalCode)
                print(pm.subThoroughfare)
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                
                if pm.country != nil {
                    addressString = addressString + pm.country!
                }
//                if pm.postalCode != nil {
//                    addressString = addressString + pm.postalCode! + " "
//                }
                
                // Zip code
                if let zip = pm.addressDictionary?["ZIP"] as? String {
                    print("zip====>", zip)
                }
                
                print(addressString)
          }
            
            myAddress =  addressString
            handler(addressString)
        })
    }
    
    /*
    // Using closure
    func getAddress(handler: @escaping (String) -> Void) {
        var address: String = ""
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        //selectedLat and selectedLon are double values set by the app in a previous process

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

            // Place details
            var placeMark: CLPlacemark?
            placeMark = placemarks?[0]

            // Address dictionary
            //print(placeMark.addressDictionary ?? "")

            // Location name
            if let locationName = placeMark?.addressDictionary?["Name"] as? String {
                address += locationName + ", "
            }

            // Street address
            if let street = placeMark?.addressDictionary?["Thoroughfare"] as? String {
                address += street + ", "
            }

            // City
            if let city = placeMark?.addressDictionary?["City"] as? String {
                address += city + ", "
            }

            // Zip code
            if let zip = placeMark?.addressDictionary?["ZIP"] as? String {
                address += zip + ", "
            }

            // Country
            if let country = placeMark?.addressDictionary?["Country"] as? String {
                address += country
            }

           // Passing address back
           handler(address)
        })
    }*/
}


//MARK:- swiftyuserDefaultsKeys extention
extension DefaultsKeys {
    var enableNoti : DefaultsKey<Bool>{ return .init("enableNoti", defaultValue: false)}
}

//MARK:- UIViewController extention
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


