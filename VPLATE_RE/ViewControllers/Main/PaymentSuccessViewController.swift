//
//  PaymentSuccessViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 9..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit

class PaymentSuccessViewController: ViewController {
    var delegate: ReceiptViewController?
    var isSucceeded: Bool = true
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    let imageView: UIImageView! = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.createGradientLayer()
    }
    
    override func setUpViewController() {
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.label.snp.bottom).inset(-10)
            make.bottom.equalTo(self.button.snp.top).inset(-30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        self.imageView.contentMode = .scaleAspectFit
        if isSucceeded {
            self.label.text = "Your payment was succesfull!".localized
            self.imageView.image = #imageLiteral(resourceName: "Bill")
            self.button.setTitle("Edit Template".localized, for: .normal)
            self.homeButton.isHidden = false        }
        else {
            self.label.text = "Your payment was unsuccesfull.".localized
            self.imageView.image = #imageLiteral(resourceName: "paymentFailureKai")
            self.button.setTitle("Try Again".localized, for: .normal)
            self.homeButton.isHidden = true
            
            self.imageView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.label.snp.bottom).inset(-10)
                make.bottom.equalTo(self.view.snp.bottom).inset(57)
                make.leading.trailing.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
            }

            self.view.bringSubview(toFront: self.button)
            self.view.sendSubview(toBack: imageView)
        }
    }
    
    @IBAction func touchUpEditor(_ sender: UIButton) {
        if isSucceeded {
            self.dismiss(animated: true) {
                self.delegate?.paymentCompletion()
            }
        } else {
            self.dismiss(animated: true) {
            }
        }
        
    }
    
    @IBAction func touchUpMain(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
