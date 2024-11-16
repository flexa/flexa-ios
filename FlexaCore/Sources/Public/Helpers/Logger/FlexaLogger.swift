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

    public enum LoggerType {
        case `default`, commerceSession
    }

    private static let subsystem = (Bundle.main.bundleIdentifier ?? "") + "-Flexa"

    public static let commerceSessionLogger = Logger(subsystem: subsystem, category: "commerce_session")
    public static let defaultLogger = Logger(subsystem: subsystem, category: "flexa-default")

    public static func log(
        _ message: Any,
        type: MessageType = .default,
        logger: LoggerType = .default) {
            getLogger(logger).log(level: type.logType, "\(String(describing: message))")
        }

    public static func info(_ message: Any, logger: LoggerType = .default) {
        log(message, type: .info, logger: logger)
    }

    public static func debug(_ message: Any, logger: LoggerType = .default) {
        log(message, type: .debug, logger: logger)
    }

    public static func error(_ error: Any, logger: LoggerType = .default) {
        log(error, type: .error, logger: logger)
    }

    private static func getLogger(_ availableLogger: LoggerType) -> Logger {
        switch availableLogger {
        case .commerceSession:
            return commerceSessionLogger
        default:
            return defaultLogger
        }
    }
}

public extension Logger {
    public func info(_ message: Any) {
        self.log(level: .info, "\(String(describing: message))")
    }

    public func debug(_ message: Any) {
        self.log(level: .debug, "\(String(describing: message))")
    }

    public func error(_ error: Any) {
        self.log(level: .error, "\(String(describing: error))")
    }
}
