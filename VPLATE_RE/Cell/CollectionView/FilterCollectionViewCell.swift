//
//  FilterCollectionViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setNeedsLayout()
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
        super.layoutSubviews()
    }
    
    func setUp(){
        self.backView.removeShadow()
        self.iconImageView.contentMode = .scaleAspectFill
        self.backView.cornerRadius = self.backView.frame.height / 2
        self.backView.layer.masksToBounds = true
        self.backView.borderColor = isSelected ? .clear : UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.backView.borderWidth = isSelected ? 0 : 1
        self.titleLabel.textColor = isSelected ? UIColor.DefaultColor.skyBlue : UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        
        switch self.isSelected {
            case true:
                self.backView.shadowRounded(cornerRadius: self.backView.frame.height / 2,
                                                 shadowOffset: CGSize(width: 0, height: 4),
                                                 shadowRadius: 4,
                                                 shadowOpacity: 0.3)
                self.iconImageView.image = self.iconImageView.image?.tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
            case false:
                self.iconImageView.image = self.iconImageView.image?.tinted(with: UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1))
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
            self.layoutSubviews()
        }
    }
}
