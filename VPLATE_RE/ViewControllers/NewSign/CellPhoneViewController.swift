//
//  CellPhoneViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit
import Firebase

class CellPhoneViewController: UIViewController, GradientService {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var confirmButton: ConfirmButton!
    
    let countryPicker = UIPickerView()
    let countryList = IsoCountries.allCountries.map { $0.calling }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.initPickerView()
        self.hideKeyboardWhenTappedAround()
    }
    
    private func setupUI() {
        self.title = "Verification".localized
        
        //        self.confirmButton.isEnabled = false
        self.confirmButton.isSelected = true
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        self.phoneNumberField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderPhone".localized, fontSize: 17)
    }
    
    private func setupAction() {
        confirmButton.addTarget(self,
                                action: #selector(touchUpConfirm),
                                for: .touchUpInside)
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    @objc func touchUpConfirm() {
        if countryCodeField.text == "+82" {
            Auth.auth().languageCode = "kr"
        } else if countryCodeField.text == "+84" {
            Auth.auth().languageCode = "vi"
        } else if countryCodeField.text == "+852" {
            Auth.auth().languageCode = "zh-HK"
        }
        let phoneNumb = countryCodeField.text! + phoneNumberField.text!
        UserDefaults.standard.set(phoneNumb, forKey: "phoneNumb")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumb, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("errorMesaage:\(error.localizedDescription)")
                return
            }

            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let storyboard = UIStoryboard(name: "Sign", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "CellPhoneConfirmViewController") as? CellPhoneConfirmViewController {
                viewController.phoneNumber = self.phoneNumberField.text
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension CellPhoneViewController: UITextFieldDelegate {
    
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
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == phoneNumberField {
//            var fullString = textField.text ?? ""
//            fullString += string
//            guard fullString.count < 14 else { return false }
//
//            if range.length == 1 {
//                textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
//            } else {
//                textField.text = format(phoneNumber: fullString)
//            }
//
//            let count = textField.text?.count ?? 0
//            if count > 11 {
//                self.confirmButton.isEnabled = true
//                self.confirmButton.isSelected = true
//            } else {
//                self.confirmButton.isEnabled = false
//                self.confirmButton.isSelected = false
//            }
//
//            return false
//        }
//
//        return true
//    }
}

extension CellPhoneViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func initPickerView(){
        let barFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let countryDoneBtn = UIBarButtonItem(title: "선택", style: .done, target: self, action: #selector(selectedCountryPickerView))
        
        let countryBar = UIToolbar(frame:barFrame)
        countryBar.setItems([btnSpace, countryDoneBtn], animated: true)
        
        countryPicker.delegate = self
        countryPicker.dataSource = self
        
        countryCodeField.inputView = countryPicker
        countryCodeField.inputAccessoryView = countryBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[row]
    }
    
    @objc func selectedCountryPickerView() {
        let row = countryPicker.selectedRow(inComponent: 0)
        self.countryCodeField.text = countryList[row]
        self.countryCodeField.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryCodeField.text = countryList[row]
    }
}
