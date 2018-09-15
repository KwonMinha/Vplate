//
//  AccountSettingViewController.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class AccountSettingViewController: UIViewController {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var contentField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    
    let placePickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let metropoList = Address.metropolitan.map{$0.rawValue}
    var cityList = Address.metropolitan.map { Address.city(metropolitan: $0) }
    let typeList = CompanyType.types
    var user = [String:String]()
    
    var accounts: AccountSetting?
    
    var isCheck: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupAction()
        self.initPickerView()
        self.hideKeyboardWhenTappedAround()
        
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Back-1"), style: .plain, target: self, action: #selector(touchUpBack(_:)))
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        let barButton: UIBarButtonItem = UIBarButtonItem(title: "Done".localized,
                                                         style: UIBarButtonItemStyle.done,
                                                         target: self,
                                                         action: #selector(touchUpCompletion(_:)))
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        accountInit()
    }
    
    func accountInit() {
        TemplateService.accountSettingInit { (accountData) in
            self.accounts = accountData
            
            if accountData.bizUser == 1 {
                self.checkButton.isSelected = false
                self.contentField.text = accountData.bizContent
                self.placeField.text = accountData.bizAddress
                self.typeField.text = accountData.bizForm
            } else {
                self.checkButton.isSelected = true
            }
        }
    }
    
    @objc func touchUpCompletion(_ sender: UIBarButtonItem) {
        if contentField.text == "" ||  placeField.text == "" ||  typeField.text == "" {
            let alert = UIAlertController(title: "", message: "Please fill all the values".localized, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "YES".localized, style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            if checkButton.isSelected == false {
                self.isCheck = 1
            } else {
                self.isCheck = 0
            }
            TemplateService.accountSettingUpdate(bizUser: self.isCheck!, bizContent: contentField.text!, bizAddress: placeField.text!, bizForm: typeField.text!) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: Navigation Item - Reft Back Button Action
    @objc func touchUpBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        self.title = "Account Setting".localized
        self.checkButton.roundBorder()
        self.checkButton.borderWidth = 1
        self.checkButton.borderColor = .white
        
        self.contentField.attributedPlaceholder = self.placeHolderString(title: "e.g. 커피전문점",
                                                                         fontSize: 17)
        self.placeField.attributedPlaceholder = self.placeHolderString(title: "도/시 시/군/구",
                                                                       fontSize: 17)
        self.typeField.attributedPlaceholder = self.placeHolderString(title: "Select".localized,
                                                                      fontSize: 17)
        self.contentField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    private func setupAction() {
        self.checkButton.addTarget(self, action: #selector(self.touchUpCheckButton(_:)),
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
            contentField.isEnabled = false
            placeField.isEnabled = false
            typeField.isEnabled = false
        case false:
            button.backgroundColor = .clear
            button.clearShadow()
            contentField.isEnabled = true
            placeField.isEnabled = true
            typeField.isEnabled = true
            self.checkEmpty()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.checkEmpty()
    }
    
    
    func checkEmpty() {
        if self.contentField.text?.isEmpty ?? true ||
            self.placeField.text?.isEmpty ?? true ||
            self.typeField.text?.isEmpty ?? true {
            
        } else {
            
        }
    }
}

extension AccountSettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
