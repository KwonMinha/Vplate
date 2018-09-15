//
//  ConfirmButton.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class ConfirmButton: UIButton {
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0
                self.backgroundColor = .white
                self.dropShadow()
            case false:
                self.layer.borderColor = UIColor.white.cgColor
                self.layer.borderWidth = 1
                self.backgroundColor = .clear
                self.clearShadow()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isSelected = false
        self.tintColor = .clear
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(#colorLiteral(red: 0.9047660232, green: 0.3464347124, blue: 0.4063560367, alpha: 1), for: .selected)
        self.layer.cornerRadius = 18
    }

}
