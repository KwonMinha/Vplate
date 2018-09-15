//
//  TutorialView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 6. 26..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit
class TutorialView: UIView {
    let componentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        self.insertSubview(componentView, at: 0)
        //componentView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        componentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.snp.edges)
        }
    }
    
    func makeHole(paths: [UIBezierPath]) {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath()
        for item in paths {
            path.append(item)
           
        }
        path.append(UIBezierPath(rect: self.bounds))
        path.usesEvenOddFillRule = true
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor.white.cgColor
        
        self.componentView.layer.mask = maskLayer
    }
    
    func reset() {
        for view in self.subviews {
            if view is DesignableButton || view is UIImageView || view.tag == 1000{
                
            }
            else {
                view.removeFromSuperview()
            }
        }
        setUp()
    }
}

extension UIView {
    func getPath() -> UIBezierPath {
        let path = UIBezierPath()
        //left top
        path.move(to: CGPoint(x: self.frame.minX, y: self.frame.minY))
        //left bottom
        path.addLine(to: CGPoint(x: self.frame.minX, y: self.frame.maxY))
        //right bottom
        path.addLine(to: CGPoint(x: self.frame.maxX, y: self.frame.maxY))
        //right top
        path.addLine(to: CGPoint(x: self.frame.maxX, y: self.frame.minY))
        path.close()
        return path
    }
}

extension CGRect {
    func getPath() -> UIBezierPath {
        let path = UIBezierPath()
        //left top
        path.move(to: CGPoint(x: self.minX, y: self.minY))
        //left bottom
        path.addLine(to: CGPoint(x: self.minX, y: self.maxY))
        //right bottom
        path.addLine(to: CGPoint(x: self.maxX, y: self.maxY))
        //right top
        path.addLine(to: CGPoint(x: self.maxX, y: self.minY))
        path.close()
        return path
    }
}

