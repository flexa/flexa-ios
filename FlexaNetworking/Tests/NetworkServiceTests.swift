//
//  NetworkServiceTests.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 03/04/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Nimble
import Quick
import Fakery
import WebKit
import Factory
import XCTest
@testable import FlexaNetworking

final class NetworkServiceTests: AsyncSpec {
    private class func buildService<T: MockURLResponder>(
        host: String = "host.com",
        path: String = "/path",
        responderType: T.Type) -> (any APIResource, NetworkService) {
            let mockUrlSession = URLSession(mockResponder: responderType)
            Container.shared.urlSession.register { mockUrlSession }
            return (TestAPIResource(host: host, path: path), NetworkService())
        }

    override class func spec() {

        describe("sendRequest async") {
            context("invalid request") {
                let (resource, service) = buildService(
                    host: "inavalid%host",
                    path: "/invalid path",
                    responderType: TestAPIModel.SuccessResponder.self
                )

                it("throws invalidRequest error") {
                    await expect {
                         try await service.sendRequest(resource: resource) as TestAPIModel
                    }.to(throwError(NetworkError.invalidRequest))
                }
            }

            context("dataTask sends an error back") {
                let (resource, service) = buildService(responderType: TestAPIModel.ErrorResponder.self)

                it("throws the same error") {
                    await expect {
                        try await service.sendRequest(resource: resource) as TestAPIModel
                    }.to(throwError(NetworkError.unknown(nil)))
                }
            }

            context("dataTask urlResponse is not a HTTPURLResponse") {
                let (resource, service) = buildService(responderType: TestAPIModel.InvalidResponseResponder.self)

                it("throws invalidResponse error") {
                    await expect {
                        try await service.sendRequest(resource: resource) as TestAPIModel
                    }.to(throwError(NetworkError.invalidResponse(nil)))
                }
            }

            context("response is not successul") {
                let (resource, service) = buildService(responderType: TestAPIModel.InvalidResponseStatusResponder.self)

                it("throws invalidStatus error") {
                    await expect {
                        try await service.sendRequest(resource: resource) as TestAPIModel
                    }.to(throwError(NetworkError.invalidStatus(status: 300, resource: resource, request: nil, data: nil)))
                }
            }

            context("undecodable object") {
                let (resource, service) = buildService(responderType: TestAPIModel.DecodeErrorResponder.self)

                it("throws a decode error") {
                    await expect {
                        try await service.sendRequest(resource: resource) as TestAPIModel
                    }.to(throwError(NetworkError.decode(nil)))
                }
            }

            context("successfull request (happy path)") {
                let (resource, service) = buildService(responderType: TestAPIModel.SuccessResponder.self)

                it("decodes the object successfully") {
                    let object = try await service.sendRequest(resource: resource) as TestAPIModel
                    expect(object.name).to(equal(TestAPIModel.SuccessResponder.model.name))
                }
            }
        }
    }
}

extension TestAPIModel {
    enum SuccessResponder: MockURLResponder {
        static let model = TestAPIModel(name: Faker().name.name())

        static func respond(to request: URLRequest) throws -> (Data?, URLResponse?) {
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            return (try JSONEncoder().encode(model), response)
        }
    }

    enum InvalidResponseStatusResponder: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, URLResponse?) {
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 404,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            return (Data(), response)
        }
    }

    enum InvalidResponseResponder: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, URLResponse?) {
            return (nil,
                    URLResponse(
                        url: try XCTUnwrap(request.url),
                        mimeType: nil,
                        expectedContentLength: 0,
                        textEncodingName: nil
                    )
            )
        }
    }

    enum ErrorResponder: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, URLResponse?) {
            throw NetworkError.unknown(nil)
        }
    }

    enum DecodeErrorResponder: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, URLResponse?) {
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            return (try JSONEncoder().encode("invalid data"), response)
        }
    }
}
