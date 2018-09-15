//
//  GradientService.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit

protocol GradientService {
    func setGradient(view: UIView)
}

extension GradientService {
    func setGradient(view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red:145/255, green:252/255, blue:202/255, alpha:1).cgColor,
            UIColor(red:47/255, green:186/255, blue:239/255, alpha:1).cgColor
        ]
        gradient.frame = view.bounds
        gradient.startPoint = .init(x: 1, y: 0)
        gradient.endPoint = .init(x: 0, y: 1)
        gradient.locations = [0, 1]
        
        view.layer.addSublayer(gradient)
    }
}
