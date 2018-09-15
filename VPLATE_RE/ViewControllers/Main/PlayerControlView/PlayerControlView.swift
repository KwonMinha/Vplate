//
//  PlayerControlView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 30..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import BMPlayer

class PlayerControlView: BMPlayerControlView {
    var muteButton = UIButton(type: .custom)
    var isMuted = false
    
    @objc func onMutedPressed(_ button: UIButton) {
        isMuted =  !isMuted
        muteStateDidChange(isMuted: isMuted)
    }
    
    override func customizeUIComponents() {
        backButton.removeFromSuperview()
        chooseDefitionView.isHidden = true
        topMaskView.addSubview(muteButton)
        muteButton.tag = BMPlayerControlView.ButtonType.mute.rawValue
        muteButton.setImage(#imageLiteral(resourceName: "UnMute"), for: .normal)
        muteButton.setImage(#imageLiteral(resourceName: "Mute"), for: .selected)

        muteButton.addTarget(self, action: #selector(onMutedPressed(_:)), for: .touchUpInside)
        
        muteButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.bottom.equalTo(topMaskView)
            make.right.equalTo(topMaskView).inset(15)
        }
    }
    override func updateUI(_ isForFullScreen: Bool) {
        
    }
    
    func muteStateDidChange(isMuted: Bool) {
        self.isMuted = isMuted
        delegate?.controlView?(controlView: self, didChangeMute: isMuted)
        muteButton.isSelected = isMuted
    }
}
