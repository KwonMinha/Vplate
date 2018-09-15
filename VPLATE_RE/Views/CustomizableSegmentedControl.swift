//
//  CustomSegmentedControl.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 9..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol CustomizableSegmentedControlDelegate where Self: UIViewController{
    @objc func valueChanged(_ sender: CustomizableSegmentedControl)
}

@IBDesignable
class CustomizableSegmentedControl: UISegmentedControl {
    @IBInspectable var bottomBarHeight: CGFloat = 3.5
    @IBInspectable var bottomBarColor: UIColor? = nil
    var delegate: CustomizableSegmentedControlDelegate?
    var bottomBar: UIView = UIView()
    var selectedType: ClipType?
    var fixedValue: CGFloat?
    var bottomColor: UIColor?
    lazy var width:CGFloat = {
        var width:CGFloat = 1
        if let fixedValue = self.fixedValue {
            width = self.frame.width / fixedValue
        } else {
            width = self.frame.width / CGFloat(self.numberOfSegments)
        }
        return width
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        valueChangedUIUpdate(self)
    }
    
    func setUp() {
        self.addTarget(self, action: #selector(valueChangedUIUpdate(_:)), for: .valueChanged)
        self.addTarget(self.delegate, action: #selector(delegate?.valueChanged(_:)), for: .valueChanged)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 15, y: self.frame.height - self.bottomBar.frame.height / 2, width: self.frame.width - 30, height: 1)
        if let color = self.bottomColor {
            bottomBorder.backgroundColor = color.cgColor
        }
        self.layer.addSublayer(bottomBorder)
        self.setBottomBar()
        
        self.tintColor = .clear
        self.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor: UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)],
                                    for: .normal)
        self.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor: UIColor.DefaultColor.skyBlue],
                                    for: .selected)
        
        self.addSubview(bottomBar)
        addBadge()
    }
    
    func setBottomBar() {
        let xPos = self.frame.width / CGFloat(self.numberOfSegments) / 2 - width / 2
        let rect = CGRect(x: xPos, y: self.frame.height - self.bottomBarHeight + bottomBarHeight/2, width: width, height: bottomBarHeight)
        self.bottomBar.frame = rect
        if let barColor = self.bottomBarColor {
            self.bottomBar.backgroundColor = barColor
        }
        else {
            self.bottomBar.createGradientLayer(startColor: UIColor.DefaultColor.skyBlue,
                                     endColor: UIColor.DefaultColor.lightGreen,
                                     startPoint: CGPoint(x: 0, y: 0),
                                     endPoint: CGPoint(x: 1, y: 0))
            self.bottomBar.makeRoundedView(corners: [.allCorners], radius:  self.bottomBar.frame.height / 2)
        }
    }
    
    override var selectedSegmentIndex: Int {
        didSet {
            if selectedSegmentIndex >= 0 {
                valueChangedUIUpdate(self)
            }
        }
    }
    
    func setSelectedSegmentIndex(_ index: Int) {
        self.selectedSegmentIndex = index
    }
    
    
    
    @objc func valueChangedUIUpdate(_ sender: CustomizableSegmentedControl) {
        if sender.selectedSegmentIndex >= 0  {
            if let title = self.titleForSegment(at: sender.selectedSegmentIndex) {
                self.selectedType = ClipType.getType(string: title)
            }
            let rect = self.subviews[sender.selectedSegmentIndex].frame
            UIView.animate(withDuration: 0.5) {
                let inset = self.frame.width / CGFloat(self.numberOfSegments) / 2 - self.width / 2
                self.bottomBar.frame.origin.x = (self.frame.width / CGFloat(self.numberOfSegments)) * CGFloat(sender.selectedSegmentIndex) + inset
            }
        }
    }
    
    func addBadge() {
        for indexView in self.subviews {
            let text = "0"
            let labelHeight: CGFloat = 20
            let label = DesignableLabel()
            indexView.addSubview(label)
            label.topInset = 0
            label.bottomInset = 0
            label.leftInset = 3
            label.rightInset = 3
            label.font = label.font.withSize(14)
            label.text = text
            label.textAlignment = .center
            label.textColor = .white
            label.cornerRadius = labelHeight/2
            label.layer.masksToBounds = true
            label.backgroundColor = .red
            label.isHidden = true
        }
    }
    
    func noSetBadge(index: Int, value: Int) {    let text = String(describing: value)
        let indexView = self.subviews[index] as UIView
        let labelHeight: CGFloat = 20
        var designableLabel:DesignableLabel?
        for view in indexView.subviews {
            if view is DesignableLabel {
                designableLabel = (view as! DesignableLabel)
            }
        }
        
        guard let label = designableLabel else {return}
        let textWidth = text.stringWidth
        label.text = text
        label.isHidden = true
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.standard.setValue(UIApplication.shared.applicationIconBadgeNumber, forKey: "badgeCount")
        UserDefaults.standard.synchronize()
    }
    
    func setBadge(index: Int, value: Int) {
        let text = String(describing: value)
        let indexView = self.subviews[index] as UIView
        let labelHeight: CGFloat = 20
        var designableLabel:DesignableLabel?
        for view in indexView.subviews {
            if view is DesignableLabel {
                designableLabel = (view as! DesignableLabel)
            }
        }
        
        guard let label = designableLabel else {return}
        let textWidth = text.stringWidth
        label.text = text
        label.isHidden = false
        label.snp.remakeConstraints { (make) in
            make.top.trailing.equalToSuperview()
            make.height.equalTo(labelHeight)
            if textWidth >= labelHeight - label.leftInset - label.rightInset {
                make.width.equalTo(textWidth + 10)
            }
            else {
                make.width.equalTo(labelHeight)
            }
        }
    }
 
}
