//
//  AVPlayer+Extension.swift
//  Alarmo
//
//  Created by RMS on 12/17/19.
//  Copyright © 2019 Alarmo. All rights reserved.
//

import Foundation
import AVFoundation

var player: AVAudioPlayer?
//var player: AVPlayer?

func playLocalSoundFile(_ soundName: String) {
    
    if soundName.contains("/var/mobile/Containers") {
        
    }
    guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
        print("error to get the mp3 file")
        print("soundName: ", soundName)
        return
    }

    print("playLocalSound: ", url)
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        player = try AVAudioPlayer(contentsOf: url)  // AVPlayer(url: url)
        
        guard let player = player else { return }
        
        player.play()

    } catch let error {
        print(error.localizedDescription)
    }
}

func playLocalUrl(_ urlString: String) {
    
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)  // AVPlayer(url: url)
        
        guard let player = player else { return }
        
        player.play()

    } catch let error {
        print(error.localizedDescription)
    }
}

func playAudioFromURL(_ soundUrl: String) {
    guard let fileURL = URL(string: soundUrl) else {
        print("error to get the audio file")
        print("soundNameFromURL: ", soundUrl)
        return
    }

    
    do {
        let soundData = NSData(contentsOf: fileURL)
        player = try AVAudioPlayer(data: soundData! as Data)
        player!.prepareToPlay()
        player!.volume = 1.0
//        player.delegate = self
        player!.play()
    } catch {
        print("error to play the audio file")
        print("urlFromURL: ", fileURL)
    }
    
}

func stopSound() {
    guard let player = player else { return }
    
    player.pause()
//    player.stop()
    
}
