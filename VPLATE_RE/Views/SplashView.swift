//
//  SplashView.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit
import Lottie

class SplashView: UIView {
    //private var label: UILabel = UILabel()
    private var indicator = LOTAnimationView(name: "splash")
    private var width = 375
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)\
        self.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(self.width)
        }
        
        indicator.contentMode = .scaleAspectFit
        indicator.loopAnimation = true
        indicator.play()
    }
    
    func show(_ value: Bool) {
        if value {
            guard let window = UIApplication.shared.keyWindow else {return}
            window.addSubview(self)
            self.snp.makeConstraints { (make) in
                make.edges.equalTo(window)
            }
        }
        self.isHidden = !value
        
        DispatchQueue.main.async {
            self.alpha = !value ? 1 : 0
            
            UIView.animate(withDuration: 1, animations: {
                self.alpha = value ? 1 : 0
                switch value {
                case true:
                    self.indicator.play()
                case false:
                    self.indicator.pause()
                }
            }) { (bool) in
                if !value {
                    self.removeFromSuperview()
                }
            }
            
        }
    }
    
    
}
