//
//  CommerceSessionsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/13/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public enum CommerceSessionEvent {
    case created(CommerceSession)
    case requiresTransaction(CommerceSession)
    case requiresApproval(CommerceSession)
    case completed(CommerceSession)
    case closed(CommerceSession)

    public var commerceSession: CommerceSession {
        switch self {
        case .created(let commerceSession),
                .requiresTransaction(let commerceSession),
                .requiresApproval(let commerceSession),
                .completed(let commerceSession),
                .closed(let commerceSession):
            return commerceSession
        }
    }
}

public protocol CommerceSessionsRepositoryProtocol {
    func watch(currentOnly: Bool, onEvent: @escaping (Result<CommerceSessionEvent, Error>) -> Void)
    func get(_ id: String) async throws -> CommerceSession
    func getCurrent() async throws -> (
        commerceSession: CommerceSession?,
        isLegacy: Bool,
        wasTransactionSent: Bool,
        lastEventId: String?
    )
    func setCurrent(_ commerceSession: CommerceSession?, isLegacy: Bool, wasTransactionSent: Bool)
    func clearCurrent()
    func close(_ id: String) async throws
    func approve(_ id: String) async throws
    func setPaymentAsset(commerceSessionId: String, assetId: String) async throws
    func stopWatching()
    func create(brand: Brand, amount: Decimal, assetId: String, paymentAssetId: String) async throws -> CommerceSession
    func create(paymentLink: URL, paymentAssetId: String) async throws -> CommerceSession
}
