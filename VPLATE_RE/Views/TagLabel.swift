//
//  TagLabel.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 8..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class TagLabel: DesignableLabel {
 
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
    
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
        self.backgroundColor = UIColor.white
        self.shadowRounded(cornerRadius: self.frame.height / 2, shadowRadius: 1)
    }
}
