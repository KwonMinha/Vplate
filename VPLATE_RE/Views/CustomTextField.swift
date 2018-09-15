//
//  CustomTextField.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 28..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

protocol DeletabelTextFieldDelegate {
    func textFieldDidSelectDeleteButton(_ textField: UITextField) -> Void
}

class CustomTextField: UITextField, UITextFieldDelegate {
    var deletableDelegate: DeletabelTextFieldDelegate?
    private var characterLimit: Int?
    private var numberTextField: Bool?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    @IBInspectable var maxLength: Int {
        get {
            guard let length = characterLimit else {
                return Int.max
            }
            return length
        }
        set {
            characterLimit = newValue
        }
    }
    
    @IBInspectable var onlyNumber: Bool {
        get {
            guard let numberTextField = self.numberTextField else {return false}
            return numberTextField
        }
        set {
            self.numberTextField = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count > 0 else { return true}

        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if onlyNumber {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet) && prospectiveText.count <= maxLength
        }
        
        return prospectiveText.count <= maxLength
    }
    
    override func deleteBackward() {
        self.deletableDelegate?.textFieldDidSelectDeleteButton(self)
        super.deleteBackward()
    }
}
