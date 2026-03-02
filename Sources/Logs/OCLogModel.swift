//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

@objc enum CocoaDebugLogType: Int {
    case normal = 0
    case rn
    case web
}

@objc enum CocoaDebugToolType: Int {
    case none = 0
    case rn
    case json
    case protobuf
}

@objc class _OCLogModel: NSObject {

    @objc var contentData: Data?
    @objc var Id: String?
    @objc var fileInfo: String?
    @objc var content: String?
    @objc var date: Date?
    @objc var color: UIColor?
    @objc var isTag: Bool = false
    @objc var isSelected: Bool = false
    @objc var str: String?
    @objc var attr: NSAttributedString?
    @objc var logType: CocoaDebugLogType = .normal

    @objc init(content: String?, color: UIColor?, fileInfo: String?, isTag: Bool, type: CocoaDebugToolType) {
        super.init()

        var fileInfo = fileInfo

        if fileInfo == "XXX|XXX|1" {
            if type == .protobuf {
                fileInfo = "Protobuf\n"
            } else {
                fileInfo = "\n"
            }
        }

        // NSLog vs color
        if type == .none {
            if fileInfo == " \n" { // nslog
                fileInfo = "NSLog\n"
            } else if fileInfo == "\n" { // color
                fileInfo = "\n"
            }
        }

        // RN (java script)
        if fileInfo == "[RCTLogError]\n" {
            fileInfo = "[error]\n"
        } else if fileInfo == "[RCTLogInfo]\n" {
            fileInfo = "[log]\n"
        }

        self.Id = UUID().uuidString
        self.fileInfo = fileInfo
        self.date = Date()
        self.color = color
        self.isTag = isTag

        if let content = content {
            self.contentData = content.data(using: .utf8)
        }

        // Avoid too many logs causing lag (use NSString.length to match ObjC UTF-16 counting)
        var truncatedContent = content ?? ""
        if (truncatedContent as NSString).length > 1000 {
            truncatedContent = (truncatedContent as NSString).substring(to: 1000)
        }
        self.content = truncatedContent

        /////////////////////////////////////////////////////////////////////////

        var stringContent = ""

        stringContent += "[\(_OCLoggerFormat.formatDate(self.date!))]"
        // Use NSString.length for NSRange compatibility (UTF-16 code units, not grapheme clusters)
        let lengthDate = (stringContent as NSString).length
        let startIndex = (stringContent as NSString).length

        if let fi = self.fileInfo {
            stringContent += "\(fi)\(self.content ?? "")"
        } else {
            stringContent += "\(self.content ?? "")"
        }

        let attstr = NSMutableAttributedString(string: stringContent)
        attstr.addAttribute(.foregroundColor, value: self.color ?? UIColor.white, range: NSRange(location: 0, length: (stringContent as NSString).length))

        let range = NSRange(location: 0, length: lengthDate)
        attstr.addAttribute(.foregroundColor, value: _NetworkHelper.shared.mainColor ?? UIColor.green, range: range)
        attstr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: range)

        let fileInfoLength = (self.fileInfo as NSString?)?.length ?? 0
        let range2 = NSRange(location: startIndex, length: fileInfoLength)

        if self.fileInfo == "[error]\n" {
            attstr.addAttribute(.foregroundColor, value: UIColor.systemRed, range: range2)
        } else {
            attstr.addAttribute(.foregroundColor, value: UIColor.systemGray, range: range2)
        }

        attstr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: range2)

        // Line break
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping

        let range3 = NSRange(location: 0, length: attstr.length)
        attstr.addAttribute(.paragraphStyle, value: paragraphStyle, range: range3)

        self.str = stringContent
        self.attr = attstr.copy() as? NSAttributedString
    }

    override init() {
        super.init()
    }
}
