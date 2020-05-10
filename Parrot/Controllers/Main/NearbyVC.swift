//
//  NearbyVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    
    var dataSource = [VoiceModel]()
    var parentVC: MainpageVC?
    
    let alertService = AlertService()
    var locationManager = CLLocationManager()
//    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var playingItemIndex = -1
    let distance = 1000.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        
        //loadTableData()
        
        addListenerMyRecordVoice()
        
        checkUsersLocationServicesAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    
    //MARK:- load tableview data
    func loadTableData() {
        
        if is_started == false {
            self.showLoadingView(vc: self, label: "Loading...")
        }
        
        let userLocation = self.locationManager.location?.coordinate
        
        FirebaseAPI.getNearbyVoice(myLocation: userLocation!, distance: distance) {(isSuccess, result) in
            if isSuccess == true {
                
                self.dataSource = result as! [VoiceModel]
                if self.dataSource.count > 0 {
                    self.view.backgroundColor = UIColor(named: "bg_white")
                }
                
                self.dataSource.sorted(by: { $0.created_date > $1.created_date })
                self.uiTableview.setNeedsLayout()
                self.uiTableview.layoutIfNeeded()
                self.uiTableview.reloadData()
            } else {
//                self.showError("Your request is failed")
            }
            
            self.hideLoadingView()
            is_started = true
        }
        
//        uiTableview.setNeedsLayout()
//        uiTableview.layoutIfNeeded()
//        uiTableview.reloadData()
    }
    
    func addListenerMyRecordVoice() {
        
        let userLocation = self.locationManager.location?.coordinate
        
            FirebaseAPI.addListenerNearVoice(myLocation: userLocation!, distance: distance ) {(isSuccess, result, changedType) in
                
                if isSuccess == true {
                    let changedData = result as! [VoiceModel]
                    if changedType == .added {
                        
                        for one in changedData {
                            self.dataSource.append(one)
                        }
                    }
                    else {
                        for one in changedData {
    //                        self.dataSource.contains { $0.doc_rowid == one.doc_rowid }
                            var matchedIndex = -1
                            for index in 0 ..< self.dataSource.count {
                                if one.doc_rowid == self.dataSource[index].doc_rowid {
                                    matchedIndex = index
                                    break
                                }
                            }
                            
                            if matchedIndex > -1 {
                                if changedType == .removed {
                                    
                                    let destination = localURL + self.dataSource[matchedIndex].created_date + ".m4a"
                                    let fileURL = URL(string: destination)!
                                    if FileManager().fileExists(atPath: fileURL.path) {
                                        do {
                                            try FileManager.default.removeItem(at: fileURL)
                                            
                                            print("Local File deleted successfully")
                                        } catch {
                                            print("deletion error on local. ==>", error.localizedDescription)
                                        }
                                    }
                                    self.dataSource.remove(at: matchedIndex)
                                    
                                } else {
                                    self.dataSource[matchedIndex] = one
                                }
                            }
                        }
                    }
                    
                    if self.dataSource.count > 0 {
                        self.view.backgroundColor = UIColor(named: "bg_white")
                    } else {
                        self.view.backgroundColor = UIColor(named: "music_bg_1")
                    }
                    
                    self.dataSource.sorted(by: { $0.created_date > $1.created_date })
                    self.uiTableview.layoutIfNeeded();
                    self.uiTableview.reloadData()
                    
                }
                else {
                    self.showError("Your request is failed")
                }
            }
        }

    
    //MARK:- record start functions
    @IBAction func onTapedRecord(_ sender: Any) {
 
        parentVC!.gotoNavVC("RecordingVC")
    }
    
    //MARK:- cell's functions
    @IBAction func onTapedPlay(_ sender: UIButton) {
        
        let audioUrl = localURL + dataSource[sender.tag].created_date + ".m4a"
        
        if (playingItemIndex == -1) {
            
            playingItemIndex = sender.tag
            dataSource[sender.tag].is_playing = true
            
            startEzPlayingAudioFile(audioLocalUrl: URL(string: audioUrl)!) { isSuccess, msg in
                if isSuccess == true {
                    self.ezPlayer?.delegate = self
                    self.uiTableview.reloadRows(at: [IndexPath(row: self.playingItemIndex, section: 0)], with: .none)
                }
            }
            
        } else if (playingItemIndex == sender.tag) {
            
            dataSource[sender.tag].is_playing = false
            self.uiTableview.reloadRows(at: [IndexPath(row: self.playingItemIndex, section: 0)], with: .none)
            playingItemIndex = -1
            
            removeEzAudioPlayer()
            
        } else {
            let prev = playingItemIndex;
            dataSource[prev].is_playing = false
            playingItemIndex = sender.tag
            dataSource[playingItemIndex].is_playing = true
            uiTableview.reloadRows(at: [IndexPath(row: prev, section: 0), IndexPath(row: playingItemIndex, section: 0)], with: .none)
            
            startEzPlayingAudioFile(audioLocalUrl: URL(string: audioUrl)!) { isSuccess, msg in
                
                if isSuccess == true {
                    self.ezPlayer?.delegate = self
                    self.uiTableview.reloadRows(at: [IndexPath(row: self.playingItemIndex, section: 0)], with: .none)
                }
            }
        }
    }
    
    @IBAction func onTapedReport(_ sender: UIButton) {
        
        var report_users = dataSource[sender.tag].report_users
        
        if report_users.contains(myUDID) {
            self.showAlert("You have already reported on this voice.")
        }
        else {
            report_users.append(myUDID)
            
            let alertVC = alertService.alert(title: "REPORT VOICE", buttonTitle: "OK") {[weak self] in
                
                self!.showLoadingView(vc: self!, label: "Requsting...")
                FirebaseAPI.reportNearVoice(self!.dataSource[sender.tag].doc_rowid, report_users) {(isSuccess) in
                    if isSuccess == true {
                        self!.showAlert("Your report has been successfully submitted.")
                    } else {
                        self!.showError("Your request is failed.")
                    }
                    
                    self!.hideLoadingView()
                }
            }
            present(alertVC, animated: true)
        }
    }
    
    @IBAction func onTapedLike(_ sender: UIButton) {
        
        self.showLoadingView(vc: self, label: "Requsting...")
        var like_users = dataSource[sender.tag].like_users
        
        if dataSource[sender.tag].is_like == true {
            like_users.remove(at: like_users.firstIndex(of: myUDID)!)
        } else {
            like_users.append(myUDID)
        }
        
        FirebaseAPI.setLikeNearVoice(dataSource[sender.tag].doc_rowid, like_users) {(isSuccess) in
            if isSuccess == true {}
            else {
                self.showError("Your request is failed.")
            }
            
            self.hideLoadingView()
        }
    }
    
    @IBAction func onTapedComment(_ sender: UIButton) {
        let toVC = (self.storyboard?.instantiateViewController( withIdentifier: "RecordingVC"))! as! RecordingVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.doc_rowId = dataSource[sender.tag].doc_rowid
        toVC.voice_user_udid = dataSource[sender.tag].user_udid
        toVC.comment_count = dataSource[sender.tag].comment_count
        toVC.comment_users = dataSource[sender.tag].comment_users
        parentVC?.navigationController?.pushViewController(toVC, animated: true)
    }
    

    //MARK:-- check Use Location Services Authorization
    func checkUsersLocationServicesAuthorization(){
        
        // Check if user has authorized Total Plus to use Location Services
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    // Request when-in-use authorization initially
                    // This is the first and the ONLY time you will be able to ask the user for permission
//                    self.locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    break

                case .restricted, .denied:
                    // Disable location features
//                    switchAutoTaxDetection.isOn = false
                    let alert = UIAlertController(title: "Allow Location Access", message: "The app needs access to your current location to find near voices for your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)

                    // Button to Open Settings
                    alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)")
                            })
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    break

                case .authorizedWhenInUse, .authorizedAlways:
                    // Enable features that require location services here.
                    print("Full Access")
                    break
                default:
                    return
            }
        }
    }
}

