//
//  PersonalInformationViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class SNSPersonalInformationViewController: UIViewController, GradientService {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var nextButton: ConfirmButton!
    
    let datePickerView = UIPickerView()
    let genderPickerView = UIPickerView()
    let genderList = ["Male".localized, "Female".localized]
    let yearList: [String] = (1940...2018).map { String(describing: $0) }
    var user = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.initPickerView()
        self.hideKeyboardWhenTappedAround()

    }
    
    private func setupUI() {
        self.title = "Personal Information".localized
        self.backgroundView.layoutIfNeeded()
        setGradient(view: self.backgroundView)
        
        self.yearField.attributedPlaceholder = placeHolderString(title: "Select".localized, fontSize: 17)
        self.genderField.attributedPlaceholder = placeHolderString(title: "Select".localized, fontSize: 17)
    }
    
    private func placeHolderString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.7)] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    @IBAction func actionBtnNext() {
        if self.genderField.text?.isEmpty ?? true || self.yearField.text?.isEmpty ?? true {
            return
        }
        
        if let birth = self.yearField.text,
            var sex = self.genderField.text {
            let storyboard = UIStoryboard(name: "Sign", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "CompanyImformationViewController") as? CompanyImformationViewController {
                if sex == "Male".localized {
                    sex = "M"
                } else {
                    sex = "W"
                }
                
                user["userBirth"] = birth
                user["userSex"] = sex
                viewController.user = self.user
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension SNSPersonalInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func initPickerView(){
        let barFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)

        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let genderDoneBtn = UIBarButtonItem(title: "Select".localized, style: .done, target: self, action: #selector(selectedGenderPickerView))
        
        let genderBar = UIToolbar(frame:barFrame)
        genderBar.setItems([btnSpace, genderDoneBtn], animated: true)
        
        let yearDoneBtn = UIBarButtonItem(title: "Selct".localized, style: .done, target: self, action: #selector(selectedYearPickerView))
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
    }
    
    @objc func selectedYearPickerView() {
        let row = datePickerView.selectedRow(inComponent: 0)
        self.yearField.text = yearList[row]
        self.yearField.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            self.genderField.text = genderList[row]
        } else {
            self.yearField.text = yearList[row]
        }
    }
}
