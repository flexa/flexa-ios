//
//  PKCEHelperTests.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Factory
import Foundation
@testable import FlexaCore

final class PKCEHelperTests: QuickSpec {
    override class func spec() {
        let helper = PKCEHelper()
        let octets: [UInt8] = [
            116, 24, 223, 180, 151, 153, 224, 37, 79, 250, 96, 125, 216, 173,
            187, 186, 22, 212, 37, 77, 105, 214, 191, 240, 91, 88, 5, 88, 83,
            132, 141, 121
        ]

        let expectedVerifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
        let expectedChallenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"

        describe("generateVerifier(randomOctets:)") {
            // swiftlint:disable:next force_try
            let verifier = try! helper.generateVerifier(randomOctets: octets)
            it("returns octets url-safe base64 encoded") {
                expect(verifier).to(equal(expectedVerifier))
            }
        }

        describe("generateVerifier") {
            it("a 48 characters random string") {
                expect(try helper.generateVerifier().count).to(equal(43))
            }
        }

        describe("generateChallenge(for:)") {
            context("Verifier with valid ascii characters") {
                // swiftlint:disable:next force_try
                let challenge = try! helper.generateChallenge(for: expectedVerifier)
                it("returns PKCE SHA-256 hash of the verifier url-safe base64 encoded") {
                    expect(challenge).to(equal(expectedChallenge))
                }
            }

            context("Verifier with invalid ascii characters") {
                it("throws a invalidVerifierFormat error") {
                    expect(try helper.generateChallenge(for: "oops é")).to(throwError(PKCEError.invalidVerifierFormat))
                }
            }
        }
    }
}
