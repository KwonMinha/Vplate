//
//  PhoneCertificationViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 13..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import FirebaseAuth
import PhoneNumberKit

class PhoneAuthenticationViewController: ViewController {
    
    @IBOutlet weak var phoneTextField: PhoneNumberTextField!
    var handle: AuthStateDidChangeListenerHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func setUpViewController() {
        self.phoneTextField.maxDigits = 10
        self.phoneTextField.delegate = self
    }
    
    @IBAction func touchUpNext(_ sender: UIButton) {
        navigateNextVC()
    }
    
    func navigateNextVC() {
        self.view.endEditing(true)
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: AuthenticateViewController.reuseIdentifier) as! AuthenticateViewController
        if let text = self.phoneTextField.text?.dropFirst() {
            nextVC.phoneNumber = "+82 \(text)"
        }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension PhoneAuthenticationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigateNextVC()
        return true
    }
}
