//
//  GradientProgressView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 5. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

@IBDesignable
class GradientProgressView: UIProgressView {

    
    lazy private var gradientLayer: CAGradientLayer = self.initGradientLayer()
    
    @IBInspectable public var gradientColors: [CGColor] = [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor] {
        didSet {
            self.gradientLayer.colors = gradientColors
        }
    }
    
    @IBInspectable override var cornerRadius: CGFloat {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
    }
    public override var trackTintColor: UIColor? {
        didSet {
            self.backgroundColor = trackTintColor
        }
    }
    
    public override var progressTintColor: UIColor? {
        didSet {
            if progressTintColor != UIColor.clear {
                progressTintColor = UIColor.clear
            }
        }
    }
    
    
    // MARK: - init methods
    
    override public init (frame : CGRect) {
        super.init(frame : frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func setProgress(_ progress: Float, animated: Bool) {
        super.setProgress(progress, animated: animated)
        updateGradientLayer()
    }
    
    // MARK: - Private methods
    
    private func setup() {
        self.layer.cornerRadius = cornerRadius
        self.layer.addSublayer(gradientLayer)
        progressTintColor = UIColor.clear
        gradientLayer.colors = gradientColors
    }
    
    private func initGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = sizeByPercentage(originalRect: bounds, width: CGFloat(progress))
        gradientLayer.anchorPoint = CGPoint(x: 0, y: 0)
        gradientLayer.position = CGPoint(x: 0, y: 0)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.masksToBounds = true
        return gradientLayer
    }
    
    private func updateGradientLayer() {
        gradientLayer.frame = sizeByPercentage(originalRect: bounds, width: CGFloat(progress))
        gradientLayer.cornerRadius = cornerRadius
    }
    
    private func sizeByPercentage(originalRect: CGRect, width: CGFloat) -> CGRect {
        let newSize = CGSize(width: originalRect.width * width, height: originalRect.height)
        return CGRect(origin: originalRect.origin, size: newSize)
    }
}
