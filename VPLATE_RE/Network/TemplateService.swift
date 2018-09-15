
//
//  TemplateService.swift
//  VPLATE_RE
//
//  Created by mokjinook on 2018. 7. 31..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON
import ObjectMapper

class TemplateService: APIService {
    //MARK: '나의 템플릿' 정보를 불러온다
    static func getMyTemplateData(url: String, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: url)
        
        Alamofire.request(url, headers: Token.getTokenHeader()).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
    
    //MARK: SubTemplate생성 후, Origin Template에 따른 Scene정보를 불러와서 데이터를 입력할 구조를 만든다.
    static func getScenesInfo(template: Template, success: ((Template) -> Void)!, failure: ((String) -> Void)!) {
        let url = self.getURL(path: "templates/scene/\(template.id)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { (response) in
            switch response.result {
            case .success(let data):
                guard let scenes = Mapper<Scene>().mapArray(JSONObject: JSON(data)["scenes"].object) else {
                    failure("Server Response Error")
                    return
                }
                template.scenes = scenes
                success(template)
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK: 편집, 수정을 위한 SubTemplate에 대한 Scene정보를 불러온다.
    static func getSubTemplateScenesInfo(subId: String, success: ((Template) -> Void)!, failure: ((String) -> Void)!) {
        let url = self.getURL(path: "subtemplates/\(subId)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { (response) in
            switch response.result {
            case .success(let data):
                guard let scenes = Mapper<Scene>().mapArray(JSONObject: JSON(data)["subClips"].object) else {
                    failure("Server Response Error")
                    return
                }
                
                let template: Template = Template()
                template.scenes = scenes
                success(template)
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK: 처음 쿠폰으로 템플릿을 구매 후 그에 대한 SubTemplate생성
    //성공 시 subId를 받아서 getScenesInfo()에 이용하여 scene구조 생성에 이용
    static func createTemplate(template: Template, completion: @escaping (String)->Void) {
        let url = self.getURL(path: "subtemplates")
        
        let body: [String : String] = [
            "templateId" : template.id]
        
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "subTemplate stored" {
                        let subId = JSON(value)["subtemplate"]["_id"].string
                        
                        completion(subId!)
                    }
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK: Done, Back Button시 SubTemplate의 내용 수정
    static func editTemplate(subId: String, status: Int, percent: Int, template: Template, progress: ((Double) -> Void)!, success: (() -> Void)!, failure: ((String) -> Void)!) {
        
        //image, video의 AWS S3 저장을 위한 메소드
        mediaFileUpload(
            template: template,
            progress: {(progressRespons: Double) in
                progress(progressRespons)
        },
            success: {(urls: [String]) in
                
                //업로드한 파일 경로 설정
                var index = 0
                for scene in template.scenes {
                    for clip in scene.clips {
                        if(clip.type == .image) {
                            guard URL(string: clip.imageUrl) != nil else {break}
                            clip.imageUrl = urls[index]
                            index += 1
                        } else if(clip.type == .video) {
                            print(urls.count)
                            
                            guard URL(string: clip.videoUrl) != nil else {break}
                            clip.videoUrl = urls[index]
                            index += 1
                        }
                    }
                }
                let url = self.getURL(path: "subtemplates/\(subId)")
                
                let sceneParams = template.scenes.toJSON()
                let parameter: [String: Any] = [
                    "subClips" : sceneParams,
                    "progress" : percent,
                    "status"   : status
                ]
                
                Alamofire.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { (response) in
                    switch response.result {
                    case .success(let data):
                        if((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! < 400) {
                            success()
                        } else {
                            if let message = JSON(data)["message"].string {
                                failure(message)
                            }
                            failure("")
                        }
                        break
                    case .failure(let error):
                        failure(error.localizedDescription)
                        break
                    }
                }
        },
            failure: {(errString: String) in
                failure(errString)
        })
    }
    
    //MARK: editTempalte() 수정 시, image, video 먼저 업로드 후 AWS url 받아옴
    private static func mediaFileUpload(template: Template, progress: ((Double) -> Void)!, success: (([String]) -> Void)!, failure: ((String) -> Void)!) {
        let url = self.getURL(path: "templates/upload")
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                for scene in template.scenes {
                    for clip in scene.clips {
                        if(clip.type == .image) {
                            do {
                                guard let url = URL(string: clip.imageUrl) else {break}
                                let data = try Data(contentsOf: url)
                                multipartFormData.append(data, withName: "files", fileName: "USER_\(template.title)_S\(scene.index)_C\(clip.index).png", mimeType: "image/png")
                                
                                
                            } catch {}
                        } else if(clip.type == .video) {
                            do {
                                guard let url = URL(string: clip.videoUrl) else {break}
                                let data = try Data(contentsOf: url)
                                multipartFormData.append(data, withName: "files", fileName: "USER_\(template.title)_S\(scene.index)_C\(clip.index).mp4", mimeType: "video/mp4")
                            } catch {}
                        }
                    }
                }
        },
            usingThreshold: UInt64.init(),
            to: url,
            method: .post,
            headers: nil,
            encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progressResponse in
                        progress(progressResponse.fractionCompleted)
                    }
                    upload.responseData() { (response) in
                        switch response.result {
                        case .success(let data) :
                            let urls: [String] = JSON(data)["urls"].arrayValue.map {$0.stringValue}
                            success(urls)
                            break
                        case .failure(let error) :
                            
                            failure(error.localizedDescription)
                            break
                        }
                        
                    }
                    break
                case .failure(let error):
                    failure(error.localizedDescription)
                    break
                }
        })
    }
    
    //MARK: Template Confirm Networking
    static func comfirmTemplate(subId: String, completion: @escaping ()->Void) {
        let url = self.getURL(path: "subtemplates/confirm/\(subId)")
        
        let body: [String : String] = [
            "status" : "3" ]
        
        Alamofire.request(url, method: .patch, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "subTemplate status change in 3" {
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
    
    //MARK: Template Re Edit Networking
    static func reEditTemplate(subId: String, completion: @escaping ()->Void) {
        let url = self.getURL(path: "subtemplates/reedit/\(subId)")
        
        //        let body: [String : String] = [
        //            "status" : "3" ]
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    
                    let message = JSON(value)["message"].string
                    
                    //if message == "subTemplate status change in 3" {
                    completion()
                    //}
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: Coupon Networking
    static func couponValidation(code: String, completion: @escaping (String)->Void) {
        let url = self.getURL(path: "coupons/check")
        
        let body: [String : String] = [
            "code" : code ]
        
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    
                    let message = JSON(value)["message"].string
                    if message == "match" {
                        completion("match")
                    } else if message == "duplication" {
                        completion("duplication")
                    } else {
                        completion("not match")
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    
    
    //MARK: Template Add Heart Networking
    static func addHeartTemplate(templateId: String, completion: @escaping ()->Void) {
        let url = self.getURL(path: "likes/")
        
        let body: [String : String] = [
            "templateId" : templateId ]
        
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "like stored" {
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
    
    //MARK: Heart Validation Networking
    static func heartValidation(templateId: String, completion: @escaping (String)->Void) {
        let url = self.getURL(path: "templates/detail/\(templateId)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "like" {
                        completion("like")
                    } else {
                        completion("unlike")
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: Template Delete Heart Networking
    static func deleteHeartTemplate(templateId: String, completion: @escaping ()->Void) {
        let url = self.getURL(path: "likes")
        
        let body: [String : String] = [
            "templateId" : templateId ]
        
        Alamofire.request(url, method: .delete, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "like deleted" {
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
    
    //MARK: '찜한 템플릿' 정보를 불러온다
    static func getFavoriteTemplateData(url: String, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: url)
        
        Alamofire.request(url, headers: Token.getTokenHeader()).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
    
    //MARK: 편집 팁 리스트를 불러온다
    static func editTipListInit(completion: @escaping ([EditTipListData])->Void) {
        let URL = self.getURL(path: "guides")
        Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData() { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let decoder = JSONDecoder()
                    
                    do {
                        let editTipListData = try decoder.decode(EditTipList.self, from: value)
                        
                        completion(editTipListData.guides)
                    } catch {
                        
                    }
                    //////////////////
                }
                
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: 편집 팁들을 불러온다
    static func editTipInit(tipId: String, completion: @escaping (EditTip, [EditTipData])->Void) {
        let URL = self.getURL(path: "guides/\(tipId)")
        Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData() { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let decoder = JSONDecoder()
                    
                    do {
                        let editTipData = try decoder.decode(EditTip.self, from: value)
                        completion(editTipData, editTipData.mediaArray)
                    } catch {
                    }
                    //////////////////
                }
                
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: 템플릿 상세정보 불러오기
    static func getTemplateDetailData(templateId: String, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: "templates/info/\(templateId)")
    
        Alamofire.request(url, headers: Token.getTokenHeader()).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
    
    //MARK: Account Setting 불러오기
    static func accountSettingInit(completion: @escaping (AccountSetting)->Void) {
        let URL = self.getURL(path: "user/account")
        Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData() { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let decoder = JSONDecoder()
                    
                    do {
                        let accountData = try decoder.decode(AccountSetting.self, from: value)
                        if accountData.message == "account information" {
                            completion(accountData)
                        }
                    } catch {
                        
                    }
                    //////////////////
                }
                
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    //MARK: Account Setting Update
    static func accountSettingUpdate(bizUser: Int, bizContent: String, bizAddress: String, bizForm: String, completion: @escaping ()->Void) {
        let url = self.getURL(path: "user/account")
        
        let body: [String : Any] = [
            "bizUser" : bizUser,
            "bizContent" : bizContent,
            "bizAddress" : bizAddress,
            "bizForm" : bizForm]
        
        Alamofire.request(url, method: .patch, parameters: body, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let message = JSON(value)["message"].string
                    
                    if message == "information updates" {
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
}
