//
//  RecordingVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import AVFoundation

var recordedVoiceURL: URL?

class RecordingVC: BaseVC {
    
    @IBOutlet weak var viwBefore: UIView!
    @IBOutlet weak var viwListen: UIView!
    @IBOutlet weak var butRecord: UIButton!
    @IBOutlet weak var butListen: UIButton!
    @IBOutlet weak var lblRecordingTime: UILabel!
    
    var comment_count = 0
    var comment_users = [String]()
    var timeVal = 0
    var recordingTimer: Timer?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer:AVAudioPlayer!
    var doc_rowId = ""
    var voice_user_udid = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        viwBefore.roundCorners([.bottomRight, .topRight], radius: 25)
        viwListen.roundCorners([.bottomLeft, .topLeft], radius: 25)
        
        //setup Recorder
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timeVal = 0
        lblRecordingTime.text = "00:00"
        butListen.isEnabled = false
        viwListen.backgroundColor = UIColor(named: "cir_2")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.pause()
        }
        doc_rowId  = ""
        voice_user_udid = ""
        print("PreviewRecordVC-viewWillDisappear")
    }
    
    //MARK:- tap event function
    @IBAction func onTapedBack(_ sender: Any) {
        doDismiss()
    }
    
    @IBAction func onTapedListen(_ sender: Any) {
        let toVC = (self.storyboard?.instantiateViewController( withIdentifier: "PreviewRecordVC"))! as! PreviewRecordVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.doc_rowId = doc_rowId
        toVC.voice_user_udid = voice_user_udid
        toVC.comment_count = comment_count
        toVC.comment_users = comment_users
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTaprecordAudioButton(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    //MARK:- custom function
    func setupView() {
        recordedVoiceURL = nil
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            try recordingSession.overrideOutputAudioPort(.speaker)
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record
        }
    }
    
    @objc func runTimedCode () {
        timeVal += 1
        
//        let hourString = String(format: "%02d", Int(timeVal / 360))
        let minuteString = String(format: "%02d", Int(timeVal / 60))
        let secondString = String(format: "%02d", Int(timeVal %  60))
//        self.lblRecordingTime.text = "\(hourString):\(minuteString):\(secondString)"
        self.lblRecordingTime.text = "\(minuteString) : \(secondString)"
        
        if timeVal >= 50 {
            finishRecording(success: true)
        }
    }
    
    func loadRecordingUI() {
        butRecord.isEnabled = true
        butRecord.setTitle("RECORD", for: .normal)
        butListen.isEnabled = false
    }
    
    func startRecording() {
        let audioFilename = getFileURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
//            AVEncoderBitRateKey: 320000,
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            butRecord.setTitle("STOP RECORD", for: .normal)

            butListen.isEnabled = false
            viwListen.backgroundColor = UIColor(named: "cir_2")
            timeVal = 0
            recordingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        
        recordingTimer?.invalidate()
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            butRecord.setTitle("RE-RECORD", for: .normal)
        } else {
            butRecord.setTitle("RECORD", for: .normal)
            // recording failed :(
        }
        recordedVoiceURL = getFileURL()
        viwListen.backgroundColor = UIColor(named: "next_but")
        butListen.isEnabled = true
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return path as URL
    }
}

//MARK:- Delegates
extension RecordingVC: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
}
