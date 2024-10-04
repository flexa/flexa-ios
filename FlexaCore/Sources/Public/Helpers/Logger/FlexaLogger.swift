//
//  FlexaLogger.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import os.log

public class FlexaLogger {
    public enum MessageType: String, CaseIterable {
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

    private static let oslog = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "Flexa",
        category: "default"
    )

    public static func log(
        _ message: Any,
        type: MessageType = .default,
        function: String = #function,
        file: String = #file,
        line: Int = #line) {

            os_log(
                "[Flexa][%{public}@/%{public}@:%{public}@] %{public}@",
                log: oslog,
                type: type.logType,
                (file as NSString).lastPathComponent,
                function,
                "\(line)",
                String(describing: message)
            )
        }

    public static func info(_ message: Any,
                            function: String = #function,
                            file: String = #file,
                            line: Int = #line) {

        log(message, type: .info, function: function, file: file, line: line)
    }

    public static func debug(_ message: Any,
                             function: String = #function,
                             file: String = #file,
                             line: Int = #line) {
        log(message, type: .debug, function: function, file: file, line: line)
    }

    public static func error(_ error: Any,
                             function: String = #function,
                             file: String = #file,
                             line: Int = #line) {
        log(error, type: .error, function: function, file: file, line: line)
    }
}
