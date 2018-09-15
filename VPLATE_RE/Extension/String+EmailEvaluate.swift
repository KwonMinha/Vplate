//
//  String+EmailEvaluate.swift
//  VPLATE_RE
//
//  Created by 이혜진 on 2018. 7. 6..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

extension String {
    func isValidEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }
}
