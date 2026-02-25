//
//  _HTTPModel+cURL.swift
//  CocoaDebug
//
//  Created by Nehcgnos on 2023/6/11.
//  Copyright © 2023 man. All rights reserved.
//

import Foundation

extension _HttpModel {

    /// Build a complete, valid cURL command from this request model.
    /// Output is compatible with terminal paste AND Postman "Import > Raw Text".
    /// Accepts optional pre-cached data to avoid redundant disk reads.
    func cURLDescription(cachedRequestData: Data? = nil) -> String {
        var parts = [String]()

        // 1. Command + method (always explicit for clarity)
        let httpMethod = (method ?? "GET").uppercased()
        parts.append("curl -X \(httpMethod)")

        // 2. URL
        let urlString = url?.absoluteString ?? ""
        parts.append(shellQuote(urlString))

        // 3. Headers (sorted for consistent output)
        if let headers = requestHeaderFields as? [String: Any] {
            let sortedKeys = headers.keys.sorted()
            for key in sortedKeys {
                let value = "\(headers[key] ?? "")"
                parts.append("-H \(shellQuote("\(key): \(value)"))")
            }
        }

        // 4. Body
        let bodyData: Data? = cachedRequestData ?? self.requestData
        if let data = bodyData, !data.isEmpty {
            if let bodyString = String(data: data, encoding: .utf8), !bodyString.isEmpty {
                // Text body (JSON, form-encoded, multipart, plain text)
                parts.append("--data-raw \(shellQuote(bodyString))")
            } else {
                // Binary data — encode as base64 string (for reference/documentation)
                let b64 = data.base64EncodedString()
                parts.append("--data-binary \(shellQuote(b64))")
            }
        }

        return parts.joined(separator: " \\\n  ")
    }

    /// Shell-quote a string using single quotes.
    /// Single quotes in the string are replaced with '\'' (end quote, escaped quote, start quote).
    private func shellQuote(_ string: String) -> String {
        let escaped = string.replacingOccurrences(of: "'", with: "'\\''")
        return "'\(escaped)'"
    }
}
