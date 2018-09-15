//
//  Player.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 30..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import BMPlayer

class Player: BMPlayer {
    
    override func storyBoardCustomControl() -> BMPlayerControlView? {
        return PlayerControlView()
    }
    
    func isMuted(_ mute: Bool) {
        if let controlView = controlView as? PlayerControlView {
            controlView.muteStateDidChange(isMuted: mute)
        }
    }

}
