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
        case unimplemented
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
        case cannotApproveCommerceSession(Error?)
        case cannotSetCommerceSessionPaymentAsset(Error?)
        case cannotSetCommerceSessionAmount(Error?)
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
            case .unimplemented:
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
            case .unimplemented:
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
            case .networkError(let error),
                    .cannotCreateAccount(let error),
                    .cannotGetAccount(let error),
                    .cannotDeleteAccount(let error),
                    .cannotDeleteAppNotification(let error),
                    .cannotConvertAsset(let error),
                    .cannotGetExchangeRates(let error),
                    .cannotGetAssets(let error),
                    .cannotGetBrands(let error),
                    .cannotSignTransaction(let error),
                    .cannotCreateCommerceSession(let error),
                    .cannotGetCommerceSession(let error),
                    .cannotWatchSession(let error),
                    .cannotCloseCommerceSession(let error),
                    .cannotApproveCommerceSession(let error),
                    .cannotSetCommerceSessionPaymentAsset(let error),
                    .cannotCreateToken(let error),
                    .cannotVerifyToken(let error),
                    .cannotRefreshToken(let error),
                    .cannotDeleteToken(let error),
                    .cannotSyncOneTimeKeys(let error):
                return error
            default:
                return nil
            }
        }
    }
}

// Equatable
extension ReasonableError.Reason: Equatable {
    public static func ==(lhs: ReasonableError.Reason, rhs: ReasonableError.Reason) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
            (.invalidValue, .invalidValue),
            (.unimplemented, .unimplemented):
            return true
        case (.customMessage(let lhsTitle, let lhsMessage), .customMessage(let rhsTitle, let rhsMessage)):
            return lhsTitle == rhsTitle && lhsMessage == rhsMessage
        case (.custom(let lhsError), .custom(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.networkError(let lhsError), .networkError(let rhsError)),
            (.cannotCreateAccount(let lhsError), .cannotCreateAccount(let rhsError)),
            (.cannotGetAccount(let lhsError), .cannotGetAccount(let rhsError)),
            (.cannotDeleteAccount(let lhsError), .cannotDeleteAccount(let rhsError)),
            (.cannotDeleteAppNotification(let lhsError), .cannotDeleteAppNotification(let rhsError)),
            (.cannotConvertAsset(let lhsError), .cannotConvertAsset(let rhsError)),
            (.cannotGetExchangeRates(let lhsError), .cannotGetExchangeRates(let rhsError)),
            (.cannotGetAssets(let lhsError), .cannotGetAssets(let rhsError)),
            (.cannotGetBrands(let lhsError), .cannotGetBrands(let rhsError)),
            (.cannotSignTransaction(let lhsError), .cannotSignTransaction(let rhsError)),
            (.cannotCreateCommerceSession(let lhsError), .cannotCreateCommerceSession(let rhsError)),
            (.cannotGetCommerceSession(let lhsError), .cannotGetCommerceSession(let rhsError)),
            (.cannotWatchSession(let lhsError), .cannotWatchSession(let rhsError)),
            (.cannotCloseCommerceSession(let lhsError), .cannotCloseCommerceSession(let rhsError)),
            (.cannotApproveCommerceSession(let lhsError), .cannotApproveCommerceSession(let rhsError)),
            (.cannotSetCommerceSessionPaymentAsset(let lhsError), .cannotSetCommerceSessionPaymentAsset(let rhsError)),
            (.cannotSetCommerceSessionAmount(let lhsError), .cannotSetCommerceSessionAmount(let rhsError)),
            (.cannotCreateToken(let lhsError), .cannotCreateToken(let rhsError)),
            (.cannotVerifyToken(let lhsError), .cannotVerifyToken(let rhsError)),
            (.cannotRefreshToken(let lhsError), .cannotRefreshToken(let rhsError)),
            (.cannotDeleteToken(let lhsError), .cannotDeleteToken(let rhsError)),
            (.cannotSyncOneTimeKeys(let lhsError), .cannotSyncOneTimeKeys(let rhsError)):
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        default:
            return false
        }
    }
}

extension ReasonableError: Equatable {
    public static func == (lhs: ReasonableError, rhs: ReasonableError) -> Bool {
        lhs.reason == rhs.reason
    }
}

public struct EquatableError: Error, Equatable {
    public let base: Error

    public init(_ base: Error) {
        self.base = base
    }

    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        guard let lhs = lhs.base as? ReasonableError, let rhs = rhs.base as? ReasonableError else {
            return false
        }
        return lhs == rhs
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
    public static let uninplemented = ReasonableError(reason: .unimplemented)
}

// MARK: Error
extension Error {
    public var isUnauthorized: Bool {
        if let networkError = self as? FlexaNetworking.NetworkError,
           networkError.isUnauthorized, let apiError = networkError.apiError {
            return apiError.isInvalidTokenError
        }

        if let reasonableError = self as? ReasonableError,
           let error = reasonableError.reason.error,
           let networkError = error as? FlexaNetworking.NetworkError,
           networkError.isUnauthorized, let apiError = networkError.apiError {
            return apiError.isInvalidTokenError
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

    public var isExpiredToken: Bool {
        if let networkError = self as? FlexaNetworking.NetworkError,
           let apiError = networkError.apiError {
            return apiError.isExpiredTokenError
        }

        if let reasonableError = self as? ReasonableError,
           let error = reasonableError.reason.error,
           let networkError = error as? FlexaNetworking.NetworkError,
           let apiError = networkError.apiError {
            return apiError.isExpiredTokenError
        }

        return false
    }
}
