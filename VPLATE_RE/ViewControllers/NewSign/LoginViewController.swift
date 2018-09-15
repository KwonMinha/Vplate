//
//  LoginViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GradientService {

    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var signinButton: ConfirmButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var findEmailButton: UIButton!
    @IBOutlet weak var findPwButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let userdefault = UserDefaults.standard
    
    var text: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        signinButton.isSelected = true
        self.findEmailButton.setAttributedTitle(self.underLineString(title: "Forgot Email Address?".localized, fontSize: 13), for: .normal)
        self.findPwButton.setAttributedTitle(self.underLineString(title: "Forgot Password?".localized, fontSize: 13), for: .normal)
    }
    
    private func setupAction() {
        self.signinButton.addTarget(self, action: #selector(touchUpConfirm), for: .touchUpInside)
        self.findEmailButton.addTarget(self, action: #selector(touchUpFindEmail), for: .touchUpInside)
        self.findPwButton.addTarget(self, action: #selector(touchUpFindPw), for: .touchUpInside)
        self.backButton.addTarget(self, action: #selector(touchUpBackButton), for: .touchUpInside)
    }
    
    private func underLineString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    @objc func touchUpFindEmail() {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ChangeEmailViewController") as? ChangeEmailViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func touchUpFindPw() {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ChangePwViewController") as? ChangePwViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func touchUpBackButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: Login button Action
    @objc func touchUpConfirm() {
        if !(emailField.text?.isEmpty ?? false),
            !(pwField.text?.isEmpty ?? false) {
            
            SignService.signIn(email: emailField.text ?? "", pwd: pwField.text ?? "") { [weak self] (result) in
                switch result {
                case .success(let token):
                    print(token)
                    Token.setToken(token: token)
                    self?.userdefault.set(token, forKey: "token")
                    
                    //MARK: POST Device Token
                    SignService.addDeviceToken(deviceToken: (self?.userdefault.string(forKey: "deviceAPNsToken"))!, completion: {
                    })

                    DispatchQueue.main.async {
                        UIApplication.shared.statusBarStyle = .default
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTab") as? UITabBarController {
                        self?.present(tabBarController, animated: true, completion: nil)
                    }
                    
                case .error(let message):
                    self?.addAlert(title: "", msg: message)
                    break
                    
                case .failure():
                    self?.networkingError()
                }
            }
            
        } else {
            addAlert(title: "로그인 오류", msg: "모든 필드를 채워주세요.")
        }
    }

}
