//
//  FlexaAPIResourceTests.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/2/24.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Nimble
import Quick
import Factory
import Foundation
@testable import FlexaCore

final class FlexaAPIResourceTests: QuickSpec {
    private static var resource: TestResource!
    private static let publishableKey = "publishable_test_\(UUID().uuidString)"
    private static let authToken = Data((":" + publishableKey).utf8).base64EncodedString()
    private static let authHeader = "Basic \(authToken)"
    private static let flexaClient = FXClient(publishableKey: publishableKey, assetAccounts: [], theme: .default)

    override class func setUp() {
        Container.shared.flexaClient.register { flexaClient }
        resource = TestResource(authToken: authToken)
    }

    override class func spec() {
        describe("scheme") {
            it("is https") {
                expect(resource.scheme).to(equal("https"))
            }
        }

        describe("host") {
            it("is api.flexa.co") {
               expect(resource.host).to(equal("api.flexa.co"))
            }
        }

        describe("method") {
            it("is get") {
                expect(resource.method).to(equal(.get))
            }
        }

        describe("headers") {
            it("is nil") {
                expect(resource.headers).to(beNil())
            }
        }

        describe("queryParams") {
            it("is nil") {
                expect(resource.queryParams).to(beNil())
            }
        }

        describe("pathParams") {
            it("is nil") {
                expect(resource.pathParams).to(beNil())
            }
        }

        describe("bodyParams") {
            it("is nil") {
                expect(resource.bodyParams).to(beNil())
            }
        }

        describe("authToken") {
            it("is equal to the publishable key base64 encoded") {
                expect(resource.authToken).to(equal(authToken))
            }
        }

        describe("authHeader") {
            context("with authToken") {
                it("is equal to 'Basic [authToken]'") {
                    expect(resource.authHeader).to(equal(authHeader))
                }
            }

            context("without authToken") {
                let noTokenResource = TestResource(authToken: nil)
                it("is nil") {
                    expect(noTokenResource.authHeader).to(beNil())
                }
            }
        }
    }
}

private struct TestResource: FlexaAPIResource {
    var authToken: String?
}
