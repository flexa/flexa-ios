//
//  TOTPGeneratorTests.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 5/24/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Fakery
import Foundation
@testable import FlexaSpend

class TOTPGeneratorSpec: QuickSpec {
    override class func spec() {
        describe("generate") {
            for testCase in TOTPTestData.testData {
                context("with time: \(testCase.time), digits: \(testCase.digits), timeInterval: \(testCase.timeInterval), algorithm: \(testCase.algorithm)") {
                    let generator = TOTPGenerator(
                        secret: TOTPTestData.sharedSecrets[testCase.algorithm]!, // swiftlint:disable:this force_unwrapping
                        digits: testCase.digits,
                        timeInterval: testCase.timeInterval,
                        algorithm: testCase.algorithm
                    )
                    it("returns \(testCase.totp)") {
                        expect(generator.generate(secondsSince1970: testCase.time)).to(equal(testCase.totp))
                    }
                }
            }

            context("with an invalid number of digits") {
                context("digits < 1") {
                    let generator = TOTPGenerator(
                        secret: TOTPTestData.sharedSecrets[.sha1]!, // swiftlint:disable:this force_unwrapping
                        digits: 0,
                        timeInterval: 30,
                        algorithm: .sha1
                    )

                    it("returns nil") {
                        expect(generator.generate(secondsSince1970: 59)).to(beNil())
                    }
                }

                context("digits > 10") {
                    let generator = TOTPGenerator(
                        secret: TOTPTestData.sharedSecrets[.sha1]!, // swiftlint:disable:this force_unwrapping
                        digits: 11,
                        timeInterval: 30,
                        algorithm: .sha1
                    )

                    it("returns nil") {
                        expect(generator.generate(secondsSince1970: 59)).to(beNil())
                    }
                }

            }

            context("with invalid seconds (negative)") {
                let generator = TOTPGenerator(
                    secret: TOTPTestData.sharedSecrets[.sha1]!, // swiftlint:disable:this force_unwrapping
                    digits: 6,
                    algorithm: .sha1
                )

                it("returns nil") {
                    expect(generator.generate(secondsSince1970: -1)).to(beNil())
                }
            }
        }
    }
}

private struct TOTPTestData {
    let time: Int
    let digits: Int
    let timeInterval: Int
    let totp: String
    let algorithm: HMACAlgorithm

    init(time: Int, digits: Int = 8, timeInterval: Int = 30, totp: String, algorithm: HMACAlgorithm) {
        self.time = time
        self.digits = digits
        self.timeInterval = timeInterval
        self.totp = totp
        self.algorithm = algorithm
    }

    static let sharedSecrets: [HMACAlgorithm: Data] = [
        .sha1: "12345678901234567890".data(using: .ascii)!, // swiftlint:disable:this force_unwrapping
        .sha256: "12345678901234567890123456789012".data(using: .ascii)!, // swiftlint:disable:this force_unwrapping
        .sha512: "1234567890123456789012345678901234567890123456789012345678901234".data(using: .ascii)! // swiftlint:disable:this force_unwrapping line_length
    ]

    // Test data can be found at: https://www.rfc-editor.org/rfc/rfc6238#appendix-B
    static let testData: [Self] = [
        .init(time: 59, totp: "94287082", algorithm: .sha1),
        .init(time: 59, totp: "46119246", algorithm: .sha256),
        .init(time: 59, totp: "90693936", algorithm: .sha512),
        .init(time: 1111111109, totp: "07081804", algorithm: .sha1),
        .init(time: 1111111109, totp: "68084774", algorithm: .sha256),
        .init(time: 1111111109, totp: "25091201", algorithm: .sha512),
        .init(time: 1111111111, totp: "14050471", algorithm: .sha1),
        .init(time: 1111111111, totp: "67062674", algorithm: .sha256),
        .init(time: 1111111111, totp: "99943326", algorithm: .sha512),
        .init(time: 1234567890, totp: "89005924", algorithm: .sha1),
        .init(time: 1234567890, totp: "91819424", algorithm: .sha256),
        .init(time: 1234567890, totp: "93441116", algorithm: .sha512),
        .init(time: 2000000000, totp: "69279037", algorithm: .sha1),
        .init(time: 2000000000, totp: "90698825", algorithm: .sha256),
        .init(time: 2000000000, totp: "38618901", algorithm: .sha512),
        .init(time: 20000000000, totp: "65353130", algorithm: .sha1),
        .init(time: 20000000000, totp: "77737706", algorithm: .sha256),
        .init(time: 20000000000, totp: "47863826", algorithm: .sha512)
    ]
}
