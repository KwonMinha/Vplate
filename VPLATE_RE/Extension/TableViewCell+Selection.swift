//
//  TableViewCell+Selection.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 7. 3..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

extension UITableViewCell {
    func setTransparentSelect() {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.selectionStyle = .none
        self.layoutMargins = UIEdgeInsets.zero
    }
}
