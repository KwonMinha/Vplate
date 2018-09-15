//
//  SlideMenuView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 21..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenu(state: Bool)
}

@IBDesignable
class SlideMenuView: UIView {
    //MARK -: Property
    //MARK : IBOutlet
    var backgroundView = UIView()
    var menuView = UIView()
    @IBOutlet private weak var menuTrailing: NSLayoutConstraint!
    @IBOutlet private weak var menuWidth: NSLayoutConstraint!
    //MARK : Stored
    var delegate: HomeViewController?
    private let dismsissConstraint: CGFloat = 0.0
    private let showConstraint: CGFloat = 0.0
    private var menuViewSize: CGSize {
        return CGSize(width: self.frame.width * 0.8, height: self.frame.height)
    }
    
    //MARK : Calculated / Stored
    var isOpened: Bool = false {
        didSet {
            DispatchQueue.main.async {
                switch self.isOpened {
                case true:
                    //                (414.0, 0.0, 331.2, 672.0)
                    self.menuView.frame = CGRect(x: self.frame.width, y: 0, width: self.menuViewSize.width, height: self.menuViewSize.height)
                    UIView.animate(withDuration: 1,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 1,
                                   options: .curveEaseOut,
                                   animations: {
                                    self.backgroundView.alpha = 0.5
                                    self.menuView.frame = CGRect(x: self.frame.width - self.menuViewSize.width, y: 0, width: self.menuViewSize.width, height: self.menuViewSize.height)
                                    self.delegate?.navigationItem.rightBarButtonItem?.isEnabled = false
                                    self.layoutIfNeeded()
                    },
                                   completion: { (completion) in
                                    self.delegate?.navigationItem.rightBarButtonItem?.isEnabled = true
                    })
                case false:
                    self.menuView.frame = CGRect(x: self.frame.width - self.menuViewSize.width, y: 0, width: self.menuViewSize.width, height: self.menuViewSize.height)
                    UIView.animate(withDuration: 1, animations: {
                        self.backgroundView.alpha = 0
                        self.menuView.frame = CGRect(x: self.frame.width, y: 0, width: self.menuViewSize.width, height: self.menuViewSize.height)
                        self.delegate?.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.layoutIfNeeded()
                    }, completion: { (completion) in
                        self.removeFromSuperview()
                        self.delegate?.navigationItem.rightBarButtonItem?.isEnabled = true
                    })
                }
            }
            (delegate as! SlideMenuDelegate).slideMenu(state: isOpened)
        }
    }
    
    //MARK -: Method
    func setUp() {
        guard let window = UIApplication.shared.keyWindow else {return}
        window.addSubview(self)

        if let navigationFrame = self.delegate?.navigationController?.navigationBar.frame {
            let totalNavHeight = navigationFrame.height + navigationFrame.minY
            self.frame = CGRect(x: 0,
                                y: totalNavHeight,
                                width: window.frame.width,
                                height:  window.frame.height - totalNavHeight)
//            self.menuTrailing.constant = -self.menuWidth.constant
            self.backgroundColor = UIColor.clear
            self.backgroundView.backgroundColor = UIColor.black
            self.backgroundView.alpha = 0.0
            self.backgroundView.frame = CGRect(x: 0,
                                               y: 0,
                                               width: self.frame.width,
                                               height: self.frame.height)
            self.addSubview(backgroundView)
            self.menuView.frame = CGRect(x: self.frame.width,
                                         y: 0,
                                         width: self.menuViewSize.width,
                                         height: self.menuViewSize.height)
            self.addSubview(menuView)
        }
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))

        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: FilterViewController.reuseIdentifier) as! FilterViewController
        controller.delegate = delegate
        controller.slideDelegate = self
        self.menuView.addSubview(controller.view)
        controller.view.frame = CGRect(x: 0, y: 0, width: self.menuView.frame.width, height: self.frame.height )
        let root = window.rootViewController!
        root.addChildViewController(controller)
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParentViewController: root)
        self.layoutIfNeeded()
    }
    
    @objc func dismiss() {
        self.isOpened = false
    }
}

