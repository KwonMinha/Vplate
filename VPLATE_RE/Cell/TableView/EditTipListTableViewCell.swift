//
//  EditTipListTableViewCell.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class EditTipListTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var thumbnailimageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backView.cornerRadius = 5.0
        self.backView.shadowColor = UIColor.black
        self.backView.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.backView.shadowRadius = 2.0
        self.backView.shadowOpacity = 0.15
        self.backView.layer.masksToBounds = false
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setUp()
    }
    
    func setUp() {
        self.backView.shadowRounded(shadowOffset: CGSize(width: 0, height: 0))
    }


}


