//
//  EmailPersonalInformationViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class EmailPersonalInformationViewController: UIViewController, GradientService {

    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var confirmButton: ConfirmButton!
    
    let datePickerView = UIPickerView()
    let genderPickerView = UIPickerView()
    let genderList = ["Male".localized, "Female".localized]
    let yearList: [String] = (1940...2018).map { String(describing: $0) }
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.initPickerView()
        self.hideKeyboardWhenTappedAround()

    }
    
    private func setupUI() {
        self.title = "Personal Information".localized
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        
        self.nameField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderName".localized, fontSize: 17)
        self.emailField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderEmail".localized, fontSize: 17)
        self.yearField.attributedPlaceholder = placeHolderString(title: "Select".localized, fontSize: 17)
        self.genderField.attributedPlaceholder = placeHolderString(title: "Select".localized, fontSize: 17)
    }
    
    private func setupAction() {
        self.nameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.emailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.confirmButton.addTarget(self, action: #selector(touchUpConfirm), for: .touchUpInside)
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }

    @objc func textFieldDidChange() {
        if self.genderField.text?.isEmpty ?? true ||
            self.yearField.text?.isEmpty ?? true ||
            self.nameField.text?.isEmpty ?? true ||
            self.emailField.text?.isEmpty ?? true {
            self.confirmButton.isSelected = false
            self.confirmButton.isEnabled = false
        }else {
            self.confirmButton.isEnabled = true
            self.confirmButton.isSelected = true
        }
    }
    
    @objc func touchUpConfirm() {
        if let email = emailField.text,
            let name = nameField.text,
            let birth = yearField.text,
            var sex = genderField.text {
            
            if email.isValidEmailAddress() {
                
                if sex == "Male".localized {
                    sex = "M"
                } else {
                    sex = "W"
                }
                
                let user: [String: String] = ["userEmail":email,
                                              "userName":name,
                                              "userBirth":birth,
                                              "userSex":sex,
                                              "userPhoneNumber":phoneNumber!]
                
                SignService.emailCheck(email: email) { [weak self] result in
                    switch result {
                    case .success:
                        
                        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
                        if let viewController = storyboard.instantiateViewController(withIdentifier: "SetPwViewController") as? SetPwViewController {
                            viewController.type = .setUp
                            viewController.user = user
                            self?.navigationController?.pushViewController(viewController, animated: true)
                        }
                        
                    case .error(let msg):
                        
                        if msg == "mail exists" {
                            self?.addAlert(title: "Email Error".localized, msg: "This email already exists".localized)
                        }
                        
                    case .failure():
                        self?.networkingError()
                    }
                }
            } else {
                addAlert(title: "Email Error".localized, msg: "Please enter a valid email format".localized)
            }
            
        }
    }
}

extension EmailPersonalInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func initPickerView(){
        let barFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let genderDoneBtn = UIBarButtonItem(title: "Select".localized, style: .done, target: self, action: #selector(selectedGenderPickerView))
        
        let genderBar = UIToolbar(frame:barFrame)
        genderBar.setItems([btnSpace, genderDoneBtn], animated: true)
        
        let yearDoneBtn = UIBarButtonItem(title: "Select".localized, style: .done, target: self, action: #selector(selectedYearPickerView))
        let yearBar = UIToolbar(frame:barFrame)
        yearBar.setItems([btnSpace, yearDoneBtn], animated: true)
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        datePickerView.delegate = self
        datePickerView.dataSource = self
        
        genderField.inputView = genderPickerView
        genderField.inputAccessoryView = genderBar
        
        yearField.inputAccessoryView = yearBar
        yearField.inputView = datePickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPickerView {
            return genderList.count
        } else {
            return yearList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            return genderList[row]
        } else {
            return yearList[row]
        }
    }
    
    @objc func selectedGenderPickerView() {
        let row = genderPickerView.selectedRow(inComponent: 0)
        self.genderField.text = genderList[row]
        self.genderField.endEditing(true)
        
        textFieldDidChange()
    }
    
    @objc func selectedYearPickerView() {
        let row = datePickerView.selectedRow(inComponent: 0)
        self.yearField.text = yearList[row]
        self.yearField.endEditing(true)
        
        textFieldDidChange()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            self.genderField.text = genderList[row]
        } else {
            self.yearField.text = yearList[row]
        }
        
        textFieldDidChange()
        
    }
}
