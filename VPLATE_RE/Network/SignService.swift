//
//  SignService.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 1. 26..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct SignService: APIService {
    static func getSignData(url: String, parameter: [String : Any]?, completion: @escaping (Result<Any>)->()) {
        let URL = self.getSignURL(path: url)
        Alamofire.request(URL, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
    
    static func signUp(user: [String:String], completion: @escaping (NewResult<Void>)->Void) {
        let URL = getSignURL(path: "user/signup")
        
        let params: [String:String] = user
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseData { (res) in
            switch res.result {
            case .success(let data):
                
                if let message = JSON(data)["message"].string {
                    if message == "User created" {
                        completion(.success(()))
                    } else {
                        completion(.error(message))
                    }
                }
                
            case .failure(let err):
                print(err.localizedDescription)
                completion(.failure())
            }
        }
    }
    
    static func signIn(email: String, pwd: String, completion: @escaping (NewResult<String>)->Void) {
        let URL = getSignURL(path: "user/login")
        
        let params: [String:String] = [
            "userEmail" : email,
            "password" : pwd
        ]
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseObject{(response: DataResponse<User>) in
            
            guard let userResponse = response.result.value else {
                completion(.failure())
                return
            }
            guard let res = response.response else {
                completion(.failure())
                return
            }
            switch res.statusCode {
            case 200..<400 :
                if(userResponse.token != "") {
                    completion(.success(userResponse.token))
                } else {
                    completion(.error(userResponse.message))
                }
            default :
                completion(.error("이메일 혹은 비밀번호가 올바르지 않습니다."))
            }
        }
    }
    
    static func emailCheck(email: String, completion: @escaping (NewResult<()>)->Void) {
        let URL = getSignURL(path: "user/emailcheck")
        
        let params: [String:String] = [
            "userEmail" : email
        ]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseData { (res) in
            guard let response = res.response else {
                completion(.error("서버 응답 오류"))
                return
            }
            switch response.statusCode {
            case 200..<400 :
                completion(.success(()))
                break
            default :
                switch res.result {
                case .success(let data):
                    if let message = JSON(data)["message"].string {
                        completion(.error(message))
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                    completion(.failure())
                }
                break
            }
        }
    }
    
    static func snsSignUp(user: [String:String], completion: @escaping (NewResult<Void>)->Void) {
        let URL = getSignURL(path: "user/snssignup")
        
        let params: [String:String] = user
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseData { (res) in
            switch res.result {
            case .success(let data):
                
                if let message = JSON(data)["message"].string {
                    if message == "sns user created" {
                        completion(.success(()))
                    } else {
                        completion(.error(message))
                    }
                }
                
            case .failure(let err):
                print(err.localizedDescription)
                completion(.failure())
            }
        }
    }
    
    static func snsSignIn(email: String, uid: String, completion: @escaping (NewResult<String>)->Void) {
        let URL = getSignURL(path: "user/snslogin")
        
        let params: [String:String] = [
            "userEmail" : email,
            "socialKey" : uid
        ]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseObject{(response: DataResponse<User>) in
            
            guard let userResponse = response.result.value else {
                completion(.error("Error Json Decode"))
                return
            }
            guard let res = response.response else {
                completion(.error("Error server response"))
                return
            }
            switch res.statusCode {
            case 200..<400 :
                if(userResponse.token != "") {
                    completion(.success(userResponse.token))
                } else {
                    completion(.error(userResponse.message))
                }
            default :
                completion(.error(userResponse.message))
            }
        }
    }
    
    static func snsCheck(uid: String, completion: @escaping (NewResult<String>)->Void) {
        let URL = getSignURL(path: "user/snscheck")
        
        let params: [String:String] = [
            "socialKey" : uid
        ]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseData { (res) in
            switch res.result {
            case .success(let data):
                
                if let message = JSON(data)["message"].string {
//                    if message == "sns available" {
//                        completion(.success(()))
//                    } else {
//                        completion(.error(message))
//                    }
                    completion(.success(message))
                }
                
            case .failure(let err):
                print(err.localizedDescription)
                completion(.failure())
            }
        }
    }
    
    
    static func addDeviceToken(deviceToken: String, completion: @escaping ()->Void) {
        let url = self.getURL(path: "pushes")
        
        print(deviceToken)
        let body: [String : String] = [
            "deviceToken" : deviceToken ]
        
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "push stored" {
                        completion()
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: Change Password
    static func changePassword(userName: String, userEmail: String, password: String, completion: @escaping (String)->Void) {
        let url = self.getURL(path: "user/findpw")
        
        let body: [String : String] = [
            "userName"  : userName,
            "userEmail" : userEmail,
            "password"  : password]

        
        Alamofire.request(url, method: .patch, parameters: body, encoding: JSONEncoding.default, headers: nil).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    //if message == "password update" {
                        completion(message!)
                    //}
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: Find Email
    static func findEmail(userName: String, userPhone: String, completion: @escaping (String, String)->Void) {
        let url = self.getURL(path: "user/findemail")
        
        let body: [String : String] = [
            "userName"  : userName,
            "userPhoneNumber" : userPhone]
  
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    let findEmail = JSON(value)["userEmail"].string
                    
                    if message == "userEmail" {
                        completion(message!, findEmail!)
                    } else {
                        completion(message!, "no email")
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
}

//**********    Example Code    **********
//SignService.getSignData(url: "addedURL", parameter: ...) { (result) in
//    switch result {
//    case .Success(let response):
//        guard let data = response as? Data else {return}
//        let dataJSON = JSON(data)
//        print(dataJSON)
//    case .Failure(let failureCode):
//        print("Sign In Failure : \(failureCode)")
//          switch failureCode {
//              case ... :
//          }
//    }
//}

