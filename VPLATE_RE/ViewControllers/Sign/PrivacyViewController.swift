//
//  PrivacyViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 14..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import McPicker

class PrivacyViewController: ViewController {

    @IBOutlet weak var birthDayButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func setUpViewController() {
    }
    
    @IBAction func touchUpBirthDayButton(_ sender: UIButton) {
        var birthYear:[[String]] = []
        var years: [String] = []
        for year in 1970 ... 2010 {
            years.append("\(year)년")
        }
        birthYear.append(years)
        
        McPicker.showAsPopover(data: birthYear, fromViewController: self, sourceView: sender, cancelHandler: {
            print("PopOver Cancled")
        }) { (selections: [Int: String]) in
            if let year = selections[0] {
                print(year)
            }
        }
    }
    
    
    @IBAction func touchUpNextVC(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoreInformViewController.reuseIdentifier)
        self.present(nextVC, animated: true, completion: nil)
    }
}

