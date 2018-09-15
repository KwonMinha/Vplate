//
//  Validation.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 27..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

extension UITextField {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    
}

extension String {
    func validateEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
        
    }
}
