//
//  APIResourceTests.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 01/26/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Fakery
import WebKit
@testable import FlexaNetworking

// swiftlint:disable function_body_length line_length
final class APIResourceTests: QuickSpec {
    static let path = "api"
    static let authHeader = "Basic \(Data("publishable_key_value".utf8).base64EncodedString())"
    static let headers = ["header1": "value1"]
    static let authHeaderDict = ["Authorization": authHeader]
    static let defaultHeadersDict = ["Content-Type": "application/json"]

    static var headersPlusAuthHeader: [String: String] = {
        authHeaderDict.merging(headers) { (current, _) in current }
    }()

    static var defaultHeadersPlusAuthHeader: [String: String] = {
        authHeaderDict.merging(defaultHeadersDict) { (current, _) in current }
    }()

    static var allHeaders: [String: String] = {
        headersPlusAuthHeader
            .merging(defaultHeadersDict) { (current, _) in current }
    }()

    static var headersPlusDefaultHeaders: [String: String] = {
        defaultHeadersDict.merging(headers) { (current, _) in current }
    }()

    override class func spec() {
        describe("default properties") {
            let resource = DefaultTestAPIResource()

            describe("scheme") {
                it("is https") {
                    expect(resource.scheme).to(equal("https"))
                }
            }

            describe("host") {
                it("is empty") {
                    expect(resource.host).to(beEmpty())
                }
            }

            describe("path") {
                it("is empty") {
                    expect(resource.path).to(beEmpty())
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

            describe("defaultHeaders") {
                it("is nil") {
                    expect(resource.defaultHeaders).to(beNil())
                }
            }

            describe("queryParams") {
                it("is nil") {
                    expect(resource.queryParams).to(beNil())
                }
            }

            describe("queryItems") {
                it("is nil") {
                    expect(resource.queryItems).to(beNil())
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

            describe("authHeader") {
                it("is nil") {
                    expect(resource.authHeader).to(beNil())
                }
            }
        }

        describe("request") {
            context("Valid fields") {
                let resource = TestAPIResource()
                let request = resource.request

                it("it's not nil") {
                    expect(request).notTo(beNil())
                }

                it("sets http method") {
                    expect(request?.httpMethod?.lowercased()).to(equal(resource.method.rawValue.lowercased()))
                }

                context("with nil headers") {
                    context("with nil default headers") {
                        context("without authHeader") {
                            it("has an empty set of headers") {
                                expect(request?.allHTTPHeaderFields).to(beEmpty())
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader)
                            let request = resource.request
                            it("has the authorization header only") {
                                expect(request?.allHTTPHeaderFields).to(equal(authHeaderDict))
                            }

                        }
                    }

                    context("with empty default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(defaultHeaders: [:])
                            let request = resource.request
                            it("has an empty set of headers") {
                                expect(request?.allHTTPHeaderFields).to(beEmpty())
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, defaultHeaders: [:])
                            let request = resource.request
                            it("has the authorization header only") {
                                expect(request?.allHTTPHeaderFields).to(equal(authHeaderDict))
                            }

                        }
                    }

                    context("with default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(defaultHeaders: defaultHeadersDict)
                            let request = resource.request
                            it("has the default headers only") {
                                expect(request?.allHTTPHeaderFields).to(equal(defaultHeadersDict))
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, defaultHeaders: defaultHeadersDict)
                            let request = resource.request
                            it("has the authorization header only") {
                                expect(request?.allHTTPHeaderFields).to(equal(defaultHeadersPlusAuthHeader))
                            }

                        }
                    }
                }

                context("with empty headers") {
                    context("with nil default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(headers: [:])
                            let request = resource.request

                            it("has an empty set of headers") {
                                expect(request?.allHTTPHeaderFields).to(beEmpty())
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, headers: [:])
                            let request = resource.request

                            it("has the authorization header only") {
                                expect(request?.allHTTPHeaderFields).to(equal(authHeaderDict))
                            }
                        }
                    }

                    context("with empty default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(headers: [:], defaultHeaders: [:])
                            let request = resource.request

                            it("has an empty set of headers") {
                                expect(request?.allHTTPHeaderFields).to(beEmpty())
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, headers: [:], defaultHeaders: [:])
                            let request = resource.request

                            it("has the authorization header only") {
                                expect(request?.allHTTPHeaderFields).to(equal(authHeaderDict))
                            }
                        }
                    }

                    context("with default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(headers: [:], defaultHeaders: defaultHeadersDict)
                            let request = resource.request

                            it("has the default headers") {
                                expect(request?.allHTTPHeaderFields).to(equal(defaultHeadersDict))
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, headers: [:], defaultHeaders: defaultHeadersDict)
                            let request = resource.request

                            it("has the authorization plus the default headers") {
                                expect(request?.allHTTPHeaderFields).to(equal(defaultHeadersPlusAuthHeader))
                            }
                        }
                    }
                }

                context("with headers") {
                    context("with nil default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(headers: headers)
                            let request = resource.request
                            it("has the specified headers only") {
                                expect(request?.allHTTPHeaderFields).to(equal(headers))
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, headers: headers)
                            let request = resource.request
                            it("has the authorization header pluse the specified headers") {
                                expect(request?.allHTTPHeaderFields).to(equal(headersPlusAuthHeader))
                            }
                        }
                    }

                    context("with empty default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(headers: headers, defaultHeaders: [:])
                            let request = resource.request
                            it("has the specified headers only") {
                                expect(request?.allHTTPHeaderFields).to(equal(headers))
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, headers: headers, defaultHeaders: [:])
                            let request = resource.request
                            it("has the authorization header pluse the specified headers") {
                                expect(request?.allHTTPHeaderFields).to(equal(headersPlusAuthHeader))
                            }
                        }
                    }

                    context("with default headers") {
                        context("without authHeader") {
                            let resource = TestAPIResource(headers: headers, defaultHeaders: defaultHeadersDict)
                            let request = resource.request
                            it("has the specified headers plus the default headers") {
                                expect(request?.allHTTPHeaderFields).to(equal(headersPlusDefaultHeaders))
                            }
                        }

                        context("with authHeader") {
                            let resource = TestAPIResource(authHeader: authHeader, headers: headers, defaultHeaders: defaultHeadersDict)
                            let request = resource.request

                            it("has the auth header, plus the specified headers, plus the default headers") {
                                expect(request?.allHTTPHeaderFields).to(equal(allHeaders))
                            }
                        }
                    }
                }

