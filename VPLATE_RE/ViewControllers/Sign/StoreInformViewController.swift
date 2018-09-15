 //
//  StoreInformViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 13..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import McPicker
class StoreInformViewController: ViewController {

    var metropolitan: [[String]] = [Address.metropolitan.map{$0.rawValue}]
    var city: [[String]] = [Address.city(metropolitan: .seoul)]
    
    @IBOutlet weak var metropolitanButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func setUpViewController() {
        self.cityButton.isEnabled = false
    }
    
    @IBAction func touchUpMetropolitan(_ sender: UIButton) {
        
        let mcPicker = McPicker(data: metropolitan)
        mcPicker.showAsPopover(fromViewController: self, sourceView: sender, cancelHandler: {
            print("Pop Over Canceled")
        }) { (selections) in
            if let metro = selections[0] {
                print("\(metro)")
                let city = Address.city(metropolitan: Address.metropolitan.filter{ $0.rawValue == metro }[0])
                self.city = [city]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                    self.openCityPicker(sender: self.cityButton)
                })
            }
        }
        
    }
    
    @IBAction func touchUpCity(_ sender: UIButton) {
        openCityPicker(sender: sender)
    }
    
    func openCityPicker(sender :UIButton) {
        self.cityButton.isEnabled = true
        let mcPicker = McPicker(data: city)
        mcPicker.showAsPopover(fromViewController: self, sourceView: sender, cancelHandler: {
            print("Pop Over Canceled")
        }) { (selections) in
            if let city = selections[0] {
                print("\(city)")
            }
        }
    }
}


extension Date {
    
    // -> Date System Formatted Medium
    func ToDateMediumString() -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: self)
    }
}
