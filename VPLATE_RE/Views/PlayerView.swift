//
//  PlayerView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 6. 27..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import AVKit

class PlayerView: UIView {

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    var currentItem: AVPlayerItem? {
        return self.player?.currentItem
    }
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
        
    var currentTime: TimeInterval {
        return self.currentItem?.currentTime().seconds ?? 0.0
    }
    //MARK: - Methods
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    func play(){
        self.player?.play()
    }
}
