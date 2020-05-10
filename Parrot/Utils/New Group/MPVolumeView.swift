//
//  MPVolumeView.swift
//  Alarmo
//
//  Created by RMS on 12/11/19.
//  Copyright © 2019 Alarmo. All rights reserved.
//

//import AVFoundation
import MediaPlayer

extension MPVolumeView {
    
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        volumeView.isHidden = true
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
    
//    static func getVolume() -> Float {
//        let volumeView = MPVolumeView()
//        return MPVolumeView.volumeView.getVolume()
//    }
}
