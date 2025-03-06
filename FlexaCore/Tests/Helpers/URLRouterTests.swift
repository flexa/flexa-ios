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
                static let payment = URL(string: "https://pay.flexa.co")!
            }

            struct Link {
                static let guides = URL(string: "https://flexa.link/guides/how-to-pay")!
                static let explore = URL(string: "https://flexa.link/explore/how-to-pay")!
                static let reportIssue = URL(string: "https://flexa.link/report-issue")!
                static let account = URL(string: "https://flexa.link/account")!
                static let payment = URL(string: "https://pay.flexa.link")!
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

            context("url is a flexa url (flexa.co/flexa.link)") {
                context("path is account") {
                    it("returns .account") {
                        expect(subject.getLink(from: Links.Flexa.Main.account)).to(equal(.account))
                    }
                }

                context("is a payment link on flexa.co") {
                    it("returns .paymentLink with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Main.payment)).to(equal(FlexaLink.paymentLink(Links.Flexa.Main.payment)))
                    }
                }

                context("is a payment link on flexa.link") {
                    it("returns .paymentLink with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Link.payment)).to(equal(FlexaLink.paymentLink(Links.Flexa.Link.payment)))
                    }
                }

                context("path is not account and is not a paymentLink") {
                    it("returns .webView with the same url") {
                        expect(subject.getLink(from: Links.Flexa.Main.reportIssue)).to(equal(.webView(Links.Flexa.Main.reportIssue)))
                    }
                }
            }
        }
    }
}
// swiftlint:enable function_body_length force_unwrapping line_length
