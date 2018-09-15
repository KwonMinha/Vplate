//
//  SetPwViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class SetPwViewController: UIViewController, GradientService {
    
    enum ViewType: String {
        case setUp = "Next"
        case change = "Reset Your Password"
    }
    
    var name: String?
    var email: String?
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwCheckField: UITextField!
    @IBOutlet weak var confirmButton: ConfirmButton!
    
    var type: ViewType = .setUp
    var user = [String:String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.hideKeyboardWhenTappedAround()

    }
    
    private func setupUI() {
        if type == .setUp {
             self.title = "Set Password".localized
        } else {
            self.title = "Reset Your Password".localized
        }
        
        self.confirmButton.setTitle(self.type.rawValue.localized,
                                    for: .normal)
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
    }
    
    private func setupAction() {
        self.confirmButton.isEnabled = false
        self.confirmButton.addTarget(self, action: #selector(touchUpConfirm), for: .touchUpInside)
        self.pwField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.pwCheckField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

    }
    
    @objc func touchUpConfirm() {
        if let pwd = pwField.text {
            switch type {
            case .setUp:
                user.updateValue(pwd, forKey: "password")
                
                let storyboard = UIStoryboard(name: "Sign", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "CompanyImformationViewController") as? CompanyImformationViewController {
                    viewController.user = self.user
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                
            case .change:
            SignService.changePassword(userName: name!, userEmail: email!, password: pwField.text!) { (message) in
                if message == "password update" {
                    let alertController = UIAlertController(title: nil, message: "Password has been changed".localized, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Log In".localized, style: .default) { (UIAlertAction) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // 비밀번호 변경 못했을 시
                }
            }
            
            
            

            
            
            
  
            }

            
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        let pwText = pwField.text ?? ""
        let pwCheckText = pwCheckField.text ?? ""
        if pwText.isEmpty ||
            pwCheckText.isEmpty ||
            pwText != pwCheckText {
            self.confirmButton.isSelected = false
            self.confirmButton.isEnabled = false
        }else {
            self.confirmButton.isEnabled = true
            self.confirmButton.isSelected = true
        }
    }
}
