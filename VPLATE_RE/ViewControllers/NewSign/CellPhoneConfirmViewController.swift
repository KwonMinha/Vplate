//
//  CellPhoneConfirmViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit
import Firebase

class CellPhoneConfirmViewController: UIViewController, GradientService {
    @IBOutlet weak var validationNumberField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var confirmButton: ConfirmButton!
    @IBOutlet weak var retryButton: UIButton!
    
    var user = [String:String]()
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    private func setupUI() {
        self.title = "Verification".localized
        
        //        self.confirmButton.isEnabled = false
        self.confirmButton.isSelected = true
        
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        self.validationNumberField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderCode".localized, fontSize: 17)
        
        // seunghwan 변경된 부분
        self.retryButton.setAttributedTitle(self.underLineString(title: "Re-send SMS".localized, fontSize: 14), for: .normal)
    }
    
    private func setupAction() {
        confirmButton.addTarget(self, action: #selector(touchUpConfirm), for: .touchUpInside)
        // seunghwan 변경된 부분
        retryButton.addTarget(self, action: #selector(touchUpRetry), for: .touchUpInside)
        validationNumberField.addTarget(self, action: #selector(numberDidChange(_:)), for: .editingChanged)
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    private func underLineString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    @objc func touchUpConfirm() {
        //seunghwan 변경된 부분
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let verificationCode = validationNumberField.text!
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                
                let alert = UIAlertController(title: "Please check the verification code again".localized, message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "YES".localized, style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
                print("errorMesaage:\(error.localizedDescription)")
                return
            }
            
            let storyboard = UIStoryboard(name: "Sign", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "EmailPersonalInformationViewController") as? EmailPersonalInformationViewController {
                //user!["userPhoneNumber"] = self.phoneNumber
                viewController.phoneNumber = self.phoneNumber
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func touchUpRetry() {
        Auth.auth().languageCode = "ko"
        let phoneNumb = UserDefaults.standard.string(forKey: "phoneNumb")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumb!, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("errorMesaage:\(error.localizedDescription)")
                return
            }
        }
    }
    
    @objc func numberDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            self.confirmButton.isEnabled = false
            self.confirmButton.isSelected = false
        } else {
            self.confirmButton.isEnabled = true
            self.confirmButton.isSelected = true
        }
    }
    
}
