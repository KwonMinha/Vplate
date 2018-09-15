//
//  HomeService.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 7. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire

struct HomeService: APIService {
    static func getTemplateData(url: String, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: url)
        
        Alamofire.request(url, headers: Token.getTokenHeader()).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
    
    static func getScenesData(url: String, templateID: String, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: "\(url)\(templateID)")
        Alamofire.request(url, headers: Token.getTokenHeader()).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
}
