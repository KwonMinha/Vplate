//
//  CompanyImformationViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class CompanyImformationViewController: UIViewController, GradientService {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var contentField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var confirmButton: ConfirmButton!
    
    let placePickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let metropoList = Address.metropolitan.map{$0.rawValue}
    var cityList = Address.metropolitan.map { Address.city(metropolitan: $0) }
    let typeList = CompanyType.types
    
    
    var user = [String:String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.initPickerView()
        self.hideKeyboardWhenTappedAround()

    }
    
    private func setupUI() {
        self.title = "Business Information".localized
        self.backgroundView.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        self.checkButton.roundBorder()
        self.checkButton.borderWidth = 1
        self.checkButton.borderColor = .white
        
        self.contentField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderBizContent".localized,
                                                                         fontSize: 17)
        self.placeField.attributedPlaceholder = self.placeHolderString(title: "PlaceholderBizAddress".localized,
                                                                       fontSize: 17)
        self.typeField.attributedPlaceholder = self.placeHolderString(title: "Select".localized,
                                                                      fontSize: 17)
        self.contentField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.confirmButton.isEnabled = false
    }
    
    private func setupAction() {
        self.checkButton.addTarget(self, action: #selector(self.touchUpCheckButton(_:)),
                                   for: .touchUpInside)
        self.confirmButton.addTarget(self, action: #selector(touchUpConfirmButton),
                                     for: .touchUpInside)
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    @objc func touchUpCheckButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        switch button.isSelected {
        case true:
            button.backgroundColor = .white
            button.dropShadow()
            confirmButton.isEnabled = true
            confirmButton.isSelected = true
            contentField.isEnabled = false
            placeField.isEnabled = false
            typeField.isEnabled = false
        case false:
            button.backgroundColor = .clear
            button.clearShadow()
            contentField.isEnabled = true
            placeField.isEnabled = true
            typeField.isEnabled = true
            confirmButton.isSelected = false
            confirmButton.isEnabled = false
            self.checkEmpty()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.checkEmpty()
    }
    
    @objc func touchUpConfirmButton() {
        if !checkButton.isSelected {
            if let content = contentField.text, let place = placeField.text, let type = typeField.text {
                user["bizUser"] = "1"
                user["bizContent"] = content
                user["bizAddress"] = place
                user["bizForm"] = type
            }
        } else {
            user["bizUser"] = "0"
            user["bizContent"] = ""
            user["bizAddress"] = ""
            user["bizForm"] = ""
        }
        
        print(user)
        
        if user["socialKey"] != nil {
            self.snsSignUp(user: user)
        } else {
            self.emailSignUp(user: user)
        }
    }
    
    private func snsSignUp(user: [String:String]) {
        SignService.snsSignUp(user: user) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                
                let storyboard = UIStoryboard(name: "Sign", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "CompleteViewController") as? CompleteViewController {
                    viewController.user = self.user
                    self.present(viewController, animated: true, completion: nil)
                }
                
            case .error(let message):
                print(message)
                
            case .failure():
                self.networkingError()
            }
        }
    }
    
    private func emailSignUp(user: [String:String]) {
        SignService.signUp(user: user) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                
                let storyboard = UIStoryboard(name: "Sign", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "CompleteViewController") as? CompleteViewController {
                    viewController.user = self.user
                    self.present(viewController, animated: true, completion: nil)
                }
                
            case .error(let message):
                print(message)
                
                if message == "Mail exists" {
                    self.addAlert(title: "Register Error".localized, msg: "Please enter a valid email format".localized)
                }
                
            case .failure():
                self.networkingError()
            }
        }
    }
    
    func checkEmpty() {
        if self.contentField.text?.isEmpty ?? true ||
            self.placeField.text?.isEmpty ?? true ||
            self.typeField.text?.isEmpty ?? true {
            confirmButton.isEnabled = false
            confirmButton.isSelected = false
        } else {
            confirmButton.isEnabled = true
            confirmButton.isSelected = true
        }
    }

}

extension CompanyImformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func initPickerView(){
        let barFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: self,
                                       action: nil)
        let placeDoneBtn = UIBarButtonItem(title: "Select".localized,
                                           style: .done,
                                           target: self,
                                           action: #selector(selectedPlacePickerView))
        
        let placeBar = UIToolbar(frame:barFrame)
        placeBar.setItems([btnSpace, placeDoneBtn], animated: true)
        
        let typeDoneBtn = UIBarButtonItem(title: "Select".localized,
                                          style: .done,
                                          target: self,
                                          action: #selector(selectedTypePickerView))
        let typeBar = UIToolbar(frame:barFrame)
        typeBar.setItems([btnSpace, typeDoneBtn],
                         animated: true)
        
        placePickerView.delegate = self
        placePickerView.dataSource = self
        typePickerView.delegate = self
        typePickerView.dataSource = self
        
        placeField.inputView = placePickerView
        placeField.inputAccessoryView = placeBar
        
        typeField.inputAccessoryView = typeBar
        typeField.inputView = typePickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == placePickerView {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == placePickerView {
            if component == 0 {
                return self.metropoList.count
            } else {
                let selected = pickerView.selectedRow(inComponent: 0)
                return self.cityList[selected].count
                
            }
            
        } else {
            return typeList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == placePickerView {
            if component == 0 {
                return self.metropoList[row]
            } else {
                let selected = pickerView.selectedRow(inComponent: 0)
                return self.cityList[selected][row]
            }
        } else {
            return typeList[row]
        }
    }
    
    @objc func selectedPlacePickerView() {
        let metropoIndex = placePickerView.selectedRow(inComponent: 0)
        let cityIndex = placePickerView.selectedRow(inComponent: 1)
        let metropo = self.metropoList[metropoIndex]
        let city = self.cityList[metropoIndex][cityIndex]
        self.placeField.text = metropo + " " + city
        self.placeField.endEditing(true)
    }
    

    
    @objc func selectedTypePickerView() {
        self.typeField.text = self.typeList[typePickerView.selectedRow(inComponent: 0)]
        self.typeField.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == placePickerView {
            pickerView.reloadComponent(1)
            let metropoIndex = placePickerView.selectedRow(inComponent: 0)
            let cityIndex = placePickerView.selectedRow(inComponent: 1)
            let metropo = self.metropoList[metropoIndex]
            let city = self.cityList[metropoIndex][cityIndex]
            self.placeField.text = metropo + " " + city
        } else {
            self.typeField.text = self.typeList[pickerView.selectedRow(inComponent: 0)]
        }
        
        self.checkEmpty()
    }
    
}
