//
//  String+Localize.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 6. 25..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

//editLabel.text = "Edit".localized // extension으로 구현
//let myName = "Sam"
//let friend = "Tom"
//let myNum = 10
//
//titleLabel.text = String(format: NSLocalizedString("Hello %@, This is %@", comment: ""), myName, friend)
// Hello Sam, This is Tom
//titleLabel.text = String(format: NSLocalizedString("Hello %d", comment: ""), myNum)
// Hello 10
 
