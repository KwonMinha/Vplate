//
//  Template.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 13..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Photos
import ObjectMapper
import AlamofireObjectMapper

enum ClipType: Int {
    case video, image, text
    
    static func getType(string: String) -> ClipType? {
        switch string {
        case "Video".localized : return .video
        case "Image".localized : return .image
        case "Text".localized : return .text
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .video: return "Video".localized
        case .image: return "Image".localized
        case .text: return "Text".localized
        }
    }
}

class Template: NSObject, Mappable {
    var id: String = ""
    var title: String = ""
    var hashString: String = ""
    var thumbnail: String? = nil
    var price: Double = 0.0
    var url: String? = nil
    var duration: Double = 0.0
    var content: String = ""
    var ratio: Ratio = .all
    var categorize: Categorize = .all
    var channel: Channel = .all
    var videoNum: Int = 0
    var imageNum: Int = 0
    var textNum: Int = 0
    var isLiked = false
    
    var state: TemplateState = .progress
    
    var scenes = [Scene]()

    override init(){
        super.init()
    }
    
    convenience required init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        id          <- map["_id"]
        title       <- map["title"]
        hashString  <- map["hashString"]
        thumbnail   <- map["thumbnail"]
        url         <- map["url"]
        price       <- map["price"]
        duration    <- map["duration"]
        content     <- map["content"]
        ratio       <- (map["ratio"], EnumTransform<Ratio>())
        categorize  <- (map["categorize"], EnumTransform<Categorize>())
        channel    <- (map["channel"], EnumTransform<Channel>())
        videoNum    <- map["videoNum"]
        imageNum    <- map["imageNum"]
        textNum     <- map["textNum"]
        isLiked     <- map["isLiked"]
    }
    
    func isFilled() -> Bool {
        var isFilled = true
        for scene in scenes {
            if(scene.isFilled() == false) {
                isFilled = false
                break
            }
        }
        return isFilled
    }
}

class Scene: NSObject, Mappable {
    var types = [ClipType]()
    var clips = [Clip]()
    //var id: String = ""
    var index: Int = 0
    var thumbnail = [String]()
    
    var durationCount: Int = 0
    
    override init(){
        super.init()
    }
    
    convenience required init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        types   <- (map["types"],EnumTransform<ClipType>())
        clips   <- map["clips"]
        //id      <- map["_id"]
        index   <- map["index"]
        thumbnail <- map["thumbnail"]
    }
    
    func isFilled() -> Bool {
        var isFilled = true
        for clip in clips {
            if(clip.isFilled() == false) {
                isFilled = false
            }
        }
        return isFilled
    }
    
//    func duration() -> Int {
//        //var duration = 0
//        for clip in clips {
//            if(clip.isFilled() == false) {
//                
//            } else {
//                //duration += 1
//                durationCount = durationCount + 1
//            }
//        }
//        return durationCount
//    }

}

class Clip: NSObject, Mappable {
    var index: Int = 0
    var type: ClipType = .text
    var text: String = ""
    var imageUrl: String = ""
    var videoUrl: String = ""
    var width: Int = 0
    var height: Int = 0
    var value: Int = 0
    var time: Double = 0
    
    var count: Int = 0
    
    override init(){
        super.init()
    }
    
    convenience required init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        index       <- map["index"]
        type        <- (map["type"],EnumTransform<ClipType>())
        text        <- map["text"]
        imageUrl    <- map["imageURL"]
        videoUrl    <- map["videoURL"]
        width       <- map["width"]
        height      <- map["height"]
        value       <- map["value"]
        time        <- map["time"]
    }
    
    func isFilled() -> Bool {
        switch type {
        case .text:
            if(text == "") { return false }
            else {
                return true
            }
        case .image:
            if(imageUrl == "") { return false }
            else {
                return true
                
            }
        case .video:
            if(videoUrl == "") { return false }
            else {
                return true
            }
        }
    }
    
    func filledCount() -> Int {
        switch type {
        case .text:
            if(text == "") { }
            else {
                count += 1
            }
        case .image:
            if(imageUrl == "") {  }
            else {
                count += 1
                
            }
        case .video:
            if(videoUrl == "") {  }
            else {
                count += 1
            }
        }
        return count
    }
    
    func getVideoThumbnail() -> UIImage? {
        if(type != .video) { return nil }
        guard let url = URL(string: videoUrl) else {return nil }
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0, preferredTimescale: 1)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch(let error) {
            print(error.localizedDescription)
        }
        return nil
    }
}
