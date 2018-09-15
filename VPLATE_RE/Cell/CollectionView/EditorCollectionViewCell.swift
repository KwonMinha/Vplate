//
//  EditorCollectionViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 9..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import TLPhotoPicker

class EditorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var videoIconImageView: UIImageView!
    lazy var blackView:UIView = UIView()
    func setUp(clip: Clip) {
        self.thumbnailImageView.image = nil
         DispatchQueue.main.async {
            self.numberLabel.text =  String(format: "%02d", clip.index)
            switch clip.type {
            case .video:
                self.titleLabel.text = "Video Clip Content".localized
                
                self.durationLabel.text = Util.format(TimeInterval(clip.value))
                self.videoIconImageView.isHidden = false
                self.thumbnailImageView.image = clip.getVideoThumbnail()
            case .image:
                self.titleLabel.text = "Image Clip Content".localized
                self.durationLabel.text = "\(clip.width):\(clip.height)"
                self.videoIconImageView.isHidden = true
                let imageURL = clip.imageUrl
                if let url = URL(string: imageURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        self.thumbnailImageView.image = UIImage(data: data)
                    }
                    catch(let err) {
                        debugPrint(err.localizedDescription)
                    }
                }
            default: break
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.thumbnailImageView.clipsToBounds = true
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.thumbnailImageView.addSubview(blackView)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.blackView.frame = CGRect(x: 0, y: 0,
               width: self.thumbnailImageView.frame.width, height: self.thumbnailImageView.frame.height)
        if self.thumbnailImageView.image != nil && self.thumbnailImageView.subviews.filter({$0.tag == 6605}).count == 0 {
            blackView.isHidden = false
        }
        else {
            blackView.isHidden = true
        }
        super.layoutSubviews()
    }

}
