//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore

@objc class _ObjcLog: NSObject {

    @objc static func log(file: String, function: String, line: Int, color: UIColor, message: Any) {
        let messageStr: String
        if let str = message as? String {
            messageStr = str
        } else if let jsValue = message as? JSValue {
            let strValue = jsValue.toString() ?? ""
            if strValue == "[object Object]" {
                let dict = jsValue.toDictionary() ?? [:]
                messageStr = "\(dict)"
            } else {
                messageStr = "\(jsValue)"
            }
        } else {
            messageStr = "\(message)"
        }
        _OCLogHelper.shared.handleLog(file: file, function: function, line: line, message: messageStr, color: color, type: .none)
    }
}
