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
public extension ReasonableError {
    private typealias Strings = CoreStrings.Errors

    enum Reason {
        case unknown
        case invalidValue
        case custom(Error)
        case customMessage(String, String)
        case uninplemented
        case networkError(Error?)
        case cannotCreateAccount(Error?)
        case cannotGetAccount(Error?)
        case cannotDeleteAccount(Error?)
        case cannotDeleteAppNotification(Error?)
        case cannotConvertAsset(Error?)
        case cannotGetExchangeRates(Error?)
        case cannotGetAssets(Error?)
        case cannotGetBrands(Error?)
        case cannotSignTransaction(Error?)
        case cannotCreateCommerceSession(Error?)
        case cannotGetCommerceSession(Error?)
        case cannotWatchSession(Error?)
        case cannotCloseCommerceSession(Error?)
        case cannotSetCommerceSessionPaymentAsset(Error?)
        case cannotCreateToken(Error?)
        case cannotVerifyToken(Error?)
        case cannotRefreshToken(Error?)
        case cannotDeleteToken(Error?)
        case cannotSyncOneTimeKeys(Error?)

        var title: String? {
            switch self {
            case .unknown:
                return Strings.Unknown.title
            case .invalidValue:
                return Strings.InvalidValue.title
            case .customMessage(let title, _):
                return title
            case .uninplemented:
                return Strings.Unimplemented.title
            default:
                return Strings.Default.title
            }
        }

        var message: String? {
            switch self {
            case .unknown:
                return Strings.Unknown.message
            case .invalidValue:
                return Strings.InvalidValue.message
            case .custom(let error):
                return error.localizedDescription
            case .customMessage(_, let message):
                return message
            case .uninplemented:
                return Strings.Unimplemented.message
            default:
                return Strings.Default.message
            }
        }

        var debugMessage: String? {
            nil
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

    public static func withReason(_ reason: Reason, traceId: String? = nil) -> ReasonableError {
        return ReasonableError(reason: reason, traceId: traceId)
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

    public var isRestrictedRegion: Bool {
        if let networkError = self as? FlexaNetworking.NetworkError,
           let apiError = networkError.apiError {
            return apiError.isRestrictedRegion
        }

        if let reasonableError = self as? ReasonableError,
           case .custom(let error) = reasonableError.reason,
           let networkError = error as? FlexaNetworking.NetworkError,
           let apiError = networkError.apiError {
            return apiError.isRestrictedRegion
        }
        return false
    }
}
