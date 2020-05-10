//
//  CommentVC.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit


class CommentVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    @IBOutlet weak var viwBack: UIView!
    
    var dataSource = [VoiceModel]()
    var alertService = AlertService()
    var doc_rowId = ""
    var playingItemIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.pause()
        }
        print("viewWillDisappear")
    }
    
    // MARK: - custom function
    func setupView() {
        
        viwBack.roundCorners([.bottomRight, .topRight], radius: 25)
        
        uiTableview.dataSource = self
        uiTableview.tableFooterView = UIView()
        
//        loadTableData()
        
        addListenerCommentVoice()
        
    }
    
    //MARK:- load tableview data
    func loadTableData() {
        
        self.showLoadingView(vc: self, label: "Loading...")
        FirebaseAPI.getCommentVoice(doc_rowId) { (isSuccess, result) in
            
            if isSuccess == true {
                
                let resultData = result as! [VoiceModel]
                for one in resultData {
                    self.dataSource.append(one)
                }
                
                if self.dataSource.count > 0 {
                    self.view.backgroundColor = UIColor(named: "bg_white")
                }

                self.uiTableview.layoutIfNeeded();
                self.uiTableview.reloadData()
            } else {
                self.showError("Your request is failed")
            }
            self.hideLoadingView()
        }
    }
    
    func addListenerCommentVoice() {
        
        FirebaseAPI.addListenerCommentVoice(doc_rowId) {(isSuccess, result, changedType) in
            
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

                self.uiTableview.layoutIfNeeded();
                self.uiTableview.reloadData()
                
            }
            else {
                self.showError("Your request is failed")
            }
        }
    }
    
    
    
    //MARK:- custom action function
    @IBAction func didTapReport(_ sender: UIButton) {
        
        if sender.tag == 0 {
            return
        }
        
        var report_users = dataSource[sender.tag].report_users
        
        if report_users.contains(myUDID) {
            self.showAlert("You have already reported on this voice.")
        }
        else {
            report_users.append(myUDID)
            
            let alertVC = alertService.alert(title: "REPORT VOICE", buttonTitle: "OK") {[weak self] in
                
                self!.showLoadingView(vc: self!, label: "Requsting...")
                FirebaseAPI.reportCommentVoice(self!.doc_rowId, self!.dataSource[sender.tag].doc_rowid, report_users) {(isSuccess) in
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
    
    @IBAction func didTapPlay(_ sender: UIButton) {
        
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
    
    @IBAction func didTapLike(_ sender: UIButton) {
        if sender.tag == 0 {
            return
        }
        self.showLoadingView(vc: self, label: "Requsting...")
        var like_users = dataSource[sender.tag].like_users

        if dataSource[sender.tag].is_like == true {
            like_users.remove(at: like_users.firstIndex(of: myUDID)!)
        } else {
            like_users.append(myUDID)
        }
        
        FirebaseAPI.setLikeCommentVoice(self.doc_rowId, dataSource[sender.tag].doc_rowid, like_users) {(isSuccess) in
            if isSuccess == true {}
            else {
                self.showError("Your request is failed.")
            }
            
            self.hideLoadingView()
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        doDismiss()
    }
    
}

extension CommentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.entity = dataSource[indexPath.row]
        cell.butPlay.tag    = indexPath.row
        cell.butLike.tag    = indexPath.row
        cell.butReport.tag  = indexPath.row
        cell.parrent_voice_udid = dataSource[0].user_udid
        
        if indexPath.row == 0 {
            cell.lblCommentUser.text = "@ OJ"
            
        } else {
            let commentData = dataSource[indexPath.row]
            
            if commentData.user_udid == dataSource[0].user_udid {
                cell.lblCommentUser.text = "@ OJ"
                
            } else {
                
                var temp_comment_users = commentData.comment_users
                
                if temp_comment_users.contains(dataSource[0].user_udid) {
                    temp_comment_users.remove(at: temp_comment_users.firstIndex(of: dataSource[0].user_udid)!)
                }
                
                let index = temp_comment_users.firstIndex(of: commentData.user_udid)! + 1
                cell.lblCommentUser.text = "@ \(index)"
            }
        }
        
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
        
        return cell
    }
}

//MARK:- EZAudioPlayer delegate
extension CommentVC: EZAudioPlayerDelegate {
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
