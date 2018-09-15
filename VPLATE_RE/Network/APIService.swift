//
//  APIService.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 1. 26..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire

enum Result<T> {
    case Success(T)
    case Failure(Int)
    case FailDescription(String)
}

enum NewResult<T> {
    case success(T)
    case error(String)
    case failure()
}

class Token {
    static var token: String = ""
    
    static func setToken(token: String) {
        self.token = token
    }
    
    static func getTokenHeader() -> [String:String]{
        return ["Authorization" : "Bearer " + self.token]
    }
}
protocol APIService {
    
}

extension APIService  {
    static func getURL(path: String) -> String {
        return "http://13.125.183.128:8000/" + path
    }
    static func getSignURL(path: String) -> String {
        return "http://13.125.183.128:8000/" + path
    }
    static func getResult_StatusCode(response: DataResponse<Data>) -> Result<Any>? {
        switch response.result {
        case .success :
            guard let statusCode = response.response?.statusCode as Int? else {return nil}
            guard let responseData = response.data else {return nil}
            switch statusCode {
            case 200..<400 :
                return Result.Success(responseData)
            default :
                return Result.Failure(statusCode)
            }
        case .failure(let err) :
            return Result.FailDescription(err.localizedDescription)
        }
    }
}
