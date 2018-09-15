//
//  SceneCollectionViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 13..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
//79 243 175
//


extension UIColor {
    struct Filled {
        static var layer: UIColor = UIColor(red: 151/255, green: 242/255, blue: 204/255, alpha: 0.34)
        static var smallView: UIColor = UIColor(red: 75/255, green: 111/255, blue: 95/255, alpha: 1)
        static var smallLabel: UIColor = UIColor(red: 70/255, green: 255/255, blue: 173/255, alpha: 1)
    }
    
    struct Unfilled {
        static var layer: UIColor = UIColor(red: 226/255, green: 88/255, blue: 107/255, alpha: 0.34)
        static var smallView: UIColor = UIColor(red: 109/255, green: 76/255, blue: 81/255, alpha: 1)
        static var smallLabel: UIColor = UIColor(red: 212/255, green: 96/255, blue: 111/255, alpha: 1)
    }
}

class SceneCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var smallView: UIView!
    @IBOutlet weak var smallLabel: UILabel!
    
    lazy var alphaLayer = CALayer()
    
    var filled: Bool? {
        didSet {
            updateUI()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.alphaLayer.isHidden = isSelected
            self.smallView.isHidden = isSelected
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        alphaLayer.frame = self.imageView.frame
        self.imageView.layer.addSublayer(alphaLayer)
        self.smallView.cornerRadius = 5
        updateUI()
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            switch self.isSelected {
            case true:
                break
            case false:
                if let filled = self.filled
                {
                    self.alphaLayer.backgroundColor = filled ? UIColor.Filled.layer.cgColor : UIColor.Unfilled.layer.cgColor
                    self.smallView.backgroundColor = filled ? UIColor.Filled.smallView : UIColor.Unfilled.smallView
                    self.smallLabel.textColor = filled ? UIColor.Filled.smallLabel : UIColor.Unfilled.smallLabel
                    self.smallLabel.text = filled ? "✓" : "◻︎"
                }
            }
        }
    }
}
