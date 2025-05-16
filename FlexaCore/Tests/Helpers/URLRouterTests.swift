//
//  URLRouterTests.swift
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
@testable import FlexaCore

// swiftlint:disable function_body_length force_unwrapping line_length
final class URLRouterTests: QuickSpec {
    private struct Links {
        struct Flexa {
            struct Main {
                static let guides = URL(string: "https://flexa.co/guides/how-to-pay")!
                static let explore = URL(string: "https://flexa.co/explore/how-to-pay")!
                static let reportIssue = URL(string: "https://flexa.co/report-issue")!
                static let account = URL(string: "https://flexa.co/account")!
                static let accountData = URL(string: "https://flexa.co/account/data")!
                static let accountDeletion = URL(string: "https://flexa.co/account/delete")!
                static let paymentLink = URL(string: "https://flexa.co/pay/1234")!
                static let spend = URL(string: "https://flexa.co/pay")!
                static let scan = URL(string: "https://flexa.co/scan")!
                static let pinned = URL(string: "https://flexa.co/pinned")!
                static let verify = URL(string: "https://flexa.co/verify")!
                static let merchants = URL(string: "https://flexa.co/directory")!
            }

            struct Link {
                static let guides = URL(string: "https://flexa.link/guides/how-to-pay")!
                static let explore = URL(string: "https://flexa.link/explore/how-to-pay")!
                static let reportIssue = URL(string: "https://flexa.link/report-issue")!
                static let account = URL(string: "https://flexa.link/account")!
                static let accountData = URL(string: "https://flexa.link/account/data")!
                static let accountDeletion = URL(string: "https://flexa.link/account/delete")!
                static let paymentLink = URL(string: "https://flexa.link/pay/1234")!
                static let spend = URL(string: "https://flexa.link/pay")!
                static let scan = URL(string: "https://flexa.link/scan")!
                static let pinned = URL(string: "https://flexa.link/pinned")!
                static let verify = URL(string: "https://flexa.link/verify")!
                static let merchants = URL(string: "https://flexa.link/directory")!
            }
        }

        static let nonFlexa = URL(string: Faker().internet.url())!
    }

