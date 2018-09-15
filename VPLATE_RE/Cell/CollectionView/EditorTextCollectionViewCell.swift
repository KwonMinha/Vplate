//
//  EditorTextCollectionViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 10..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class EditorTextCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textField: CustomizableTextField!
    @IBOutlet weak var numberLabel: UILabel!
    
    var maxLenght: Int = 0 {
        didSet {
            self.textField.maxLength = self.maxLenght
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.textField.stateUIUpdate(state: .empty)
        self.textField.isEnabled = false
        self.textField.textColor = .white
    }

}
