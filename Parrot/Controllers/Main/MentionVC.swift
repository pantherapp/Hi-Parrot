//
//  MentionVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class MentionVC: BaseVC {
    
    //MARK:-   define outlet and set variable data
    @IBOutlet weak var uiTableview: UITableView!
    
    var dataSource = [MentionModel]()
    var parentVC: MainpageVC?
    var selectedMentionIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        
        loadMentionData()
        
        addListenerMyRecordVoice()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if selectedMentionIndex > -1 {
            let index = selectedMentionIndex
            selectedMentionIndex = -1
            FirebaseAPI.deleteMentionData(dataSource[index].noti_docId, dataSource[index].mention_docid) { isSuccess, result in
                if isSuccess == true {
                    let badgeCount = result as! Int
                    UIApplication.shared.applicationIconBadgeNumber = badgeCount
                    NotificationCenter.default.post(name: Notification.Name("changedBadgeCount"), object: nil)
                } else {
                    print("fail:===>", result as! String)
                }
            }
        }
    }
    
    
    
    
    //MARK:- load data and set listener
    func loadMentionData() {
        
        if is_started == false {
            self.showLoadingView(vc: self, label: "Loading...")
        }
        
        FirebaseAPI.getMentionData(){ isSuccess, result in
            
            if isSuccess == true {
                self.dataSource = result as! [MentionModel]
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
        FirebaseAPI.addListenerMentions() {(isSuccess, result, changedType) in
            
            if isSuccess == true {
                let changedData = result as! [MentionModel]
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
                            if one.mention_docid == self.dataSource[index].mention_docid {
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
                
                
                self.uiTableview.layoutIfNeeded();
                self.uiTableview.reloadData()
            }
            else {
                self.showError("Your request is failed")
            }
        }
    }
}

extension MentionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionCell", for: indexPath) as! MentionCell
        cell.entity = dataSource[indexPath.row]

        return cell
    }
}

extension MentionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        parentVC!.gotoNavVC("CommentVC")
        
        selectedMentionIndex = indexPath.row
        
        let toVC = (self.storyboard?.instantiateViewController( withIdentifier: "CommentVC"))! as! CommentVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.doc_rowId = dataSource[indexPath.row].comment_docid
        parentVC?.navigationController?.pushViewController(toVC, animated: true)
    }
}
