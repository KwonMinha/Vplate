//
//  CompleteViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 23..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class CompleteViewController: UIViewController, GradientService {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var confirmButton: ConfirmButton!
    
    let userdefault = UserDefaults.standard
    var user = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
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
        self.confirmButton.isSelected = true
    }
    
    private func setupAction() {
        self.confirmButton.addTarget(self, action: #selector(touchUpConfirm), for: .touchUpInside)
    }
    
    @objc func touchUpConfirm() {
        if let email = user["userEmail"], let uid = user["socialKey"] {
            SignService.snsSignIn(email: email, uid: uid) { [weak self] (result) in
                guard let `self` = self else { return }
                
                switch result {
                case .success(let token):
                    Token.setToken(token: token)
                    self.userdefault.set(token, forKey: "token")
                    self.goMain()
                case .error(let msg):
                    print(msg)
                case .failure():
                    self.networkingError()
                }
            }
        } else {
            if let email = user["userEmail"], let pwd = user["password"] {
                SignService.signIn(email: email, pwd: pwd) { [weak self] (result) in
                    guard let `self` = self else { return }
                    
                    switch result {
                    case .success(let token):
                        print("token: \(token)")
                        Token.setToken(token: token)
                        self.userdefault.set(token, forKey: "token")
                        self.goMain()
                    case .error(let msg):
                        print(msg)
                    case .failure():
                        self.networkingError()
                    }
                }
            }
        }
    }
    
    private func goMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.shared.statusBarStyle = .default
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTab") as? UITabBarController {
            self.present(tabBarController, animated: true, completion: nil)
        }
    }
}
