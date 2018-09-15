//
//  CustomizableTextField.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 10..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

enum TextFieldState {
    case empty, typing, complete
}

@IBDesignable
class CustomizableTextField: UITextField {

    @IBInspectable var underLineHeight: CGFloat = 1
    @IBInspectable var normaUnderLinelColor: UIColor = UIColor.white
    @IBInspectable var activeUnderLineColor: UIColor = UIColor.DefaultColor.skyBlue
    var emptyTextColor = UIColor(red: 122/255, green: 122/255, blue: 122/255, alpha: 1)
    var typingTextColor = UIColor.DefaultColor.lightGreen
    var completeTextColor = UIColor.DefaultColor.skyBlue
    
    let border = CALayer()
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
//    var complete: Bool = false
    @IBInspectable var maxLength: Int = 25
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        label.textAlignment = .right
        label.text = "\(maxLength)자"
        label.font.withSize(12)
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: label.stringSize.width, height: label.stringSize.height))
        label.frame = CGRect(x: 0, y: 0, width: label.stringSize.width, height: label.stringSize.height)
        rightView.addSubview(label)
        if let length = self.text?.count {
            lenghtUIUpdate(length: length)
        }
        self.rightView = rightView
        self.rightViewMode = .always
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        border.frame = CGRect(x: 0, y: self.frame.height - underLineHeight, width: self.frame.width, height: underLineHeight)
        
        
        rightView?.frame = CGRect(x: 0, y: 0, width: label.stringSize.width, height: label.stringSize.height)
        label.frame = CGRect(x: 0, y: 0, width: label.stringSize.width, height: label.stringSize.height)
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        super.layoutSubviews()
    }
    
    func lenghtUIUpdate(length: Int) {
        switch length {
        case 0:
            stateUIUpdate(state: .empty)
        case maxLength:
            stateUIUpdate(state: .complete)
        default :
            stateUIUpdate(length: length, state: .typing)
        }
    }
    
    func stateUIUpdate(length: Int? = nil, state: TextFieldState) {
        switch state {
        case .empty:
            label.text = "\(maxLength)"
            label.textAlignment = .right
            label.textColor = self.emptyTextColor
            border.backgroundColor = normaUnderLinelColor.cgColor
        case .typing:
            label.text = "\(length!)/\(maxLength)"
            label.textColor = self.typingTextColor
            border.backgroundColor = UIColor.DefaultColor.lightGreen.cgColor
        case .complete:
            label.text = "✓"
            label.textAlignment = .center
            label.textColor = self.completeTextColor
            self.border.backgroundColor = activeUnderLineColor.cgColor
        }
    }
}

extension String {
    var stringWidth: CGFloat {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
        let boundingBox = self.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
        return boundingBox.width
    }
    
    var stringHeight: CGFloat {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
        let boundingBox = self.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
        return boundingBox.height
    }
}

extension UILabel {
    var stringSize: CGSize {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
        let boundingBox = self.text?.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: self.font], context: nil)
        
        if let boundingBox = boundingBox {
            return CGSize(width: boundingBox.width, height: boundingBox.height)
        }
        return CGSize(width: 0, height: 0)
    }
}
