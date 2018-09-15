//
//  MyTemplate.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 5. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Photos
import ObjectMapper
import AlamofireObjectMapper

enum TemplateState: Int {
    case progress, render, complete, confirmed, modified
    
    static func getType(string: String) -> TemplateState? {
        switch string {
        case "in progress".localized : return .progress
        case "rendering".localized : return .render
        case "render complete".localized : return .complete
        case "confirmed".localized : return .confirmed
        case "re editing".localized : return .modified
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .progress: return "In Progress".localized
        case .render: return "Rendering".localized
        case .complete: return "Complete".localized
        case .confirmed: return "Confirmed".localized
        case .modified: return "Editing".localized
        }
    }
}


class MyTemplate: NSObject, Mappable {
    var id:String = ""
    //var title: String = ""
    //var thumbnail: String? = nil
    //var duration: Double = 0.0
    var state: TemplateState = .progress
    var timesModified: Int = 0
    var value: Int = 0 //progress percent
    var url: String? = nil
    var originTemplate:OriginTemplate = OriginTemplate()

    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id             <- map["subtemplateId"]
        //title          <- map["title"]
        //thumbnail      <- map["thumbnail"]
        //duration       <- map["duration"]
        state          <- (map["status"], EnumTransform<TemplateState>())
        timesModified  <- map["timesModified"]
        value          <- map["progress"]
        url            <- map["renderCompleteVideo"]
        originTemplate <- map["originTemplate"]
    }
}

class OriginTemplate: NSObject, Mappable {
    var title: String = ""
    var thumbnail: String? = nil
    var duration: Double = 0.0
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        title          <- map["title"]
        thumbnail      <- map["thumbnail"]
        duration       <- map["duration"]
    }
    
}

