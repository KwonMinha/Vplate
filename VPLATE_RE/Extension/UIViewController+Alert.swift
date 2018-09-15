//
//  UIViewController+Alert.swift
//  VPLATE_RE
//
//  Created by 이혜진 on 2018. 7. 4..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addAlert(title: String?, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "YES".localized, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func networkingError() {
        let alert = UIAlertController(title: "네트워크 에러", message: "네트워크를 확인해주세요.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "YES".localized, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
