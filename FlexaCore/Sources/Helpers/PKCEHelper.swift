//
//  PKCEHelper.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import CryptoKit

enum PKCEError: Error {
    case failedToGenerateRandomOctets
    case invalidVerifierFormat
}

protocol PKCEHelperProtocol {
    func generateVerifier() throws -> String
    func generateChallenge(for verifier: String) throws -> String
}

struct PKCEHelper: PKCEHelperProtocol {
    func generateChallenge(for verifier: String) throws -> String {
        guard let verifierData = verifier.data(using: .ascii) else {
            throw PKCEError.invalidVerifierFormat
        }
        return Data(SHA256.hash(data: verifierData)).base64URLEncodedString
    }

    func generateVerifier() throws -> String {
        try generateVerifier(randomOctets: generateRandomOctets(count: 32))
    }

    func generateVerifier(randomOctets: [UInt8]) throws -> String {
        return Data(bytes: randomOctets, count: randomOctets.count).base64URLEncodedString
    }

    func generateRandomOctets(count: Int) throws -> [UInt8] {
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)

        guard status == errSecSuccess else {
            throw PKCEError.failedToGenerateRandomOctets
        }
        return octets
    }
}
