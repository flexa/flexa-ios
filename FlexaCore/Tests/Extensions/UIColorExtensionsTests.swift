//
//  UIColorExtensionsTests.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 20/02/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import UIKit
@testable import FlexaCore

// swiftlint:disable function_body_length
class UIColorExtensionsSpec: QuickSpec {
    override class func spec() {
        describe("init(hex:)") {
            context("valid hex string") {
                context("large hex without alpha") {
                    it("should create an UIColor with correct components") {
                        let rgba = UIColor(hex: "#FFBF7F")?.rgba
                        expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                        expect(rgba?.green).to(beCloseTo(0.75, within: 0.01))
                        expect(rgba?.blue).to(beCloseTo(0.5, within: 0.01))
                        expect(rgba?.alpha).to(beCloseTo(1, within: 0.01))
                    }
                }

                context("large hex with alpha") {
                    it("should create an UIColor with correct components") {
                        let rgba = UIColor(hex: "#3FFFBF7F")?.rgba
                        expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                        expect(rgba?.green).to(beCloseTo(0.75, within: 0.01))
                        expect(rgba?.blue).to(beCloseTo(0.5, within: 0.01))
                        expect(rgba?.alpha).to(beCloseTo(0.25, within: 0.01))
                    }
                }

                context("short hex without alpha") {
                    it("should create an UIColor with correct components") {
                        let rgba = UIColor(hex: "#F08")?.rgba
                        expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                        expect(rgba?.green).to(beCloseTo(0, within: 0.01))
                        expect(rgba?.blue).to(beCloseTo(0.53, within: 0.01))
                        expect(rgba?.alpha).to(beCloseTo(1, within: 0.01))
                    }
                }

                context("short hex with alpha") {
                    it("should create an UIColor with correct components") {
                        let rgba = UIColor(hex: "#AF08")?.rgba
                        expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                        expect(rgba?.green).to(beCloseTo(0, within: 0.01))
                        expect(rgba?.blue).to(beCloseTo(0.53, within: 0.01))
                        expect(rgba?.alpha).to(beCloseTo(0.66, within: 0.01))
                    }
                }
            }

            context("invalid hex string") {
                it("should return nil") {
                    expect(UIColor(hex: "invalid hex value")).to(beNil())
                }
            }

            context("invalid hex value") {
                it("should return nil") {
                    expect(UIColor(hex: "#GG0000")).to(beNil())
                }
            }
        }

        describe("init(rgba:)") {
            context("valid rgba string") {
                it("should create an UIColor with correct components") {
                    let rgba = UIColor(rgba: "rgba(255,51,85,0.5)")?.rgba
                    expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                    expect(rgba?.green).to(beCloseTo(0.2, within: 0.01))
                    expect(rgba?.blue).to(beCloseTo(0.33, within: 0.01))
                    expect(rgba?.alpha).to(beCloseTo(0.5, within: 0.01))
                }
            }

            context("invalid rgba string") {
                it("should return nil") {
                    expect(UIColor(rgba: "invalid rgba value")).to(beNil())
                }
            }
        }

        describe("init(string:)") {
            context("valid hex string") {
                it("should create an UIColor with correct components") {
                    let rgba = UIColor(string: "#F08")?.rgba
                    expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                    expect(rgba?.green).to(beCloseTo(0, within: 0.01))
                    expect(rgba?.blue).to(beCloseTo(0.53, within: 0.01))
                    expect(rgba?.alpha).to(beCloseTo(1, within: 0.01))
                }
            }

            context("valid rgba string") {
                it("should create an UIColor with correct components") {
                    let rgba = UIColor(string: "rgba(255,51,85,0.5)")?.rgba
                    expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                    expect(rgba?.green).to(beCloseTo(0.2, within: 0.01))
                    expect(rgba?.blue).to(beCloseTo(0.33, within: 0.01))
                    expect(rgba?.alpha).to(beCloseTo(0.5, within: 0.01))
                }
            }

            context("valid system color name") {
                it("should create an UIColor with correct components") {
                    let rgba = UIColor(string: "lightText")?.rgba
                    expect(rgba?.red).to(beCloseTo(1, within: 0.01))
                    expect(rgba?.green).to(beCloseTo(1, within: 0.01))
                    expect(rgba?.blue).to(beCloseTo(1, within: 0.01))
                    expect(rgba?.alpha).to(beCloseTo(0.6, within: 0.01))
                }
            }

            context("invalid hex, rgba and system color name string") {
                it("should return nil") {
                    expect(UIColor(string: "invalid string value")).to(beNil())
                }
            }
        }
    }
}

private extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
// swiftlint:enable function_body_length
