//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

@objc class _OCLoggerFormat: NSObject {

    @objc static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
}
