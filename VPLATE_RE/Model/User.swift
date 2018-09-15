//
//  User.swift
//  VPLATE_RE
//
//  Created by 이혜진 on 2018. 7. 3..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import ObjectMapper

class User: NSObject, Mappable {
    
    var message: String = ""
    var token: String = ""
    var error: String = ""
    
    override init(){
        super.init()
    }
    
    convenience required init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map){
        message <- map["message"]
        token <- map["token"]
        error <- map["error"]
    }
}
