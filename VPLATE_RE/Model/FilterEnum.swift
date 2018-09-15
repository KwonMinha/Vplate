//
//  FilterEnum.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 21..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

enum Categorize: Int {
    case all, restaurant, foodTruck, cafe, fashion, travel, hospital, service, product
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Categorize(rawValue: max) { max += 1 }
        return max
    }()
    
    func getDescription() -> String {
        switch self {
        case .all: return "All".localized
        case .restaurant: return "Restaurant".localized
        case .foodTruck: return "Foodtruck".localized
        case .cafe: return "Cafe".localized
        case .fashion: return "Fashion".localized
        case .travel: return "Travel".localized
        case .hospital: return "Hospital".localized
        case .service: return "Service".localized
        case .product: return "Product".localized
        }
    }
    
    func getIconImage() -> UIImage {
        switch self {
        case .all: return #imageLiteral(resourceName: "CategoryAll")
        case .restaurant: return #imageLiteral(resourceName: "Food")
        case .foodTruck: return #imageLiteral(resourceName: "FoodTruck")
        case .cafe: return #imageLiteral(resourceName: "Cafe")
        case .fashion: return #imageLiteral(resourceName: "Fashion")
        case .travel: return #imageLiteral(resourceName: "Travel")
        case .hospital: return #imageLiteral(resourceName: "Hospital")
        case .service: return #imageLiteral(resourceName: "Service")
        case .product: return #imageLiteral(resourceName: "Product")
        }
    }
}

enum Ratio: Int {
    case all, ratio1x1 , ratio16x9 , ratio9x16, ratio4x5
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Ratio(rawValue: max) { max += 1 }
        return max
    }()
    
    func getDescription() -> String {
        switch self {
        case .all: return "All".localized
        case .ratio1x1: return "1:1"
        case .ratio16x9: return "16:9"
        case .ratio9x16: return "9:16"
        case .ratio4x5: return "4:5"
        }
    }
    
    func getIconImage() -> UIImage {
        switch self {
        case .all: return #imageLiteral(resourceName: "RatioAll")
        case .ratio1x1: return #imageLiteral(resourceName: "Ratio1x1")
        case .ratio16x9: return #imageLiteral(resourceName: "Ratio16x9")
        case .ratio9x16: return #imageLiteral(resourceName: "Ratio9x16")
        case .ratio4x5: return #imageLiteral(resourceName: "FourFive")
        }
    }
    
    func getSize() -> CGSize? {
        switch self {
        case .all: return nil
        case .ratio1x1: return CGSize(width: 1, height: 1)
        case .ratio16x9: return CGSize(width: 16, height: 9)
        case .ratio9x16: return CGSize(width: 9, height: 16)
        case .ratio4x5: return CGSize(width: 4, height: 5)
        }
    }
}

enum Channel: Int {
    case all, facebook, instagram, youtube, blog, enterprise, signboard
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Channel(rawValue: max) { max += 1 }
        return max
    }()

    func getDescription() -> String {
        switch self {
        case .all: return "All".localized
        case .facebook: return "Facebook".localized
        case .instagram: return "Instagram".localized
        case .youtube: return "YouTube".localized
        case .blog: return "Blog".localized
        case .enterprise: return "Business Pitching".localized
        case .signboard: return "Digital Signage".localized
        }
    }
    
    func getIconImage() -> UIImage {
        switch self {
        case .all: return #imageLiteral(resourceName: "CategoryAll").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        case .facebook: return #imageLiteral(resourceName: "Facebook").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        case .instagram: return #imageLiteral(resourceName: "Instagram").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        case .youtube: return #imageLiteral(resourceName: "Youtube").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        case .blog: return #imageLiteral(resourceName: "Blog").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        case .enterprise: return #imageLiteral(resourceName: "Enterprise").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        case .signboard: return #imageLiteral(resourceName: "Signboard").tintedWithLinearGradientColors(colorsArr: [UIColor.DefaultColor.skyBlue.cgColor, UIColor.DefaultColor.lightGreen.cgColor])
        }
    }
}