    override class func spec() {
        let subject = URLRouter()

        describe("isFlexaUrl") {
            context("is a flexa.co url") {
                it("returns true") {
                    expect(subject.isFlexaUrl(Links.Flexa.Main.guides)).to(beTrue())
                }
            }

            context("is a flexa.link url") {
                it("returns true") {
                    expect(subject.isFlexaUrl(Links.Flexa.Link.guides)).to(beTrue())
                }
            }

            context("is not a flexa.link or flexa.co url") {
                it("returns false") {
                    expect(subject.isFlexaUrl(Links.nonFlexa)).to(beFalse())
                }
            }
        }

        describe("shouldReplaceDomain") {
            context("is a flexa.co url") {
                context("path is /guides") {
                    it("returns true") {
                        expect(subject.shouldReplaceDomain(for: Links.Flexa.Main.guides)).to(beTrue())
                    }
                }
                context("path is /explore") {
                    it("returns true") {
                        expect(subject.shouldReplaceDomain(for: Links.Flexa.Main.explore)).to(beTrue())
                    }
                }
                context("path is not /explore or /guides") {
                    it("returns false") {
                        expect(subject.shouldReplaceDomain(for: Links.Flexa.Main.reportIssue)).to(beFalse())
                    }
                }
            }

            context("is a flexa.link url") {
                context("path is /guides") {
                    it("returns true") {
                        expect(subject.shouldReplaceDomain(for: Links.Flexa.Link.guides)).to(beTrue())
                    }
                }
                context("path is /explore") {
                    it("returns true") {
                        expect(subject.shouldReplaceDomain(for: Links.Flexa.Link.explore)).to(beTrue())
                    }
                }
                context("path is not /explore or /guides") {
                    it("returns false") {
                        expect(subject.shouldReplaceDomain(for: Links.Flexa.Link.reportIssue)).to(beFalse())
                    }
                }
            }

            context("is not a flexa.link or flexa.co url") {
                it("returns false") {
                    expect(subject.shouldReplaceDomain(for: Links.nonFlexa)).to(beFalse())
                }
            }
        }

        describe("replaceDomain") {
            context("is a flexa.co url") {
                context("path is /guides") {
                    it("returns the same url") {
                        expect(subject.replaceDomain(for: Links.Flexa.Main.guides)).to(equal(Links.Flexa.Main.guides))
                    }
                }
                context("path is /explore") {
                    it("returns the same url)") {
                        expect(subject.replaceDomain(for: Links.Flexa.Main.explore)).to(equal(Links.Flexa.Main.explore))
                    }
                }
                context("path is not /explore or /guides") {
                    it("returns the same url") {
                        expect(subject.replaceDomain(for: Links.Flexa.Main.reportIssue)).to(equal(Links.Flexa.Main.reportIssue))
                    }
                }
            }

            context("is a flexa.link url") {
                context("path is /guides") {
                    it("returns the same url but replacing flexa.link by flexa.co") {
                        expect(subject.replaceDomain(for: Links.Flexa.Link.guides)).to(equal(Links.Flexa.Main.guides))
                    }
                }
                context("path is /explore") {
                    it("returns the same url but replacing flexa.link by flexa.co") {
                        expect(subject.replaceDomain(for: Links.Flexa.Link.explore)).to(equal(Links.Flexa.Main.explore))
                    }
                }
                context("path is not /explore or /guides") {
                    it("returns the same url") {
                        expect(subject.replaceDomain(for: Links.Flexa.Link.reportIssue)).to(equal(Links.Flexa.Link.reportIssue))
                    }
                }
            }

            context("is not a flexa.link or flexa.co url") {
                it("returns the same url") {
                    expect(subject.replaceDomain(for: Links.nonFlexa)).to(equal(Links.nonFlexa))
                }
            }
        }

        describe("getLink") {
            context("url is nil") {
                it("returns nil") {
                    expect(subject.getLink(from: nil)).to(beNil())
                }
            }

            context("url is not a flexa url (flexa.co/flexa.link)") {
                it("returns .systemBrowser with the url") {
                    expect(subject.getLink(from: Links.nonFlexa)).to(equal(FlexaLink.systemBrowser(Links.nonFlexa)))
                }
            }

            context("url is a flexa url on flexa.co") {
                context("path is account") {
                    it("returns .account") {
                        expect(subject.getLink(from: Links.Flexa.Main.account)).to(equal(.account))
                    }
                }

                context("path is account/data") {
                    it("returns .accountData") {
                        expect(subject.getLink(from: Links.Flexa.Main.accountData)).to(equal(.accountData))
                    }
                }

                context("path is account/delete") {
                    it("returns .accountData") {
                        expect(subject.getLink(from: Links.Flexa.Main.accountDeletion)).to(equal(.accountDeletion))
                    }
                }

                context("path is pay") {
                    it("returns .pay") {
                        expect(subject.getLink(from: Links.Flexa.Main.spend)).to(equal(.pay))
                    }
                }

                context("path is scan") {
                    it("returns .scan") {
                        expect(subject.getLink(from: Links.Flexa.Main.scan)).to(equal(.scan))
                    }
                }

                context("path is pinned") {
                    it("returns .pinnedBrands") {
                        expect(subject.getLink(from: Links.Flexa.Main.pinned)).to(equal(.pinnedBrands))
                    }
                }

                context("path is verify") {
                    it("returns .verify(\(Links.Flexa.Main.verify)") {
                        expect(subject.getLink(from: Links.Flexa.Main.verify)).to(equal(.verify( Links.Flexa.Main.verify)))
                    }
                }

                context("path is directory") {
                    it("returns .brandWebView(\(Links.Flexa.Main.merchants)") {
                        expect(subject.getLink(from: Links.Flexa.Main.merchants)).to(equal(.brandWebView( Links.Flexa.Main.merchants)))
                    }
                }

                context("is a payment link") {
                    it("returns .paymentLink with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Main.paymentLink)).to(equal(FlexaLink.paymentLink(Links.Flexa.Main.paymentLink)))
                    }
                }

                context("path is not any of the processable urls") {
                    it("returns .webView with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Main.reportIssue)).to(equal(.webView(Links.Flexa.Main.reportIssue)))
                    }
                }
            }

            context("url is a flexa url on flexa.link") {
                context("path is account") {
                    it("returns .account") {
                        expect(subject.getLink(from: Links.Flexa.Link.account)).to(equal(.account))
                    }
                }

                context("path is account/data") {
                    it("returns .accountData") {
                        expect(subject.getLink(from: Links.Flexa.Link.accountData)).to(equal(.accountData))
                    }
                }

                context("path is account/delete") {
                    it("returns .accountData") {
                        expect(subject.getLink(from: Links.Flexa.Link.accountDeletion)).to(equal(.accountDeletion))
                    }
                }

                context("path is pay") {
                    it("returns .pay") {
                        expect(subject.getLink(from: Links.Flexa.Link.spend)).to(equal(.pay))
                    }
                }

                context("path is scan") {
                    it("returns .scan") {
                        expect(subject.getLink(from: Links.Flexa.Link.scan)).to(equal(.scan))
                    }
                }

                context("path is pinned") {
                    it("returns .pinnedBrands") {
                        expect(subject.getLink(from: Links.Flexa.Link.pinned)).to(equal(.pinnedBrands))
                    }
                }

                context("path is verify") {
                    it("returns .verify(\(Links.Flexa.Main.verify)") {
                        expect(subject.getLink(from: Links.Flexa.Link.verify)).to(equal(.verify(Links.Flexa.Link.verify)))
                    }
                }

                context("path is directory") {
                    it("returns .brandWebView(\(Links.Flexa.Link.merchants)") {
                        expect(subject.getLink(from: Links.Flexa.Link.merchants)).to(equal(.brandWebView( Links.Flexa.Link.merchants)))
                    }
                }

                context("is a payment link") {
                    it("returns .paymentLink with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Link.paymentLink)).to(equal(FlexaLink.paymentLink(Links.Flexa.Link.paymentLink)))
                    }
                }

                context("path is not any of the processable urls") {
                    it("returns .webView with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Link.reportIssue)).to(equal(.webView(Links.Flexa.Link.reportIssue)))
                    }
                }
            }
        }
    }
}
// swiftlint:enable function_body_length force_unwrapping line_length
