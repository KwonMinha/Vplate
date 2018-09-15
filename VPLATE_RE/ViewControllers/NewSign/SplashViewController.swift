//
//  SplashViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, GradientService {

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradient(view: self.view)
    }

}
