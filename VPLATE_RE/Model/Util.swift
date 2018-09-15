//
//  Util.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 12..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

struct Util {
    static func format(_ duration: TimeInterval) -> String {
        let seconds: Int = lround(duration)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
}
