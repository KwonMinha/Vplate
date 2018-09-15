//
//  HomeTableViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import Kingfisher
class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var priceButton: UIButton!
    
    var info: Template? {
        didSet {
            self.titleLabel.text = info?.title
            self.hashLabel.text = info?.hashString
            if let str = info?.thumbnail,
                let thumbnailURL = URL(string: str) {
                self.thumbnailImageView.kf.setImage(with: thumbnailURL) 
            }
            self.timeButton.setTitle(Util.format(info?.duration ?? 0), for: .normal)
            self.priceButton.setTitle("Needs Coupon".localized, for: .normal)
//            if let price = info?.price {
//                self.priceButton.setTitle(price == 0 ? "FREE" : "\(Int(price))"+"Money".localized, for: .normal)
//            }
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setUp()
    }

//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setUp()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setUp()
//    }
//    override func awakeFromNib() {
//        setUp()
//    }
    func setUp() {
        self.backView.shadowRounded(shadowOffset: CGSize(width: 0, height: 0))
    }
}
