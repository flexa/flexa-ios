//
//  FlexaLogger.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 19/5/21.
//  Copyright © 2021 Flexa. All rights reserved.
//

import Foundation
import os.log

class FlexaLogger {
    enum MessageType: String, CaseIterable {
        case `default`, info, debug, error

        var logType: OSLogType {
            switch self {
            case .info:
              return .info
            case .debug:
              return .debug
            case .error:
              return .error
            default:
              return .default
            }
        }
    }

    static private let oslog = OSLog(
      subsystem: Bundle.main.bundleIdentifier ?? "Flexa",
      category: "default"
    )

    static func log(
        _ message: Any,
        type: MessageType = .default,
        function: String = #function,
        file: String = #file,
        line: Int = #line) {

        os_log(
            "[%{public}@/%{public}@:%{public}@] %{public}@",
            log: oslog,
            type: type.logType,
            (file as NSString).lastPathComponent,
            function,
            "\(line)",
            String(describing: message)
        )
    }

    static func info(_ message: Any,
                     function: String = #function,
                     file: String = #file,
                     line: Int = #line) {

        log(message, type: .info, function: function, file: file, line: line)
    }

    static func debug(_ message: Any,
                      function: String = #function,
                      file: String = #file,
                      line: Int = #line) {
        log(message, type: .debug, function: function, file: file, line: line)
    }

    static func error(_ error: Any,
                      function: String = #function,
                      file: String = #file,
                      line: Int = #line) {
        log(error, type: .error, function: function, file: file, line: line)
    }
}
