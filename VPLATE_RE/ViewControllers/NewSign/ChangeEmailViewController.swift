//
//  ChangeEmailViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class ChangeEmailViewController: UIViewController, GradientService {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var validateNumberField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var confirmButton: ConfirmButton!
    @IBOutlet weak var validateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.hideKeyboardWhenTappedAround()

    }
    
    private func setupUI() {
        self.title = "Find Email Address".localized
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        
        self.nameField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderName".localized, fontSize: 17)
        self.phoneNumberField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderPhone".localized, fontSize: 17)
        self.validateNumberField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderCode".localized, fontSize: 17)
        self.validateButton.cornerRadius = 11
        
    }
    
    private func setupAction() {
        //self.confirmButton.isEnabled = false
        self.confirmButton.addTarget(self, action: #selector(touchUpConfirmButton), for: .touchUpInside)
        self.nameField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.phoneNumberField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    @objc func touchUpConfirmButton() {
        if nameField.text != "" || phoneNumberField.text != "" {
            SignService.findEmail(userName: nameField.text!, userPhone: phoneNumberField.text!) { (message, findEmail) in
                if message == "userEmail" {
                    let alert = UIAlertController(title: "", message: findEmail, preferredStyle: .alert)
                    alert.message = findEmail
                    let okAction = UIAlertAction(title: "Log In".localized, style: .default) { (UIAlertAction) in
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    }
                    let cancelAction = UIAlertAction(title: "Find Password".localized, style: .default) { (UIAlertAction) in
                        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
                        if let viewController = storyboard.instantiateViewController(withIdentifier: "ChangePwViewController") as? ChangePwViewController {
                            
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    }
                    alert.addAction(cancelAction)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "", message: "Email or phone number is invalid".localized, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "YES".localized, style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        } else {
        }
    
    }

    @objc func textFieldDidChange(textField: UITextField) {
//        let nameText = nameField.text ?? ""
//        let phoneText = phoneNumberField.text ?? ""
//        if nameText.isEmpty ||
//            phoneText.isEmpty {
//            self.confirmButton.isSelected = false
//            self.confirmButton.isEnabled = false
//        }else {
//            self.confirmButton.isEnabled = true
//            self.confirmButton.isSelected = true
//        }
        
//        print(phoneNumberField.text?.count)
//        if nameField.text != "" && phoneNumberField.text != "" {
//            self.confirmButton.isEnabled = true
//            self.confirmButton.isSelected = true
//        } else {
//            self.confirmButton.isEnabled = false
//            self.confirmButton.isSelected = false
//        }
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }

}

extension ChangeEmailViewController: UITextFieldDelegate {
    
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
