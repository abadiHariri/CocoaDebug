//
//  CocoaDebugTool.swift
//  Example_Swift
//
//  Created by man 5/8/19.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

@objc class CocoaDebugTool: NSObject {

    // MARK: - logWithString

    @objc static func log(string: String) {
        log(string: string, color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    }

    @objc static func log(string: String, color: UIColor) {
        finalLog(string: string, type: .none, color: color)
    }

    // MARK: - logWithJsonData

    @objc static func log(jsonData data: Data) -> String {
        return log(jsonData: data, color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    }

    @objc static func log(jsonData data: Data, color: UIColor) -> String {
        let string = getPrettyJsonString(data: data) ?? "NULL"
        return finalLog(string: string, type: .json, color: color)
    }

    // MARK: - tool

    private static func getPrettyJsonString(jsonString: String) -> String? {
        return getPrettyJsonString(data: jsonString.data(using: .utf8))
    }

    private static func getPrettyJsonString(data: Data?) -> String? {
        guard let data = data else { return nil }

        // 1. pretty json
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }

        guard let prettyData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return nil }

        if let prettyJsonString = String(data: prettyData, encoding: .utf8) {
            return prettyJsonString
        }

        // 2. utf-8 string
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    private static func finalLog(string: String, type: CocoaDebugToolType, color: UIColor) -> String {
        _OCLogHelper.shared.handleLog(file: "XXX", function: "XXX", line: 1, message: string, color: color, type: type)
        return string
    }
}
