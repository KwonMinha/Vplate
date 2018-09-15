//
//  EditTipVideoTableViewCell.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class EditTipVideoTableViewCell: UITableViewCell {
    @IBOutlet weak var player: Player!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
