//
//  ChangePwViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class ChangePwViewController: UIViewController, GradientService {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var validateNumberField: UITextField!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var confirmButton: ConfirmButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.hideKeyboardWhenTappedAround()

    }
    
    private func setupUI() {
        self.title = "Find Password".localized
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        
        self.nameField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderName".localized, fontSize: 17)
        self.emailField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderEmail".localized, fontSize: 17)
        self.phoneNumberField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderPhone".localized, fontSize: 17)
        self.validateNumberField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderCode".localized, fontSize: 17)
        self.validateButton.cornerRadius = 11

    }
    
    private func setupAction() {
        self.confirmButton.addTarget(self, action: #selector(touchUpConfirmButton), for: .touchUpInside)
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    @objc func touchUpConfirmButton() {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SetPwViewController") as? SetPwViewController {
            viewController.type = .change
            viewController.name = nameField.text
            viewController.email = emailField.text
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

extension ChangePwViewController: UITextFieldDelegate {
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 11 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }
        
        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }
        
        if number.count == 11 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{4})(\\d{4})", with: "$1-$2-$3", options: .regularExpression, range: range)
        } else if number.count == 10 {
            if number.index(of: "0") == String.Index(encodedOffset: 0) && number.index(of: "2") == String.Index(encodedOffset: 1) {
                let end = number.index(number.startIndex, offsetBy: number.count)
                let range = number.startIndex..<end
                number = number.replacingOccurrences(of: "(\\d{2})(\\d{4})(\\d{4})", with: "$1-$2-$3", options: .regularExpression, range: range)
            } else {
                let end = number.index(number.startIndex, offsetBy: number.count)
                let range = number.startIndex..<end
                number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d{4})", with: "$1-$2-$3", options: .regularExpression, range: range)
            }
        }else if number.count > 5 && number.index(of: "0") == String.Index(encodedOffset: 0) && number.index(of: "2") == String.Index(encodedOffset: 1){
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{2})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: range)
        } else if number.count > 7{
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: range)
        } else {
            if number.index(of: "0") == String.Index(encodedOffset: 0) && number.index(of: "2") == String.Index(encodedOffset: 1) {
                let end = number.index(number.startIndex, offsetBy: number.count)
                let range = number.startIndex..<end
                number = number.replacingOccurrences(of: "(\\d{2})(\\d+)", with: "$1-$2", options: .regularExpression, range: range)
            } else {
                let end = number.index(number.startIndex, offsetBy: number.count)
                let range = number.startIndex..<end
                number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "$1-$2", options: .regularExpression, range: range)
            }
        }
        
        return number
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberField {
            var fullString = textField.text ?? ""
            fullString += string
            guard fullString.count < 14 else { return false }
            
            if range.length == 1 {
                textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
            } else {
                textField.text = format(phoneNumber: fullString)
            }
            
            return false
        }
        
        return true
    }
}
