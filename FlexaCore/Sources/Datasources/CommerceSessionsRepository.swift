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
    private let timeoutInterval: TimeInterval = 3000
    private var onEvent: ((Result<CommerceSessionEvent, Error>) -> Void)?
    private var sseClient: SSEClientProtocol?
    private var lastEventId: String?

    func stopWatching() {
        SSECommerceSessionEvent.allCases.forEach { event in
            sseClient?.removeListener(for: event.rawValue)
        }
        sseClient?.disconnect()
        lastEventId = nil
        sseClient = nil
    }

    func watch(_ onEvent: @escaping (Result<CommerceSessionEvent, Error>) -> Void) {
        let resource = CommerceSessionResource.watch(SSECommerceSessionEvent.allCases.map({ $0.rawValue }))
        guard var sseClient = Container.shared.sseClient((resource, timeoutInterval)) else {
            FlexaLogger.error("Cannot create an SSEClient for \(resource)")
            return
        }

        self.sseClient = sseClient
        self.onEvent = onEvent

        SSECommerceSessionEvent.allCases.forEach { event in
            sseClient.addListener(for: event.rawValue, handler: eventHandler)
        }

        sseClient.connect(lastEventId: lastEventId)
    }

    func create(brand: Brand, amount: Decimal, assetId: String, paymentAssetId: String) async throws -> CommerceSession {
        let input = CreateCommerceSessionInput(
            brand: brand.id,
            amount: amount,
            asset: assetId,
            paymentAsset: paymentAssetId
        )

        let commerceSession: Models.CommerceSession = try await networkClient.sendRequest(resource: CommerceSessionResource.create(input))

        return commerceSession
    }

    func close(_ id: String) async throws {
        try await networkClient.sendRequest(
            resource: CommerceSessionResource.close(id)
        )
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
        do {
            let event = try Models.Event<Models.CommerceSession>(data)
            let commerceSessionEvent = sseCommerceSessionEvent.commerceSessionEvent(event.data)
            onEvent(.success(commerceSessionEvent))
        } catch let error {
            FlexaLogger.error(error)
            onEvent(.failure(error))
        }
    }
}

enum SSECommerceSessionEvent: String, CaseIterable {
    case created = "commerce_session.created"
    case updated = "commerce_session.updated"
    case completed = "commerce_session.completed"

    func commerceSessionEvent(_ session: CommerceSession) -> CommerceSessionEvent {
        switch self {
        case .created:
            return .created(session)
        case .updated:
            return .updated(session)
        case .completed:
            return .completed(session)
        }
    }
}
