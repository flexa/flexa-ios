//
//  TransactionsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class TransactionsRepository: TransactionsRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient

    func addSignature(transactionId: String, signature: String) async throws {
        try await networkClient.sendRequest(
            resource: TransactionsResource.sign(
                id: transactionId,
                signature: signature
            )
        )
    }
}
