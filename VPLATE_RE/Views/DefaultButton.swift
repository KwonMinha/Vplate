//
//  CustomButton.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 8..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class DefaultButton: DesignableButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
        super.layoutSubviews()
    }
    
    
    func setUp() {
        self.removeShadow()
        self.shadowRounded(cornerRadius: self.frame.height / 2,
                           shadowColor: .black,
                           shadowOffset: CGSize(width: 0, height: 2),
                           shadowRadius: 3,
                           shadowOpacity: 0.15)
    }
}
