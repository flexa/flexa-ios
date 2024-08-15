//
//  DataExtensionsTests.swift
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

final class DataExtensionsTests: QuickSpec {
    override class func spec() {
        describe("base64URLEncodedString") {
            context("5 octets") {
                let octets: [UInt8] = [3, 236, 255, 224, 193]
                let data = Data(bytes: octets, count: octets.count)
                let expected = "A-z_4ME"
                it("returns \(expected)") {
                    expect(data.base64URLEncodedString).to(equal(expected))
                }
            }

            context("32 octets") {
                let octets: [UInt8] = [
                    116, 24, 223, 180, 151, 153, 224, 37, 79, 250, 96, 125, 216, 173,
                    187, 186, 22, 212, 37, 77, 105, 214, 191, 240, 91, 88, 5, 88, 83,
                    132, 141, 121
                ]
                let data = Data(bytes: octets, count: octets.count)
                let expected = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
                it("returns \(expected)") {
                    expect(data.base64URLEncodedString).to(equal(expected))
                }
            }

        }
    }
}