extension NearbyVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let curIndex = indexPath.row % 4
        let nextIndex = (indexPath.row + 1 ) % 4
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceCell", for: indexPath) as! VoiceCell
        cell.entity = dataSource[indexPath.row]
        cell.viwMain.roundCorners([.bottomLeft], radius: 50.0)
        cell.viwMain.backgroundColor = UIColor(named: "music_bg_\(curIndex + 1)")
        
        if dataSource[indexPath.row].is_playing == true {
            addEqualizerView(parentView: cell.viwPlayState)
            cell.imgPlayState.isHidden = true
            cell.butPlay.setImage(UIImage(named: "ic_stop"), for: .normal)
        } else {
            cell.imgPlayState.isHidden = false
            cell.imgPlayState.bringSubviewToFront(cell.viwPlayState)
            cell.butPlay.setImage(UIImage(named: "ic_play1"), for: .normal)
            equalizerView?.removeFromSuperview()
        }
        
        cell.butPlay.tag    = indexPath.row
        cell.butLike.tag    = indexPath.row
        cell.butReport.tag  = indexPath.row
        cell.butComment.tag = indexPath.row
        
        if dataSource.count == indexPath.row + 1 {
            cell.contentView.backgroundColor = UIColor(named: "bg_white")
        } else {
            cell.contentView.backgroundColor = UIColor(named: "music_bg_\(nextIndex + 1)")
        }
        return cell
    }
}

extension NearbyVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        removeEzAudioPlayer()
        dataSource[indexPath.row].is_playing = false
        uiTableview.reloadRows(at: [IndexPath(row: playingItemIndex, section: 0)], with: .none)
        playingItemIndex = -1
        
        let toVC = (self.storyboard?.instantiateViewController( withIdentifier: "CommentVC"))! as! CommentVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.doc_rowId = dataSource[indexPath.row].doc_rowid
        toVC.dataSource.removeAll()
        toVC.dataSource.append(dataSource[indexPath.row])
        parentVC?.navigationController?.pushViewController(toVC, animated: true)
        
    }
}

//MARK:- EZAudioPlayer delegate
extension NearbyVC: EZAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
        
        DispatchQueue.main.async {
            if self.ezPlayer != nil && self.ezPlayer!.isPlaying {
                self.equalizerView?.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
    
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, reachedEndOf audioFile: EZAudioFile!) {
        
        DispatchQueue.main.async {
            //TODO:-
            self.dataSource[self.playingItemIndex].is_playing = false
            self.uiTableview.reloadRows(at: [IndexPath(row: self.playingItemIndex, section: 0)], with: .none)
            self.playingItemIndex = -1
            self.ezPlayer = nil
        }
    }
}
