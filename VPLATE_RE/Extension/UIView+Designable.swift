//
//  Designable.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 6..
//  Copyright © 2018년 이광용. All rights reserved.
//

//
//  Designable.swift
//  Diary
//
//  Created by 이광용 on 2018. 2. 10..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

@IBDesignable
class DesignableButton: UIButton {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

@IBDesignable
class DesignableLabel: UILabel {
    var topInset:       CGFloat = 5
    var rightInset:     CGFloat = 5
    var bottomInset:    CGFloat = 5
    var leftInset:      CGFloat = 5

    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

@IBDesignable
class DesignableImageView: UIImageView{
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat{
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    func shadowRounded(cornerRadius: CGFloat = 5.0,
                       shadowColor: UIColor = UIColor.black,
                       shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0),
                       shadowRadius: CGFloat = 2.0,
                       shadowOpacity: Float = 0.15) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        let shadowLayer = UIView()
        self.superview?.insertSubview(shadowLayer, at: 0)
        shadowLayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        shadowLayer.tag = 6604
        shadowLayer.backgroundColor = UIColor.clear
        shadowLayer.layer.shadowColor = shadowColor.cgColor
        shadowLayer.layer.shadowOffset = shadowOffset
        shadowLayer.layer.shadowRadius = shadowRadius
        shadowLayer.layer.shadowOpacity = shadowOpacity
        shadowLayer.layer.masksToBounds = false
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
    }
    
    func removeShadow() {
        if let subViews = self.superview?.subviews {
            for view in subViews {
                if view.tag == 6604 { view.removeFromSuperview() }
            }
        }
    }
    
    func makeRoundedView(corners: UIRectCorner, radius: CGFloat = 5.0){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
    
    func createGradientLayer(startColor: UIColor = UIColor.DefaultColor.lightGreen,
                             endColor: UIColor = UIColor.DefaultColor.skyBlue,
                             startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
                             endPoint: CGPoint = CGPoint(x: 0.0, y: 1.0)) {
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
//            self.layer.insertSublayer(gradientLayer, at: 0)
        }
        else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func tintedWithLinearGradientColors(colorsArr: [CGColor]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1, y: -1)
        
        context.setBlendMode(.normal)
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        // Create gradient
        let colors = colorsArr as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
        
        // Apply gradient
        context.clip(to: rect, mask: self.cgImage!)
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.size.height), options: .drawsAfterEndLocation)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage!
    }
}
