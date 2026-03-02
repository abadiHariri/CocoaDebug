//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

@objc class _OCLogHelper: NSObject {

    @objc static let shared = _OCLogHelper()

    private override init() {
        super.init()
    }

    private func parseFileInfo(file: String, function: String, line: Int) -> String {
        if file == "XXX" && function == "XXX" && line == 1 {
            return "XXX|XXX|1"
        }

        if line == 0 { // web
            let fileName = file.components(separatedBy: "/").last ?? ""
            return "\(fileName) \(function)\n"
        }

        if line == 999999999 { // nslog
            let fileName = file.components(separatedBy: "/").last ?? ""
            return "\(fileName) \(function)\n"
        }

        if line == -1 { // RN
            return file
        }

        let fileName = file.components(separatedBy: "/").last ?? ""
        return "\(fileName)[\(line)]\(function)\n"
    }

    @objc func handleLog(file: String, function: String, line: Int, message: String, color: UIColor, type: CocoaDebugToolType) {
        // 1.
        let fileInfo = parseFileInfo(file: file, function: function, line: line)

        // 2.
        let newLog = _OCLogModel(content: message, color: color, fileInfo: fileInfo, isTag: false, type: type)

        if type == .rn {
            newLog.logType = .rn
        }

        if file == "[WKWebView]" {
            newLog.logType = .web
        }

        _OCLogStoreManager.shared.addLog(newLog)

        // 3.
        NotificationCenter.default.post(name: NSNotification.Name("refreshLogs_CocoaDebug"), object: nil, userInfo: nil)
    }
}
