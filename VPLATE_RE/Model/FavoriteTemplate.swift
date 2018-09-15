//
//  FavoriteTemplate.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Photos
import ObjectMapper
import AlamofireObjectMapper

class FavoriteTemplate: NSObject, Mappable {
    var id:String = ""
    var originTemplate:FavoriteOriginTemplate = FavoriteOriginTemplate()
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id             <- map["likeId"]
        originTemplate <- map["originTemplate"]
    }
}

class FavoriteOriginTemplate: NSObject, Mappable {
    var id: String = ""
    var title: String = ""
    var subTitle: String = ""
    var thumbnail: String? = nil
    var price: Int = 0
    var duration: Double = 0.0
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id             <- map["_id"]
        title          <- map["title"]
        subTitle       <- map["hashString"]
        thumbnail      <- map["thumbnail"]
        price          <- map["price"]
        duration       <- map["duration"]
    }

}
