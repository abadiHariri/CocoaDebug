//
//  _HTTPModel+cURL.swift
//  CocoaDebug
//
//  Created by Nehcgnos on 2023/6/11.
//  Copyright © 2023 man. All rights reserved.
//

import Foundation

extension _HttpModel {

    func cURLDescription() -> String {
        var components = ["curl"]

        // URL — single-quoted to prevent shell expansion
        components.append("'\(shellEscape(url?.absoluteString ?? ""))'")

        // Method
        if let method, method != "GET" {
            components.append("-X \(method)")
        }

        // Headers — guard against nil (property is implicitly unwrapped optional)
        if let headers = requestHeaderFields as? [String: Any] {
            for (field, value) in headers {
                components.append("-H '\(shellEscape("\(field): \(value)"))'")
            }
        }

        // Body
        if let requestData, !requestData.isEmpty {
            if let bodyString = String(data: requestData, encoding: .utf8), !bodyString.isEmpty {
                components.append("-d '\(shellEscape(bodyString))'")
            } else {
                // Binary data — encode as base64 with inline decode
                let base64 = requestData.base64EncodedString(options: .lineLength76Characters)
                components.append("--data-binary \"$(echo '\(shellEscape(base64))' | base64 -D)\"")
            }
        }

        return components.joined(separator: " \\\n")
    }

    /// Escapes a string for use inside single quotes.
    /// The only character that needs escaping in single-quoted strings is
    /// the single quote itself: replace ' with '\''
    private func shellEscape(_ string: String) -> String {
        return string.replacingOccurrences(of: "'", with: "'\\''")
    }
}
