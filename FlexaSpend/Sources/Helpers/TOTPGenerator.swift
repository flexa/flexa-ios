//
//  TOTPGenerator.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 5/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import CryptoKit

enum HMACAlgorithm: String, CaseIterable {
    case sha1, sha256, sha512

    func authenticate(_ data: Data, using key: SymmetricKey) -> Data {
        switch self {
        case .sha1:
            let mac = HMAC<Insecure.SHA1>.authenticationCode(for: data, using: key)
            return Data(mac)
        case .sha256:
            let mac = HMAC<SHA256>.authenticationCode(for: data, using: key)
            return Data(mac)
        case .sha512:
            let mac = HMAC<SHA512>.authenticationCode(for: data, using: key)
            return Data(mac)
        }
    }
}

protocol TOTPGeneratorProtocol {
    init(secret: Data, digits: Int, timeInterval: Int, algorithm: HMACAlgorithm)
    func generate(secondsSince1970: Int) -> String?
}

struct TOTPGenerator: TOTPGeneratorProtocol {
    // See
    // https://www.rfc-editor.org/rfc/rfc6238
    // https://www.rfc-editor.org/rfc/rfc4226#section-5

    let secret: Data
    let digits: Int
    let timeInterval: Int
    let algorithm: HMACAlgorithm
    let validDigits = 1...10

    init(secret: Data, digits: Int = 6, timeInterval: Int = 30, algorithm: HMACAlgorithm = .sha1) {
        self.secret = secret
        self.digits = digits
        self.timeInterval = timeInterval
        self.algorithm = algorithm
    }

    func generate(secondsSince1970 seconds: Int) -> String? {
        // Validate the seconds and number of digits
        guard seconds > 0, validDigits ~= digits else {
            return nil
        }

        // Calculate the the time-based counter
        let counter = UInt64(seconds / timeInterval)

        // Convert to big endian
        let counterData = withUnsafeBytes(of: counter.bigEndian) { Data($0) }

        // Compute the HMAC hash with the secret key
        let key = SymmetricKey(data: secret)
        let hash = algorithm.authenticate(counterData, using: key)

        // Get last 4 bits of hash as offset (dynamic truncation)
        let offset = Int((hash.last ?? 0x00) & 0x0f)

        // Extracts 4 bytes of the hash starting at the offset
        let truncatedHash = hash[offset..<offset + 4]

        // Convert to UInt32 bit endian
        var number: UInt32 = 0
        truncatedHash.withUnsafeBytes { buffer in
            guard buffer.count >= 4 else {
                return
            }
            // Extract 4 bytes and construct a UInt32 in big-endian order
            number = UInt32(buffer[0]) << 24
            | UInt32(buffer[1]) << 16
            | UInt32(buffer[2]) << 8
            | UInt32(buffer[3])
        }

        // Mask most significant bit to ensure we have a positive number
        number &= 0x7fffffff

        // Ensure we have the right number of digits
        number = number % UInt32(pow(10, Float(digits)))

        // Add leading zeros if necessary and return
        return String(format: "%0*u", digits, number)
    }
}
