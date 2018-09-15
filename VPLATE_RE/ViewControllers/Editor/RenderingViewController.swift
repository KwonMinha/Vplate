//
//  RenderingViewController.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class RenderingViewController: UIViewController, GradientService {
    @IBOutlet weak var buttonHome: ConfirmButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonHome.isSelected = true

        self.setupAction()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.createGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupAction() {
        self.buttonHome.addTarget(self, action: #selector(goMain), for: .touchUpInside)
    }
    
    @objc private func goMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.shared.statusBarStyle = .default
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTab") as? UITabBarController {
            self.present(tabBarController, animated: true, completion: nil)
        }
   
    }

}
