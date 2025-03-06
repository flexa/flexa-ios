//
//  FlexaLinkTests.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 12/17/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Factory
import Foundation
import Fakery

import XCTest
@testable import FlexaCore

// swiftlint:disable force_unwrapping function_body_length
final class FlexaLinkTests: QuickSpec {
    override class func spec() {
        let url = URL(string: Faker().internet.url())!
        let howToPayUrlString = "https://flexa.co/guides/how-to-pay"
        let reportIssueUrlString = "https://flexa.co/report-an-issue"

        describe("howToPay") {
            it("is webView with url '\(howToPayUrlString)'") {
                expect(FlexaLink.howToPay).to(equal(FlexaLink.webView(URL(string: howToPayUrlString))))
            }
        }

        describe("reportIssue") {
            it("is webView with url '\(reportIssueUrlString)'") {
                expect(FlexaLink.reportIssue).to(equal(FlexaLink.webView(URL(string: reportIssueUrlString))))
            }
        }

        describe("path") {
            context("is account") {
                it("returns '/account'") {
                    expect(FlexaLink.account.path).to(equal("/account"))
                }
            }

            context("is webView") {
                context("url is nil") {
                    it("returns nil") {
                        expect(FlexaLink.webView(nil).path).to(beNil())
                    }
                }

                context("url is not nil") {
                    it("returns nil") {
                        expect(FlexaLink.webView(url).path).to(beNil())
                    }
                }
            }

            context("is systemBrowser") {
                context("url is nil") {
                    it("returns nil") {
                        expect(FlexaLink.systemBrowser(nil).path).to(beNil())
                    }
                }

                context("url is not nil") {
                    it("returns nil") {
                        expect(FlexaLink.systemBrowser(url).path).to(beNil())
                    }
                }
            }

            context("is paymentLink") {
                it("returns nil") {
                    expect(FlexaLink.paymentLink(url).path).to(beNil())
                }
            }
        }

        describe("url") {
            context("is account") {
                it("returns https://flexa.co/account") {
                    expect(FlexaLink.account.url).to(equal(URL(string: "https://flexa.co/account")))
                }
            }

            context("is webView") {
                context("url is nil") {
                    it("returns nil") {
                        expect(FlexaLink.webView(nil).url).to(beNil())
                    }
                }

                context("url is \(url.absoluteString)") {
                    it("returns \(url.absoluteString)") {
                        expect(FlexaLink.webView(url).url).to(equal(url))
                    }
                }
            }

            context("is systemBrowser") {
                context("url is nil") {
                    it("returns nil") {
                        expect(FlexaLink.systemBrowser(nil).url).to(beNil())
                    }
                }

                context("url is \(url.absoluteString)") {
                    it("returns \(url.absoluteString)") {
                        expect(FlexaLink.systemBrowser(url).url).to(equal(url))
                    }
                }
            }

            context("is paymentLink with url \(url.absoluteString)") {
                it("returns \(url.absoluteString)") {
                    expect(FlexaLink.paymentLink(url).url).to(equal(url))
                }
            }
        }
    }
}
// swiftlint:enbable force_unwrapping function_body_length
