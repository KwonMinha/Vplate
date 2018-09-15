//
//  PaymentService.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 7. 6..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire

struct PaymentService: APIService {
    static func addTemplate(url: String, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: url)
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData(completionHandler: {
            (response: DataResponse<Data>) in
            guard let resultData = getResult_StatusCode(response: response) else {
                return
            }
            completion(resultData)
        })
    }
}
