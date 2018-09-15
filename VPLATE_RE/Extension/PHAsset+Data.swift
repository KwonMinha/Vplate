//
//  PHAsset.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 20..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Photos
extension PHAsset {
    func fullResolutionImageData() -> Data? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        var image: Data? = nil
        _ = PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData {
                image = data
            }
        }
        return image
    }
    
    func vidoeData() -> Data? {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = false
        options.version = .current
        var data: Data? = nil
        
        _ = PHCachingImageManager().requestAVAsset(forVideo: self, options: options, resultHandler: { (asset, auidoMix, info) in
            if let asset = asset as? AVURLAsset {
                do {
                    data = try Data(contentsOf: asset.url)
                }
                catch (let err) {
                    print(err.localizedDescription)
                }
            }
        })
        return data
    }
}

