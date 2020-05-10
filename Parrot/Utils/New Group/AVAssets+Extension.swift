//
//  AVAssets+Extension.swift
//  Parrot
//
//  Created by AngelDev on 5/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension AVAsset {

    var g_size: CGSize {
        return tracks(withMediaType: AVMediaType.video).first?.naturalSize ?? .zero
    }

    var g_orientation: UIInterfaceOrientation {
        guard let transform = tracks(withMediaType: AVMediaType.video).first?.preferredTransform else {
            return .portrait
        }

        switch (transform.tx, transform.ty) {
            case (0, 0):
                return .landscapeRight
            case (g_size.width, g_size.height):
                return .landscapeLeft
            case (0, g_size.width):
                return .portraitUpsideDown
            default:
                return .portrait
        }
    }
}
