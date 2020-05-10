//
//  MyAudioPlayer.swift
//  Alarmo
//
//  Created by RMS on 12/11/19.
//  Copyright © 2019 Alarmo. All rights reserved.
//

import AVFoundation

class MyAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private static let sharedPlayer: MyAudioPlayer = {
        return MyAudioPlayer()
    }()

    public var container = [String : AVAudioPlayer]()

    static func isLoudCheck(completionHandler: @escaping (Bool?) -> ()) {
        let name = "silence"
        let key = name
        var player: AVAudioPlayer?

        for (file, thePlayer) in sharedPlayer.container{
            if file == key {
                player = thePlayer
                break
            }
        }

        if player == nil, let resource = Bundle.main.path(forResource: name, ofType: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: resource), fileTypeHint: AVFileType.mp3.rawValue)
            }
            catch {
                print("%%% - audio error?")
            }
        }

        if let thePlayer = player {
            print("%%% - the player plays")
            thePlayer.delegate = sharedPlayer
            sharedPlayer.container[key] = thePlayer
            thePlayer.play()
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if let thePlayer = player {
                if thePlayer.isPlaying
                {
                    print("%%% - check: playing")
                    completionHandler(true)
                } else {
                    print("%%% - check: not playing")
                    completionHandler(false)
                }
            }
        })
    }

    static func isPlaying(key: String) -> Bool? {
        return sharedPlayer.container[key]?.isPlaying
    }
}
