//
//  UIViewController+Vplate.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 24..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
