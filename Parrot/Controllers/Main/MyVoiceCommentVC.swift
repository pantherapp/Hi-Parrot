//
//  MyVoiceCommentVC.swift
//  Parrot
//
//  Created by AngelDev on 4/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class MyVoiceCommentVC: BaseVC {
    
    
    @IBOutlet weak var uiTableview: UITableView!
    @IBOutlet weak var viwBack: UIView!
    
    var dataSource = [VoiceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    

    // MARK: - custom function
    func setupView() {
        
        viwBack.roundCorners([.bottomRight, .topRight], radius: 25)
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        
        loadTableData()
    }
    
    func loadTableData() {
        
//        for index in 0 ..< 10 {
//            var state = false
//            if index % 2 == 0 {
//                state = true
//            }
//            let one = VoiceModel(record_id: "\(index)", created_date: "1588066859", record_url: "https://",
//                                 commet_count: "comment", like_count: "900", is_like: state)
//            
//            dataSource.append(one)
//        }
        //uiTableview.setNeedsLayout();
//        uiTableview.layoutIfNeeded();
        uiTableview.reloadData()
    }
    
    // MARK: - action function
    @IBAction func didTapPlay(_ sender: Any) {
        
    }
    
    @IBAction func didTapReport(_ sender: Any) {
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        doDismiss()
    }
}

extension MyVoiceCommentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyVoiceCommentCell", for: indexPath) as! MyVoiceCommentCell
        cell.entity = dataSource[indexPath.row]
        
        cell.butPlay.tag    = indexPath.row
        cell.butReport.tag  = indexPath.row
        
        return cell
    }
}

extension MyVoiceCommentVC: UITableViewDelegate{
    
}
