//
//  CertifyViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 13..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthenticateViewController: ViewController {
    @IBOutlet weak var codeTextField1: CustomTextField!
    @IBOutlet weak var codeTextField2: CustomTextField!
    @IBOutlet weak var codeTextField3: CustomTextField!
    @IBOutlet weak var codeTextField4: CustomTextField!
    @IBOutlet weak var codeTextField5: CustomTextField!
    @IBOutlet weak var codeTextField6: CustomTextField!
    lazy var codeTextFields: [CustomTextField] = [self.codeTextField1,
                                              self.codeTextField2,
                                              self.codeTextField3,
                                              self.codeTextField4,
                                              self.codeTextField5,
                                              self.codeTextField6]
    var phoneNumber: String?
    var verificationID : String?
    var code: String {
        var str = ""
        for field in self.codeTextFields {
            if let text = field.text {
                str += text
            }
        }
        return str
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendSMS()
        self.setUpViewController()
    }
    override func setUpViewController() {
        for (index, field) in codeTextFields.enumerated() {
            field.tag = index
            field.maxLength = 1
            field.delegate = self
            field.deletableDelegate = self
            field.onlyNumber = true
            field.keyboardType = .numberPad
            field.textAlignment = NSTextAlignment.center
        }
        self.codeTextField1.becomeFirstResponder()
    }
    
    @IBAction func refreshSMS(_ sender: UIButton) {
        self.sendSMS()
    }
    
    func sendSMS() {
        if let phoneNumber = self.phoneNumber {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                self.verificationID = verificationID
            
            }
        }
    }
    
    @IBAction func touchUpAuthSMS(_ sender: UIButton) {
        fetchAuthCode()
    }
    
    func fetchAuthCode() {
        self.view.endEditing(true)
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // User is signed in
            // ...
            print(user?.providerID)
            print(user?.phoneNumber)
        }
    }
}

extension AuthenticateViewController: DeletabelTextFieldDelegate, UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? CustomTextField else {return true}
        guard string.characters.count > 0 else { return true}
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if allowedCharacters.isSuperset(of: characterSet) {
            if currentText.count == 1 {
                switch textField {
                case self.codeTextField1, self.codeTextField2, self.codeTextField3, self.codeTextField4, self.codeTextField5:
                    textField.resignFirstResponder()
                    self.codeTextFields[textField.tag + 1].becomeFirstResponder()
                    self.codeTextFields[textField.tag + 1].text = string
                case self.codeTextField6:
                    if code.count == 6 {textField.resignFirstResponder()}
                default:
                    break
                }
            }
            
            return allowedCharacters.isSuperset(of: characterSet) && prospectiveText.count <= textField.maxLength
        }
            
        return false
    }

    
    func textFieldDidSelectDeleteButton(_ textField: UITextField) {
        switch textField {
        case self.codeTextField2, self.codeTextField3, self.codeTextField4, self.codeTextField5, self.codeTextField6:
            self.codeTextFields[textField.tag - 1].becomeFirstResponder()
        case self.codeTextField1 :
            self.codeTextField6.becomeFirstResponder()
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if code.count == 6 {
            fetchAuthCode()
        }
        
        return true
    }
}



