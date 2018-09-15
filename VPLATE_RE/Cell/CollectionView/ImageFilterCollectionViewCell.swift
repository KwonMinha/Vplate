//
//  ImageFilterCollectionViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 4. 30..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class ImageFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var filter: ImageFilter? {
        didSet {
            self.title.text = filter?.getDescription()
//            self.thumbnail.image = filter?.image
        }
    }
    
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true: title.textColor = UIColor.DefaultColor.skyBlue
            case false: title.textColor = UIColor.white
            }
        }
    }
}
