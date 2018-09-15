//
//  SettingService.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON
import ObjectMapper

class SettingService: APIService {
    // MARK: 공지사항 불러오기
    static func noticeInit(completion: @escaping ([NoticeData])->Void) {
        let URL = self.getURL(path: "user/notice")
        Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Token.getTokenHeader()).responseData() { res in
            switch res.result {
            case .success:
                if let value = res.result.value {
                    let decoder = JSONDecoder()
                    
                    do {
                        let notice = try decoder.decode(Notice.self, from: value)
                        
                        if notice.count! > 0 {
                            completion(notice.notice!)
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
}