                context("with nil path parameters") {
                    let expectedUrl = "\(resource.scheme)://\(resource.host)/\(resource.path)"
                    it("has an URL matching the domain + path") {
                        expect(request?.url?.absoluteString).to(equal(expectedUrl))
                    }
                }

                context("with empty path parameters") {
                    let expectedUrl = "\(resource.scheme)://\(resource.host)/\(resource.path)"
                    it("has an URL matching the domain + path") {
                        expect(request?.url?.absoluteString).to(equal(expectedUrl))
                    }
                }

                context("with path parameters") {
                    let params = [":param1": "1", ":param2": "2"]
                    let path = "api/resource1/:param1/resource2/:param2"
                    let resource = TestAPIResource(path: path, pathParams: params)
                    let request = resource.request
                    let expectedUrl = "\(resource.scheme)://\(resource.host)/api/resource1/1/resource2/2"

                    it("replaces the parameters on the url") {
                        expect(request?.url?.absoluteString).to(equal(expectedUrl))
                    }
                }

                context("with nil query parameters") {
                    let expectedUrl = "\(resource.scheme)://\(resource.host)/\(resource.path)"
                    it("has an URL matching the domain + path") {
                        expect(request?.url?.absoluteString).to(equal(expectedUrl))
                    }
                }

                context("with empty query parameters") {
                    let expectedUrl = "\(resource.scheme)://\(resource.host)/\(resource.path)"
                    it("has an URL matching the domain + path") {
                        expect(request?.url?.absoluteString).to(equal(expectedUrl))
                    }
                }

                context("with query parameters") {
                    let params = ["param1": "1"]
                    let resource = TestAPIResource(path: path, queryParams: params)
                    let request = resource.request
                    let expectedUrl = "\(resource.scheme)://\(resource.host)/\(resource.path)?param1=1"

                    it("it appends the query parameters to the url") {
                        expect(request?.url?.absoluteString).to(equal(expectedUrl))
                    }
                }

                context("with nil body parameters") {
                    it("has a nil httpBody") {
                        expect(request?.httpBody).to(beNil())
                    }
                }

                context("with with empty body parameters") {
                    let resource = TestAPIResource(bodyParams: [:])
                    let request = resource.request
                    it("has an empty dictionary encoded on httpBody") {
                        expect(String(data: request!.httpBody!, encoding: .utf8)).to(equal("{}")) // swiftlint:disable:this force_unwrapping
                    }
                }

                context("with body parameters") {
                    let model = TestAPIModel(name: Faker().name.firstName())
                    let data = try? JSONEncoder().encode(model)
                    let dict = (try? JSONSerialization.jsonObject(with: data!) as? [String: String])! // swiftlint:disable:this force_unwrapping

                    let resource = TestAPIResource(bodyParams: dict)
                    let request = resource.request
                    it("sets the encoded object into httpBody") {
                        expect(request?.httpBody).to(equal(data))
                    }
                }
            }

            context("Invalid fields") {
                // We are not testing URLComponents, we just need componenets to return a nil url
                let resource = TestAPIResource(host: "inavalid%host", path: "/invalid path")
                let request = resource.request
                it("is nil") {
                    expect(request).to(beNil())
                }
            }
        }

        describe("queryItems") {
            context("With nil query parameters") {
                let resource = TestAPIResource()
                it("is nil") {
                    expect(resource.queryItems).to(beNil())
                }
            }

            context("With empty query parameters") {
                let resource = TestAPIResource(queryParams: [:])
                it("is empty") {
                    expect(resource.queryItems).to(beEmpty())
                }
            }

            context("With query parameters") {
                let params = [":param1": "1", ":param2": "2"]
                let resource = TestAPIResource(queryParams: params)
                it("it matches the input query paramters") {
                    expect(resource.queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value }).to(equal(params))
                }
            }
        }
    }
}

// swiftlint:enable function_body_length line_length
