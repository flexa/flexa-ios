//
//  ReasonableError.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import FlexaNetworking

public struct ReasonableError: Error, LocalizedError {
    let reason: Reason

    public var traceId: String?

    public var title: String? {
        reason.title
    }

    public var message: String? {
        reason.message
    }

    public var debugMessage: String? {
        reason.debugMessage
    }

    public var allowsReporting: Bool {
        debugMessage != nil
    }

    public var errorDescription: String? {
        localizedDescription
    }

    public var localizedDescription: String {
        message ?? ""
    }

    public var recoverySuggestion: String? {
        message ?? ""
    }

    public var isNetworkLost: Bool {
        reason.domain == NSURLErrorDomain && reason.code == -1005
    }

    init(reason: Reason, traceId: String? = nil) {
        self.reason = reason
        self.traceId = traceId
    }
}

// MARK: Reason
extension ReasonableError {
    enum Reason {
        case unknown
        case invalidValue
        case custom(Error)
        case missingMerchant(String)
        case customMessage(String, String)
        case uninplemented

        private static let errorSeparator: Character = "\n"

        var title: String? {
            switch self {
            case .unknown:
                return "Error"
            case .invalidValue:
                return "Invalid value"
            case .custom:
                return "An error has occurred"
            case .missingMerchant:
                return "Merchant not found"
            case .customMessage(let title, _):
                return title
            case .uninplemented:
                return "Soon"
            }
        }

        var message: String? {
            switch self {
            case .unknown:
                return "Unknown error"
            case .invalidValue:
                return "Invalid value"
            case .custom(let error):
                return error.localizedDescription
            case .missingMerchant:
                return "Missing merchant"
            case .customMessage(_, let message):
                return message
            case .uninplemented:
                return "This feature is not available yet"
            }
        }

        var debugMessage: String? {
            switch self {
                case .missingMerchant:
                    return "Missing merchant"
                default:
                    return nil
            }
        }

        var code: Int {
            switch self {
                case .custom(let error):
                    return (error as NSError).code
                default:
                    return 1
            }
        }

        var domain: String {
            switch self {
                case .custom(let error):
                    return (error as NSError).domain
                default:
                    return ""
            }
        }

        var error: Error? {
            switch self {
                case .custom(let error):
                    return error
                default:
                    return nil
            }
        }
    }
}

// MARK: Static methods
extension ReasonableError {
    public static func custom(title: String, message: String) -> ReasonableError {
        return ReasonableError(reason: .customMessage(title, message))
    }

    public static func custom(error: Error, traceId: String? = nil) -> ReasonableError {
        guard let reasonableError = error as? ReasonableError else {
            return ReasonableError(reason: .custom(error), traceId: traceId)
        }

        return reasonableError
    }

    public static func missingMerchant(id: String) -> ReasonableError {
        return ReasonableError(reason: .missingMerchant(id))
    }

    public static let unknown = ReasonableError(reason: .unknown)
    public static let invalidValue = ReasonableError(reason: .invalidValue)
    public static let uninplemented = ReasonableError(reason: .uninplemented)
}

// MARK: Error
extension Error {
    public var isUnauthorized: Bool {
        if let networkError = self as? FlexaNetworking.NetworkError,
           networkError.isUnauthorized {
            return true
        }

        if let reasonableError = self as? ReasonableError,
           case .custom(let error) = reasonableError.reason,
           let networkError = error as? FlexaNetworking.NetworkError,
           networkError.isUnauthorized {
            return true
        }

        return false
    }
}
