//
//  PreviewRecordVC.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import GeoFire


class PreviewRecordVC: BaseVC {
    
    @IBOutlet weak var viwBefore: UIView!
    @IBOutlet weak var viwSend: UIView!
    @IBOutlet weak var butPlay: UIButton!
    @IBOutlet weak var lblPlayTime: UILabel!
    @IBOutlet weak var imgPlayState: UIImageView!
    
    @IBOutlet weak var viwEqualizer: UIView!
    
    var comment_count = 0
    var comment_users = [String]()
    var timeVal = 0
    var recordingTimer: Timer?
    var locationManager = CLLocationManager()
    var doc_rowId  = ""
    var voice_user_udid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viwBefore.roundCorners([.bottomRight, .topRight], radius: 25)
        viwSend.roundCorners([.bottomLeft, .topLeft], radius: 25)
        
        locationManager.requestWhenInUseAuthorization()
        
        let userLocation = locationManager.location?.coordinate
        
        getAddressFromLatLon(lat: userLocation!.latitude, lon: userLocation!.longitude) { addr in
            print("addres result: ====>", addr)
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = ezPlayer {
            player.pause()
            
        }
        doc_rowId  = ""
        voice_user_udid = ""
        print("PreviewRecordVC-viewWillDisappear")
    }
    
    //MARK:- custom function
    @IBAction func onTapedBack(_ sender: Any) {
        doDismiss()
    }

    @IBAction func onTapedSend(_ sender: Any) {
        
        removeEzAudioPlayer()
        ezPlayer = nil
        recordingTimer?.invalidate()
        
        let time = Int64(NSDate().timeIntervalSince1970)
        self.showLoadingView(vc: self, label: "Uploading...")
        
        FirebaseStorageManager().uploadFile(localFile: recordedVoiceURL!, dir: "records/\(myUDID)", serverFileName: "\(time).m4a") { (isSuccess, url) in
            
            if isSuccess == true {
                
                let userLocation = self.locationManager.location?.coordinate
                
                var data = [
                    USER_UDID             : myUDID,
                    USER_DEVICE_NAME      : UIDevice.current.name,
                    USER_SYSTEM_NAME      : UIDevice.current.systemName,
                    USER_SYSTEM_VERSION   : UIDevice.current.systemVersion,
                    USER_TOKEN            : deviceTokenString,
                    USER_LOCATION         : GeoPoint(latitude: userLocation!.latitude, longitude: userLocation!.longitude),
                    ADDRESS               : myAddress,
                    CREATED_TIMESTAMP     : time,
                    VOICE_URL             : "\(url!)",
                    COMMENT_COUNT         : self.comment_count,
                    COMMENT_USERS         : [],
                    LIKE_USERS            : [],
//                    LIKE_COUNT            : 0,
                ] as [String : Any]
                
                if self.doc_rowId == "" {
                    FirebaseAPI.saveMyRecordVoice(data) { (isSuccess, result) in
                        
                        let fileURL = URL(string: url!)!
                        if FileManager().fileExists(atPath: fileURL.path) {
                            do {
                                try FileManager.default.removeItem(at: fileURL)
                                print("Local File deleted successfully")
                            } catch {
                                print("deletion error on local. ==>", error.localizedDescription)
                            }
                        }
                        
                        self.hideLoadingView()
                        
                        if isSuccess == true {
                            self.doRootDismiss()
                        } else {
                            print("Your request is failed")
                        }
                    }
                }
                else {

                    if !self.comment_users.contains(myUDID) {
                        self.comment_users.append(myUDID)
                    }
                    data[COMMENT_USERS] = self.comment_users
                    
                    FirebaseAPI.saveCommentVoice(self.doc_rowId , data) { (isSuccess, comment_docId) in
                        
                        let fileURL = URL(string: url!)!
                        if FileManager().fileExists(atPath: fileURL.path) {
                            do {
                                try FileManager.default.removeItem(at: fileURL)
                                print("Local File deleted successfully")
                            } catch {
                                print("deletion error on local. ==>", error.localizedDescription)
                            }
                        }
                        
                        if isSuccess == true {
                            
                            /// badgeCount is one added  value 1;
                            FirebaseAPI.checkAndSaveMention(self.voice_user_udid, self.doc_rowId) { result, state, user_token, badgeCount in
                                if result == true {
                                    let state = state as! Bool
                                    if state == true {
                                        let sender = PushNotificationSender()
                                        sender.sendPushNotification(to: user_token, title: APP_NAME, body: CONSTANT.NOTI_BODY, badgeCount: badgeCount)
                                    }
                                } else {}

                                self.doRootDismiss()
                                self.hideLoadingView()
                            }
                            
                        } else {
                            print("Your request is failed")
                            self.hideLoadingView()
                        }
                    }
                }
            } else {
                self.hideLoadingView()
            }
        }
    }
    
    @IBAction func didTapPlayAudio(_ sender: UIButton) {
        
        if ezPlayer == nil {
            
            addEqualizerView(parentView: viwEqualizer)
            startEzPlayingAudioFile(audioLocalUrl: recordedVoiceURL!) { isSuccess, msg in
                if isSuccess == true {
                    self.ezPlayer?.delegate = self
                }
            }
            
            imgPlayState.isHidden = true
            self.lblPlayTime.text = "00 : 00"
            sender.setImage(UIImage(named: "ic_stop"), for: .normal)
            timeVal = 0
            recordingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            
        } else {
            removeEzAudioPlayer()
            equalizerView?.removeFromSuperview()
            imgPlayState.isHidden = false
            
            recordingTimer?.invalidate()
            sender.setImage(UIImage(named: "ic_play1"), for: .normal)
        }
    }
    
    @objc func runTimedCode () {
            timeVal += 1
            
            let minuteString = String(format: "%02d", Int(timeVal / 60))
            let secondString = String(format: "%02d", Int(timeVal %  60))
    //        self.lblRecordingTime.text = "\(hourString):\(minuteString):\(secondString)"
            self.lblPlayTime.text = "\(minuteString) : \(secondString)"
        }
}

//MARK:- EZAudioPlayer delegate
extension PreviewRecordVC: EZAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
        
        DispatchQueue.main.async {
            if self.ezPlayer != nil && self.ezPlayer!.isPlaying {
                self.equalizerView?.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
    
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, reachedEndOf audioFile: EZAudioFile!) {
        
        DispatchQueue.main.async {
            self.recordingTimer?.invalidate()
            self.butPlay.setImage(UIImage(named: "ic_play1"), for: .normal)
            self.ezPlayer = nil
            self.equalizerView?.removeFromSuperview()
            self.imgPlayState.isHidden = false
        }
    }
}
