//
//  NSLogHook.swift
//  CocoaDebug
//
//  Created by man 7/26/19.
//  Copyright (c) 2020 man. All rights reserved.
//
//  Replaces _NSLogHook.m.
//  Since NSLog is a C variadic function, it cannot be hooked directly from
//  pure Swift via fishhook (Swift cannot create @convention(c) variadic
//  functions). Instead we redirect STDERR -- where NSLog writes its output --
//  through a pipe so we can capture every line while still forwarding it to
//  the original file descriptor.
//

import Foundation
import UIKit

@objc class _NSLogHook: NSObject {

    private static var hooked = false
    private static var savedStderrFD: Int32 = -1

    /// Call this once (e.g. from `CocoaDebug.enable()`) to start capturing
    /// NSLog output. The method is idempotent and respects the
    /// `enableLogMonitoring_CocoaDebug` user-default.
    @objc static func enableIfNeeded() {
        guard !hooked else { return }
        guard UserDefaults.standard.bool(forKey: "enableLogMonitoring_CocoaDebug") else { return }
        hooked = true

        // Ignore SIGPIPE — writing to a pipe whose read end closed must not
        // kill the process. This is standard practice for any app using pipes.
        signal(SIGPIPE, SIG_IGN)

        redirectStderr()
    }

    // MARK: - Private

    private static func redirectStderr() {
        let pipe = Pipe()
        savedStderrFD = dup(STDERR_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }

            // Forward to original stderr so Xcode console / device log still works
            if savedStderrFD >= 0 {
                data.withUnsafeBytes { bytes in
                    if let base = bytes.baseAddress {
                        _ = write(savedStderrFD, base, data.count)
                    }
                }
            }

            if let str = String(data: data, encoding: .utf8) {
                let lines = str.components(separatedBy: "\n")
                for line in lines where !line.isEmpty {
                    DispatchQueue.main.async {
                        _OCLogHelper.shared.handleLog(
                            file: "",
                            function: "",
                            line: 999999999,
                            message: line,
                            color: .white,
                            type: .none
                        )
                    }
                }
            }
        }
    }
}
