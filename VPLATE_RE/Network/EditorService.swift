//
//  EditorService.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 20..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire
import Photos
import SwiftyJSON

struct EditorService: APIService {
    static func uploadTextClips(url: String, parameter: Parameters, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: url)
        Alamofire.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData { (response) in
            guard let resultData = getResult_StatusCode(response: response) else {return}
            completion(resultData)
        }
    }
    
    static func uploadMediaClips(fullIndicator: FullIndicatorView, url: String, template: Template, completion: @escaping (Result<Any>)->()) {
        
        let url = self.getURL(path: url)
        fullIndicator.show(true)
        
        Alamofire.upload(multipartFormData: {
            (multipartFormData) in
            for scene in template.scenes {
                for clip in scene.clips {
                    if(clip.type == .image || clip.type == .video) {
                        self.addDatas(
                            type: clip.type,
                            multipartFormData: multipartFormData,
                            videoURL: clip.videoUrl,
                            imageURL: clip.imageUrl,
                            key: "files",
                            fileName: "USER_\(template.title)_S\(scene.index)_C\(clip.index)")
                    }
                }
            }
        },
                         usingThreshold: UInt64.init(),
                         to: url,
                         method: .post,
                         headers: Token.getTokenHeader(), encodingCompletion: {
                            (encodingResult) in
                            switch encodingResult {
                            case .success(let upload, _, _) :
                                upload.uploadProgress { progress in
                                    let value = Int(progress.fractionCompleted * 100)
                                    fullIndicator.set(value: value)
                                }
                                upload.responseData(){
                                    (response) in
                                    guard let resultData = getResult_StatusCode(response: response) else {return}
                                    completion(resultData)
                                    fullIndicator.show(false)
                                }
                            case .failure(let error) :
                                completion(Result.FailDescription(error.localizedDescription))
                                fullIndicator.show(false)
                            }
        })
    }
    static func addDatas(type: ClipType, multipartFormData: MultipartFormData, videoURL: String?, imageURL: String?, key: String,  fileName: String){
//        DispatchQueue.main.async {
            switch type {
            case .image :
                if let imageURL = imageURL, let url = URL(string: imageURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        multipartFormData.append(data, withName: key, fileName: fileName+".png", mimeType: "image/png")
                    }
                    catch (let err) {
                        debugPrint(err.localizedDescription)
                    }
                }
            case .video :
                if let videoURL = videoURL, let url = URL(string: videoURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        multipartFormData.append(data, withName: key, fileName: fileName+".mp4", mimeType: "video/mp4")
                    }
                    catch (let err) {
                        print(err.localizedDescription)
                    }
                }
            default: break
            }
//        }
        
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
