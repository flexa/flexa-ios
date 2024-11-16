//
//  CommerceSessionsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/13/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import SwiftUI
import FlexaNetworking

class CommerceSessionsRepository: CommerceSessionsRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.keychainHelper) private var keychain
    @Injected(\.authStore) private var authStore

    private let timeoutInterval: TimeInterval = 3000
    private var onEvent: ((Result<CommerceSessionEvent, Error>) -> Void)?
    private var sseClient: SSEClientProtocol?
    private var lastEventId: String?
    private var retryInterval: Int = 3000
    private var watchCurrentOnly: Bool = false

    @Synchronized
    private var current: CurrentCommerceSession? {
        didSet {
            keychain.setValue(current, forKey: .currentCommerceSession)
        }
    }

    init() {
        current = keychain.value(forKey: .currentCommerceSession)
    }

    func create(
        brand: Brand,
        amount: Decimal,
        assetId: String,
        paymentAssetId: String
    ) async throws -> CommerceSession {
        let input = CreateCommerceSessionInput(
            brand: brand.id,
            amount: amount,
            asset: assetId,
            paymentAsset: paymentAssetId
        )

        let commerceSession: Models.CommerceSession = try await networkClient.sendRequest(
            resource: CommerceSessionResource.create(input)
        )

        return commerceSession
    }

    func get(_ id: String) async throws -> CommerceSession {
        let commerceSession: Models.CommerceSession = try await networkClient.sendRequest(
            resource: CommerceSessionResource.get(id)
        )
        return commerceSession
    }

    func getCurrent() async throws -> (
        commerceSession: CommerceSession?,
        isLegacy: Bool,
        wasTransactionSent: Bool,
        lastEventId: String?) {
            let emptyResponse: (CommerceSession?, Bool, Bool, String?) = (nil, false, false, nil)

            guard let current else {
                return emptyResponse
            }
            do {
                let commerceSession = try await get(current.id)
                return (commerceSession, current.isLegacy, current.wasTransactionSent, current.lastEventId)
            } catch let error {
                FlexaLogger.error(error)
                self.current = nil
                return emptyResponse
            }
    }

    func setCurrent(_ commerceSession: CommerceSession?, isLegacy: Bool, wasTransactionSent: Bool) {
        guard let commerceSession else {
            current = nil
            return
        }
        current = CurrentCommerceSession(
            id: commerceSession.id,
            isLegacy: isLegacy,
            lastEventId: lastEventId,
            wasTransactionSent: wasTransactionSent
        )
    }

    func clearCurrent() {
        current = nil
    }

    func close(_ id: String) async throws {
        try await networkClient.sendRequest(
            resource: CommerceSessionResource.close(id)
        )
    }

    func approve(_ id: String) async throws {
        try await networkClient.sendRequest(
            resource: CommerceSessionResource.approve(id)
        )
    }

    func watch(currentOnly: Bool, onEvent: @escaping (Result<CommerceSessionEvent, Error>) -> Void) {
        watchCurrentOnly = currentOnly
        let resource = CommerceSessionResource.watch(SSECommerceSessionEvent.allCases.map({ $0.rawValue }))
        guard var sseClient = Container.shared.sseClient((resource, timeoutInterval)) else {
            FlexaLogger.commerceSessionLogger.error("Cannot create an SSEClient for \(resource)")
            return
        }

        self.sseClient = sseClient
        self.onEvent = onEvent

        SSECommerceSessionEvent.allCases.forEach { event in
            sseClient.addListener(for: event.rawValue, handler: eventHandler)
        }

        sseClient.onComplete = { [weak self] status, shouldRetry, error in
            FlexaLogger.commerceSessionLogger.debug("SSEClient.oncComplete(status: \(status), shouldRetry: \(shouldRetry), error: \(error))")
            guard let self, shouldRetry == true else {
                return
            }

            if let error, error.isUnauthorized {
                refreshTokenAndRetry()
                return
            }

            if status == NetworkError.unauthorizedStatusCode || status == NetworkError.forbiddenStatusCode {
                refreshTokenAndRetry()
                return
            }

            retryAfterInterval()
        }

        sseClient.connect(lastEventId: lastEventId)
    }

    func stopWatching() {
        FlexaLogger.commerceSessionLogger.debug("Stop Watching events")
        SSECommerceSessionEvent.allCases.forEach { event in
            sseClient?.removeListener(for: event.rawValue)
        }
        sseClient?.disconnect()
        lastEventId = nil
        sseClient = nil
    }

    func setPaymentAsset(commerceSessionId id: String, assetId: String) async throws {
        try await networkClient.sendRequest(
            resource: CommerceSessionResource.setPaymentAsset(
                id,
                SetPaymentAssetInput(paymentAssetId: assetId)
            )
        )
    }

    private func eventHandler(_ event: SSE.Event) {
        guard
            let onEvent,
            let eventType = event.eventType,
            let sseCommerceSessionEvent = SSECommerceSessionEvent(rawValue: eventType),
            let data = event.data else {
            return
        }

        lastEventId = event.id ?? lastEventId

        if let retry = event.retry, let newRetryInterval = Int(retry) {
            retryInterval = newRetryInterval
        }

        do {
            let event = try Models.Event<Models.CommerceSession>(data)
            let commerceSessionEvent = sseCommerceSessionEvent.commerceSessionEvent(event.data)
            onEvent(.success(commerceSessionEvent))
        } catch let error {
            FlexaLogger.commerceSessionLogger.error(error)
            onEvent(.failure(error))
        }
    }

    private func shouldNotifyEvent(_ event: Models.Event<Models.CommerceSession>) -> Bool {
        guard let current, watchCurrentOnly else {
            return true
        }

        return current.id == event.data.id
    }

    private func retryAfterInterval() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.retryInterval)) { [weak self] in
            guard let self else {
                return
            }
            sseClient?.connect(lastEventId: self.lastEventId)
        }
    }

    private func refreshTokenAndRetry() {
        Task {
            do {
                guard let onEvent else {
                    return
                }
                try await authStore.refreshToken()
                if let request = CommerceSessionResource.watch(SSECommerceSessionEvent.allCases.map({ $0.rawValue })).request {
                    sseClient?.connect(request: request, lastEventId: lastEventId)
                }
            } catch let error {
                stopWatching()
                FlexaLogger.error(error)
            }
        }
    }
}

enum SSECommerceSessionEvent: String, CaseIterable {
    case created = "commerce_session.created"
    case requiresTransaction = "commerce_session.requires_transaction"
    case requiresApproval = "commerce_session.requires_approval"
    case closed = "commerce_session.closed"
    case completed = "commerce_session.completed"

    func commerceSessionEvent(_ session: CommerceSession) -> CommerceSessionEvent {
        switch self {
        case .created:
            return .created(session)
        case .requiresTransaction:
            return .requiresTransaction(session)
        case .requiresApproval:
            return .requiresApproval(session)
        case .completed:
            return .completed(session)
        case .closed:
            return .closed(session)
        }
    }
}

private extension CommerceSessionsRepository {
    struct CurrentCommerceSession: FlexaModelProtocol {
        var id: String
        var isLegacy: Bool
        var lastEventId: String?
        var wasTransactionSent: Bool
    }
}
