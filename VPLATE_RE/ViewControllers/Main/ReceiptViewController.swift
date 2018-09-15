//
//  ReceiptViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 6. 27..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class ReceiptViewController: ViewController {
    var template: Template?
    let fullIndicatorView = FullIndicatorView()
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashStringLabel: UILabel!
    @IBOutlet weak var textField: CustomizableTextField!
    @IBOutlet weak var paymentButton: UIButton!
    
    var subId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.text = ""
        self.textField.stateUIUpdate(length: 0, state: .empty)
        self.paymentButton(enable: false)
    }
    
    override func setUpViewController() {
        guard let template = self.template else {return}
        if let str = template.thumbnail,
            let thumbnailURL = URL(string: str) {
            self.thumbnailImageView.kf.setImage(with: thumbnailURL)
        }
        self.titleLabel.text = template.title
        self.hashStringLabel.text = template.hashString
        self.paymentButton.isEnabled = false
        self.paymentButton.setTitleColor( UIColor.DefaultColor.violetRed, for: .normal)
        self.paymentButton.setTitleColor( UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 1), for: .disabled)
        self.textField.delegate = self
        self.textField.label.isHidden = true
        self.textField.normaUnderLinelColor = .lightGray
        self.textField.activeUnderLineColor = UIColor.DefaultColor.skyBlue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func paymentButton(enable: Bool) {
        self.paymentButton.isEnabled = enable
        var labelColor: UIColor = .white
        var backgroundColor = UIColor.DefaultColor.violetRed
        if !enable {
            labelColor = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 1)
            backgroundColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1)
        }
        self.paymentButton.setTitleColor(labelColor, for: .normal)
        self.paymentButton.backgroundColor = backgroundColor
    }
    
    @IBAction func touchUpPayment(_ sender: UIButton) {
        payment()
    }
    
    func payment() {
        if self.paymentButton.isEnabled {
            //MARK: Coupon 확인
            TemplateService.couponValidation(code: textField.text!) { message in
                if message == "match" { // 제대로 된 쿠폰 코드를 입력했을 때
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PaymentSuccessViewController.reuseIdentifier) as! PaymentSuccessViewController
                    nextVC.delegate = self
                    nextVC.isSucceeded = true
                    self.present(nextVC, animated: true, completion: nil)
                } else if message == "duplication" { // 이미 사용된 쿠폰 코드일 때
                    let alertController = UIAlertController(title: "Your coupon was applied".localized, message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else { // 잘못된 쿠폰 코드일 때
                    let alertController = UIAlertController(title: "This coupon code does not exist".localized, message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
    
//                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PaymentSuccessViewController.reuseIdentifier) as! PaymentSuccessViewController
//                    nextVC.delegate = self
//                    nextVC.isSucceeded = false
//                    self.present(nextVC, animated: true, completion: nil)
                    
                }
            }
        }
    }
        
        //MARK: 템플릿 생성 - createTemplate
        func paymentCompletion() {
            self.fullIndicatorView.show(true)
            
            guard let template = self.template else {
                return
            }
            self.fullIndicatorView.show(true)
            
            TemplateService.getScenesInfo(
                template: template,
                success: {(template: Template) in
                    TemplateService.createTemplate(template: template, completion: { (subId) in
                        self.subId = subId
                        self.fullIndicatorView.show(false)
                        self.navigateEditorViewController(template: template)
                    })
            },
                failure: {(errString) in
                    self.fullIndicatorView.show(false)
                    self.addAlert(title: "", msg: errString)
            })
        }
        
        //MARK: EditorViewController - 템플릿 편집실 뷰로 이동
        func navigateEditorViewController(template: Template) {
            let editorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditorViewController.reuseIdentifier) as! EditorViewController
            editorVC.delegate = self
            editorVC.template = template
            editorVC.subId = self.subId
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(editorVC, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
        
    }
    
    extension ReceiptViewController: UITextFieldDelegate {
        func matches(for regex: String, in text: String) -> Bool {
            return NSPredicate(format:"SELF MATCHES %@",regex).evaluate(with: text)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textField = textField as? CustomizableTextField else {return false}
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if !matches(for: "^[a-zA-Z0-9]*$", in: prospectiveText) {
                return false
            }
            
            if prospectiveText.count > 11 {
                paymentButton(enable: true)
                textField.stateUIUpdate(length: 0, state: .complete)
            }
            else if prospectiveText.count > 0{
                paymentButton(enable: false)
                textField.stateUIUpdate(length: 0, state: .typing)
            }
            else {
                paymentButton(enable: false)
                textField.stateUIUpdate(length: 0, state: .empty)
            }
            return prospectiveText.count <= 12
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            payment()
            return true
        }
}

