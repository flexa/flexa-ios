//
//  NetworkErrorTests.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 06/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Fakery
import WebKit
import XCTest
import Factory
@testable import FlexaNetworking

final class NetworkErrorTests: QuickSpec {
    override class func spec() {
        describe("isUnauthorized") {
            context("status is 401") {
                let subject = NetworkError.invalidStatus(status: 401, resource: DefaultTestAPIResource(), request: nil, data: nil)

                it("is true") {
                    expect(subject.isUnauthorized).to(beTrue())
                }
            }

            context("status is not 401") {
                let status = Faker().number.randomInt(min: 200, max: 400)
                let subject = NetworkError.invalidStatus(status: status, resource: DefaultTestAPIResource(), request: nil, data: nil)
                it("is false") {
                    expect(subject.isUnauthorized).to(beFalse())
                }
            }
        }
    }
}
