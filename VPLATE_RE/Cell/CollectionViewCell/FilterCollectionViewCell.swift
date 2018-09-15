//
//  FilterCollectionViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 21..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override var isSelected: Bool{
        didSet {
            switch isSelected {
            case true:
                self.contentView.backgroundColor = UIColor.red
            case false:
                self.contentView.backgroundColor = UIColor.blue
            }
        }
    }
}
