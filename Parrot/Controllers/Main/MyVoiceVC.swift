//
//  MyVoiceVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class MyVoiceVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    
    var dataSource = [VoiceModel]()
    var parentVC: MainpageVC?
    let alertService = AlertService()
    var playingItemIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        
        //loadTableData()
        
        addListenerMyRecordVoice()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.pause()
        }
        print("viewWillDisappear")
    }
    
    //MARK:- load or update tableview data :::: call firestore
    func loadTableData() {
        
        if is_started == false {
            self.showLoadingView(vc: self, label: "Loading...")
        }
        
        FirebaseAPI.getMyRecordVoice() { (isSuccess, result) in
            if isSuccess == true {
                
                self.dataSource = result as! [VoiceModel]
                if self.dataSource.count > 0 {
                    self.view.backgroundColor = UIColor(named: "bg_white")
                }

                self.dataSource.sorted(by: { $0.created_date > $1.created_date })
                self.uiTableview.layoutIfNeeded();
                self.uiTableview.reloadData()
            } else {
//                self.showError("Your request is failed")
            }
            self.hideLoadingView()
            is_started = true
        }
    }
    
    func addListenerMyRecordVoice() {
        FirebaseAPI.addListenerMyRecordVoice() {(isSuccess, result, changedType) in
            
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
    
    //MARK:- cell's action functions
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

    @IBAction func didTapDelete(_ sender: UIButton) {
        
        removeEzAudioPlayer()
        
        let alertVC = alertService.alert(title: "DELETE YOUR VOICE", buttonTitle: "DELETE") {[weak self] in
            self!.loadTableData()
//            self.showAlert("alertOK")
            
            let voiceUrl = self!.dataSource[sender.tag].voice_url
            let doc_id = self!.dataSource[sender.tag].doc_rowid
            
            FirebaseAPI.deleteMyOneRecordVoice(voiceUrl, doc_id) {(isSuccess, result) in
                if isSuccess == true {
                    
                } else {
                    self!.showError(R.string.ERROR_OCCURED)
                }
            }
            
            self!.playingItemIndex = -1
        }
        present(alertVC, animated: true)
    }
}

extension MyVoiceVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let curIndex = indexPath.row % 4
        let nextIndex = (indexPath.row + 1 ) % 4
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyVoiceCell", for: indexPath) as! VoiceCell
        cell.entity = dataSource[indexPath.row]
        cell.viwMain.roundCorners([.bottomLeft], radius: 50.0)
        cell.viwMain.backgroundColor = UIColor(named: "music_bg_\(curIndex + 1)")
        cell.butPlay.tag    = indexPath.row
        cell.butReport.tag  = indexPath.row
        
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
        
        if dataSource.count == indexPath.row + 1 {
            cell.contentView.backgroundColor = UIColor(named: "bg_white")
        } else {
            cell.contentView.backgroundColor = UIColor(named: "music_bg_\(nextIndex + 1)")
        }
        return cell
    }
    
    
}

extension MyVoiceVC: UITableViewDelegate {
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
extension MyVoiceVC: EZAudioPlayerDelegate {
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
