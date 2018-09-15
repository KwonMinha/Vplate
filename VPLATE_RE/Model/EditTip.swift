//
//  EditTip.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

struct EditTip: Codable {
    let mediaArray: [EditTipData]
    let _id: String?
    let title: String?
    let subtitle: String?
    let thumbnail: String?
    let videoUrl: String?
}
