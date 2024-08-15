//
//  NetworkInjectionTests.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 03/07/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Fakery
import WebKit
import Factory
@testable import FlexaNetworking

final class NetworkInjectionTests: QuickSpec {

    override class func spec() {
        beforeEach {
            Container.shared.reset()
        }

        describe("urlSessionConfiguraton") {
            it("does not throw an error") {
                expect { Container.shared.urlSessionConfiguration() }.notTo(throwError())
            }
        }

        describe("urlSession") {
            it("does not throw an error") {
                expect { Container.shared.urlSession() }.notTo(throwError())
            }
        }

        describe("networkClient") {
            it("is an instance of NetworkService") {
                let client = Container.shared.networkClient()
                expect(client).to(beAKindOf(NetworkService.self))
            }
        }

        describe("sseUrlSessionConfiguration") {
            context("lastEventId is nil") {
                it("does not throw an error") {
                    expect { Container.shared.sseUrlSessionConfiguration((nil, 3000)) }.notTo(throwError())
                }

                let configuration = Container.shared.sseUrlSessionConfiguration((nil, 3000))
                it("adds only Accept and Cache-Control headers") {
                    expect(configuration.httpAdditionalHeaders?["Accept"] as? String).to(equal("text/event-stream"))
                    expect(configuration.httpAdditionalHeaders?["Cache-Control"] as? String).to(equal("no-cache"))
                    expect(configuration.httpAdditionalHeaders?["Last-Event-ID"]).to(beNil())
                }
            }

            context("lastEventId is not nil") {
                let configuration = Container.shared.sseUrlSessionConfiguration(("last-event-id", 3000))
                it("adds Accept,  Cache-Control and Last-Event-Id Headers") {
                    expect(configuration.httpAdditionalHeaders?["Accept"] as? String).to(equal("text/event-stream"))
                    expect(configuration.httpAdditionalHeaders?["Cache-Control"] as? String).to(equal("no-cache"))
                    expect(configuration.httpAdditionalHeaders?["Last-Event-ID"] as? String).to(equal("last-event-id"))
                }
            }
        }

        describe("sseUrlSession") {
            it("does not throw an error") {
                expect { Container.shared.sseUrlSession((nil, 3000, nil)) }.notTo(throwError())
            }
        }
    }
}
