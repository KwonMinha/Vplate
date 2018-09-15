//
//  LikeTableViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 4. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class LikeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var info: FavoriteTemplate? {
        didSet {
            self.titleLabel.text = info?.originTemplate.title
            self.hashLabel.text = info?.originTemplate.subTitle
            if let str = info?.originTemplate.thumbnail,
                let thumbnailURL = URL(string: str) {
                self.thumbnailImageView.kf.setImage(with: thumbnailURL)
            }
            self.durationButton.setTitle(Util.format(info?.originTemplate.duration ?? 0), for: .normal)
            if let price = info?.originTemplate.price {
                self.priceButton.setTitle(price == 0 ? "FREE" : "\(Int(price))"+"Money".localized, for: .normal)
            }
        }
    }
}
