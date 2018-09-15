//
//  DotProgress.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 7. 4..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit

class DotProgress: UIView {
    private var stackView : UIStackView = UIStackView()
    private var dots: [DesignableView] = []
    var count: Int = 3
    var index: Int = 0
    var fillBackgroundColor: UIColor = UIColor.DefaultColor.skyBlue
    var fillBorderColor: UIColor = UIColor.DefaultColor.skyBlue
    var emptyBackgroundColor: UIColor = .white
    var emptyBorderColor: UIColor = UIColor.DefaultColor.lightGreen
    
    var width: CGFloat = 15
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    private func setUp() {
        self.addSubview(stackView)
        stackView.axis  = UILayoutConstraintAxis.horizontal
        stackView.distribution  = UIStackViewDistribution.equalSpacing
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing   = 10.0
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
        }
        
        for i in 0..<count {
            let view = DesignableView()
            view.tag = i
            view.backgroundColor = emptyBackgroundColor
            view.borderColor = emptyBorderColor
            view.cornerRadius = width / 2
            view.borderWidth = 1
            dots.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { (make) in
                make.width.height.equalTo(width)
            }
        }
    }
    
    func set(value: Int) {
        dots.forEach { (view) in
            if view.tag <= value {
                view.backgroundColor = fillBackgroundColor
                view.borderColor = fillBorderColor
            }
            else {
                view.backgroundColor = emptyBackgroundColor
                view.borderColor = emptyBorderColor
            }
        }
    }
}
