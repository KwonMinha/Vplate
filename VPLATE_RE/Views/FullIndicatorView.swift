//
//  FullIndicatorView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 4. 9..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit
import Lottie

//var fullIndicatorView: FullIndicatorView = FullIndicatorView()
//fullIndicatorView.show(true)

class FullIndicatorView: UIView {
    private var label: UILabel = UILabel()
    private var indicator = LOTAnimationView(name: "indicator")
    private var width = 75
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
        label.textColor = UIColor.white
        label.textAlignment = .center

        self.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(self.width)
        }
        
        indicator.contentMode = .scaleAspectFit
        indicator.loopAnimation = true
        indicator.play()
    }
    
    func set(value: Int) {
        DispatchQueue.main.async {
            self.label.text = "\(value)%"
        }
    }
    
    func show(_ value: Bool) {
        self.label.text = ""
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
