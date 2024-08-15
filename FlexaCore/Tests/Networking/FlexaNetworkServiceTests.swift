//
//  FlexaNetworkServiceTests.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/2/24.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Nimble
import Quick
import Factory
import Foundation
import Fakery
import FlexaNetworking
@testable import FlexaCore

// swiftlint:disable function_body_length force_unwrapping type_body_length file_length
final class FlexaNetworkServiceTests: AsyncSpec {
    override class func spec() {
        let resource = TestAPIResource()
        var error = NetworkError.unknown
        let faker = Faker()
        var responseTuple: FlexaNetworkService.ResponseTuple<String> = (nil, nil, nil)

        describe("sendRequest(resource:)") {
            var subject: ObserveSendRequestWithResourceOnlyNetworkService!
            context("sendRequest(resource:) with tuple returns an error") {
                beforeEach {
                    subject = ObserveSendRequestWithResourceOnlyNetworkService(error: error)
                }

                it("throws the error") {
                    await expect {
                        try await subject.sendRequest(resource: resource) as String
                    }.to(throwError(error))
                }

                it("calls sendRequest(resource:) with tuple") {
                    _ = try? await subject.sendRequest(resource: resource) as String
                    expect(subject.sendRequestCalled).to(beTrue())
                }
            }

            context("sendRequest(resource:) with tuple does not return an error") {
                context("sendRequest(resource:) with tuple returns a nil object") {
                    beforeEach {
                        subject = ObserveSendRequestWithResourceOnlyNetworkService()
                    }

                    it("throws a Network.decode error") {
                        await expect {
                            try await subject.sendRequest(resource: resource) as String
                        }.to(throwError(NetworkError.decode(nil)))
                    }

                    it("calls sendRequest(resource:) with tuple") {
                        _ = try? await subject.sendRequest(resource: resource) as String
                        expect(subject.sendRequestCalled).to(beTrue())
                    }

                }
                context("sendRequest(resource:) with tuple returns an object") {
                    var object = faker.lorem.characters(amount: 10)
                    beforeEach {
                        subject = ObserveSendRequestWithResourceOnlyNetworkService(object: object)
                    }

                    it("does not throw an error error") {
                        await expect {
                            try await subject.sendRequest(resource: resource) as String
                        }.notTo(throwError())
                    }

                    it("returns the expected object") {
                        var resultObject = try? await subject.sendRequest(resource: resource) as String
                        expect(resultObject).to(equal(object))
                    }

                    it("calls sendRequest(resource:) with tuple") {
                        _ = try? await subject.sendRequest(resource: resource) as String
                        expect(subject.sendRequestCalled).to(beTrue())
                    }
                }
            }
        }

        describe("sendRequest(resource:refreshTokenOnFailure:") {
            Container.shared.networkClient.register { MockNetworkService() }
            beforeEach {
                responseTuple = (nil, nil, nil)
                error = .unknown
            }

            context("token is already expired") {
                beforeEach {
                    Container.shared.authStore.register { TestAuthStore(token: .expiredToken) }.singleton
                }

                context("token is refreshed successfully before sending the request") {
                    context("network client returns a successfull response") {
                        let response = HTTPURLResponse(
                            url: URL(string: faker.internet.url())!,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )
                        let object = faker.lorem.characters(amount: 10)

                        beforeEach {
                            Container.shared.networkClient.register {
                                MockNetworkService(object: object, response: response)
                            }
                            let subject = FlexaNetworkService()
                            responseTuple = await subject.sendRequest(resource: resource)
                        }

                        it("calls AuthStore.refreshToken") {
                            expect((Container.shared.authStore() as? TestAuthStore)?.refreshTokenCalled).to(beTrue())
                        }

                        it("retruns the response's object") {
                            expect(responseTuple.0).to(equal(object))
                        }

                        it("returns the HTTPURLResponse") {
                            expect(responseTuple.1).to(equal(response))
                        }

                        it("returns a nil error") {
                            expect(responseTuple.2).to(beNil())
                        }
                    }

                    context("network client returns an error") {
                        var subject: ObserveRefreshAndRetryNetworkService!
                        beforeEach {
                            Container.shared.networkClient.register {
                                MockNetworkService(error: error)
                            }
                        }

                        context("refreshTokenOnFailure is true") {
                            beforeEach {
                                subject = ObserveRefreshAndRetryNetworkService()
                                responseTuple = await subject.sendRequest(resource: resource)
                            }

                            it("calls refreshAndRetry(resource:error:)") {
                                expect(subject.refreshAndRetryCalled).to(beTrue())
                            }

                            it("calls refreshAndRetry(resource:error:) with the original resource") {
                                expect(subject.resource as? TestAPIResource).to(equal(resource))
                            }

                            it("calls refreshAndRetry(resource:error:) with the original error") {
                                expect(subject.error as? NetworkError).to(equal(error))
                            }
                        }

                        context("refreshTokenOnFailure is false") {
                            beforeEach {
                                subject = ObserveRefreshAndRetryNetworkService()
                                responseTuple = await subject.sendRequest(resource: resource, refreshTokenOnFailure: false)
                            }

                            it("calls refreshAndRetry") {
                                expect(subject.refreshAndRetryCalled).to(beNil())
                            }

                            it("returns a nil object") {
                                expect(responseTuple.0).to(beNil())
                            }

                            it("returns a nil HTTPURLResponse") {
                                expect(responseTuple.1).to(beNil())
                            }

                            it("returns the original error") {
                                expect(responseTuple.2 as? NetworkError).to(equal(error))
                            }
                        }
                    }
                }

                context("token refresh fails before sending the request") {
                    context("network client returns an error") {
                        var subject: ObserveRefreshAndRetryNetworkService!
                        beforeEach {
                            Container.shared.networkClient.register {
                                MockNetworkService(error: error)
                            }
                        }

                        context("refreshTokenOnFailure is true") {
                            beforeEach {
                                subject = ObserveRefreshAndRetryNetworkService()
                                responseTuple = await subject.sendRequest(resource: resource)
                            }

                            it("calls refreshAndRetry(resource:error:)") {
                                expect(subject.refreshAndRetryCalled).to(beTrue())
                            }

                            it("calls refreshAndRetry(resource:error:) with the original resource") {
                                expect(subject.resource as? TestAPIResource).to(equal(resource))
                            }

                            it("calls refreshAndRetry(resource:error:) with the original error") {
                                expect(subject.error as? NetworkError).to(equal(error))
                            }
                        }

                        context("refreshTokenOnFailure is false") {
                            beforeEach {
                                subject = ObserveRefreshAndRetryNetworkService()
                                responseTuple = await subject.sendRequest(resource: resource, refreshTokenOnFailure: false)
                            }

                            it("does not call refreshAndRetry") {
                                expect(subject.refreshAndRetryCalled).to(beNil())
                            }

                            it("returns a nil object") {
                                expect(responseTuple.0).to(beNil())
                            }

                            it("returns a nil HTTPURLResponse") {
                                expect(responseTuple.1).to(beNil())
                            }

                            it("returns the original error") {
                                expect(responseTuple.2 as? NetworkError).to(equal(error))
                            }
                        }
                    }
                }
            }

            context("token is not expired") {
                beforeEach {
                    Container.shared.authStore.register { TestAuthStore() }
                }

                context("network client returns a successfull response") {
                    let response = HTTPURLResponse(
                        url: URL(string: faker.internet.url())!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )
                    let object = faker.lorem.characters(amount: 10)
                    var subject: FlexaNetworkService!

                    beforeEach {
                        Container.shared.networkClient.register {
                            MockNetworkService(object: object, response: response)
                        }

                        subject = FlexaNetworkService()
                        responseTuple = await subject.sendRequest(resource: resource)
                    }

                    it("retruns the response's object") {
                        expect(responseTuple.0).to(equal(object))
                    }

                    it("returns the HTTPURLResponse") {
                        expect(responseTuple.1).to(equal(response))
                    }

                    it("returns a nil error") {
                        expect(responseTuple.2).to(beNil())
                    }
                }

                context("network client returns an error") {
                    var subject: ObserveRefreshAndRetryNetworkService!
                    beforeEach {
                        Container.shared.networkClient.register {
                            MockNetworkService(error: error)
                        }
                    }

                    context("refreshTokenOnFailure is true") {
                        beforeEach {
                            subject = ObserveRefreshAndRetryNetworkService()
                            responseTuple = await subject.sendRequest(resource: resource, refreshTokenOnFailure: true)
                        }

                        it("calls refreshAndRetry(resource:error:)") {
                            expect(subject.refreshAndRetryCalled).to(beTrue())
                        }

                        it("calls refreshAndRetry(resource:error:) with the original resource") {
                            expect(subject.resource as? TestAPIResource).to(equal(resource))
                        }

                        it("calls refreshAndRetry(resource:error:) with the original error") {
                            expect(subject.error as? NetworkError).to(equal(error))
                        }
                    }

                    context("refreshTokenOnFailure is false") {
                        beforeEach {
                            subject = ObserveRefreshAndRetryNetworkService()
                            responseTuple = await subject.sendRequest(resource: resource, refreshTokenOnFailure: false)
                        }

                        it("does not call refreshAndRetry") {
                            expect(subject.refreshAndRetryCalled).to(beNil())
                        }

                        it("returns a nil object") {
                            expect(responseTuple.0).to(beNil())
                        }

                        it("returns a nil HTTPURLResponse") {
                            expect(responseTuple.1).to(beNil())
                        }

                        it("returns the original error") {
                            expect(responseTuple.2 as? NetworkError).to(equal(error))
                        }
                    }
                }
            }
        }

        describe("refreshAndRetry(resource:error:)") {
            var subject: ObserveRefreshTokenAndSendRequestNetworkService!
            beforeEach {
                Container.shared.networkClient.register { MockNetworkService() }
            }

            context("token exists") {
                context("token is not expired") {
                    beforeEach {
                        Container.shared.authStore.register { TestAuthStore() }
                    }

                    context("error is meant to retry the request") {
                        beforeEach {
                            subject = ObserveRefreshTokenAndSendRequestNetworkService()
                            error = NetworkError.unauthorizedError(for: resource)
                            responseTuple = await subject.refreshAndRetry(resource: resource, error: error)
                        }

                        it("calls refreshTokenAndSendRequest(resource:error:)") {
                            expect(subject.refreshTokenAndSendRequestCalled).to(beTrue())
                        }

                        it("calls refreshTokenAndSendRequest(resource:error:) with the original resource") {
                            expect(subject.resource as? TestAPIResource).to(equal(resource))
                        }

                        it("calls refreshTokenAndSendRequest(resource:error:) with the original error") {
                            expect(subject.error as? NetworkError).to(equal(error))
                        }
                    }

                    context("error is not meant to retry the request") {
                        beforeEach {
                            subject = ObserveRefreshTokenAndSendRequestNetworkService()
                            error = .unknown
                            responseTuple = await subject.refreshAndRetry(resource: resource, error: error)
                        }

                        it("does not call refreshTokenAndSendRequest") {
                            expect(subject.refreshTokenAndSendRequestCalled).to(beNil())
                        }

                        it("returns a nil object") {
                            expect(responseTuple.0).to(beNil())
                        }

                        it("returns a nil HTTPURLResponse") {
                            expect(responseTuple.1).to(beNil())
                        }

                        it("returns the original error") {
                            expect(responseTuple.2 as? NetworkError).to(equal(error))
                        }
                    }
                }

                context("token is expired") {
                    beforeEach {
                        Container.shared.authStore.register { TestAuthStore(token: .expiredToken) }
                        subject = ObserveRefreshTokenAndSendRequestNetworkService()
                        responseTuple = await subject.refreshAndRetry(resource: resource, error: error)
                    }

                    it("calls refreshTokenAndSendRequest(resource:error:)") {
                        expect(subject.refreshTokenAndSendRequestCalled).to(beTrue())
                    }

                    it("calls refreshTokenAndSendRequest(resource:error:) with the original resource") {
                        expect(subject.resource as? TestAPIResource).to(equal(resource))
                    }

                    it("calls refreshTokenAndSendRequest(resource:error:) with the original error") {
                        expect(subject.error as? NetworkError).to(equal(error))
                    }
                }
            }

            context("token does not exist") {
                beforeEach {
                    Container.shared.authStore.register { TestAuthStore(token: nil) }
                    subject = ObserveRefreshTokenAndSendRequestNetworkService()
                }
                context("error is meant to retry the request") {
                    beforeEach {
                        error = NetworkError.unauthorizedError(for: resource)
                        responseTuple = await subject.refreshAndRetry(resource: resource, error: error)
                    }

                    it("calls refreshTokenAndSendRequest(resource:error:)") {
                        expect(subject.refreshTokenAndSendRequestCalled).to(beTrue())
                    }

                    it("calls refreshTokenAndSendRequest(resource:error:) with the original resource") {
                        expect(subject.resource as? TestAPIResource).to(equal(resource))
                    }

                    it("calls refreshTokenAndSendRequest(resource:error:) with the original error") {
                        expect(subject.error as? NetworkError).to(equal(error))
                    }
                }

                context("error is not meant to retry the request") {
                    beforeEach {
                        error = .unknown
                        responseTuple = await subject.refreshAndRetry(resource: resource, error: error)
                    }

                    it("does not call refreshTokenAndSendRequest") {
                        expect(subject.refreshTokenAndSendRequestCalled).to(beNil())
                    }

                    it("returns a nil object") {
                        expect(responseTuple.0).to(beNil())
                    }

                    it("returns a nil HTTPURLResponse") {
                        expect(responseTuple.1).to(beNil())
                    }

                    it("returns the original error") {
                        expect(responseTuple.2 as? NetworkError).to(equal(error))
                    }
                }
            }
        }

        describe("refreshTokenAndSendRequest(resource:error:)") {
            var subject: ObserveSendRequestNetworkService!
            beforeEach {
                Container.shared.networkClient.register { MockNetworkService() }
            }

            context("user is logged in") {
                beforeEach {
                    Container.shared.authStore.register { TestAuthStore() }.singleton
                    subject = ObserveSendRequestNetworkService()
                    responseTuple = await subject.refreshTokenAndSendRequest(resource: resource, error: error)
                }

                it("calls AuthStore.refreshToken") {
                    let authStore = Container.shared.authStore() as? TestAuthStore
                    expect(authStore?.refreshTokenCalled).to(beTrue())
                }

                it("calls sendRequest(resource:refreshTokenOnFailure:") {
                    expect(subject.sendRequestCalled).to(beTrue())
                }

                it("calls sendRequest(resource:refreshTokenOnFailure: with the original resource") {
                    expect(subject.resource as? TestAPIResource).to(equal(resource))
                }

                it("calls  sendRequest(resource:refreshTokenOnFailure: with refreshTokenOnFailure as false") {
                    expect(subject.refreshTokenOnFailure).to(beFalse())
                }
            }

            context("user is not logged in (token cannot refreshed)") {
                beforeEach {
                    Container.shared.authStore.register { TestAuthStore(token: .expiredToken, state: .none) }
                    subject = ObserveSendRequestNetworkService()
                    responseTuple = await subject.refreshTokenAndSendRequest(resource: resource, error: error)
                }

                it("calls AuthStore.refreshToken") {
                    let authStore = Container.shared.authStore() as? TestAuthStore
                    expect(authStore?.refreshTokenCalled).to(beTrue())
                }

                it("returns a nil object") {
                    expect(responseTuple.0).to(beNil())
                }

                it("returns a nil HTTPURLResponse") {
                    expect(responseTuple.1).to(beNil())
                }

                it("returns an Unauthorized error") {
                   expect(responseTuple.2 as? NetworkError).to(equal(NetworkError.unauthorizedError(for: resource)))
                }
            }
        }
    }
}

// MARK: - Mocks and test helpers

private extension Models.Token {
    static var expiredToken: Self? {
        let seconds = Date().addingTimeInterval(-1).timeIntervalSince1970
        let expiresAt = Int(exactly: seconds.rounded(.toNearestOrEven)) ?? 0
        return Models.Token(
            id: UUID().uuidString,
            statusString: Models.Token.Status.expired.rawValue,
            value: UUID().uuidString,
            expiresAt: expiresAt
        )
    }

    static var nonExpiredToken: Self? {
        let seconds = Date().addingTimeInterval(3600).timeIntervalSince1970
        let expiresAt = Int(exactly: seconds.rounded(.toNearestOrEven)) ?? 0
        return Models.Token(
            id: UUID().uuidString,
            statusString: Models.Token.Status.active.rawValue,
            value: UUID().uuidString,
            expiresAt: expiresAt
        )
    }
}

private struct TestAPIResource: APIResource, Equatable {
}

private class TestAuthStore: AuthStoreProtocol {
    var email: String?
    var token: Models.Token?
    var state: AuthStoreState
    var refreshTokenCalled = false

    var isSignedIn: Bool {
        state == .loggedIn
    }

    init(token: Models.Token? = .nonExpiredToken, state: AuthStoreState = .loggedIn) {
        self.token = token
        self.state = state
    }

    func signIn(with email: String) async throws -> AuthStoreState {
        state
    }

    func verify(code: String?, link: String?) async throws -> AuthStoreState {
        state
    }

    func refreshToken() async throws -> AuthStoreState {
        refreshTokenCalled = true
        return state
    }

    func signOut() {

    }

    func purgeIfNeeded() {

    }
}

private struct MockNetworkService: Networkable {
    var object: Decodable?
    var response: HTTPURLResponse?
    var error: Error?

    func sendRequest(resource: any FlexaNetworking.APIResource) async throws {
        let (_, _, error) = await sendRequest(resource: resource) as (Data?, HTTPURLResponse?, Error?)

        if let error {
            throw error
        }
    }

    func sendRequest<T>(resource: APIResource) async throws -> T where T: Decodable {
        if let error {
            throw error
        }
        if let object = object as? T {
            return object
        }

        throw NetworkError.decode(nil)
    }

    func sendRequest<T>(resource: APIResource) async -> FlexaNetworkService.ResponseTuple<T> {
        return (object as? T, response, error)
    }
}

private class ObserveSendRequestNetworkService: FlexaNetworkService {
    var sendRequestCalled: Bool?
    var resource: APIResource?
    var refreshTokenOnFailure: Bool?

    override func sendRequest<T>(resource: APIResource,
                                 refreshTokenOnFailure: Bool
    ) async -> FlexaNetworkService.ResponseTuple<T> where T: Decodable {

        self.sendRequestCalled = true
        self.resource = resource
        self.refreshTokenOnFailure = refreshTokenOnFailure
        return (nil, nil, nil)
    }
}

private class ObserveRefreshTokenAndSendRequestNetworkService: FlexaNetworkService {
    var refreshTokenAndSendRequestCalled: Bool?
    var resource: APIResource?
    var error: Error?

    override func refreshTokenAndSendRequest<T>(resource: APIResource,
                                                error: Error
    ) async -> FlexaNetworkService.ResponseTuple<T> where T: Decodable {

        self.refreshTokenAndSendRequestCalled = true
        self.resource = resource
        self.error = error

        return (nil, nil, nil)
    }
}

private class ObserveRefreshAndRetryNetworkService: FlexaNetworkService {
    var refreshAndRetryCalled: Bool?
    var resource: APIResource?
    var error: Error?

    override func refreshAndRetry<T>(resource: APIResource,
                                     error: Error
    ) async -> FlexaNetworkService.ResponseTuple<T> where T: Decodable {
        self.refreshAndRetryCalled = true
        self.resource = resource
        self.error = error

        return (nil, nil, nil)
    }
}

private class ObserveSendRequestWithResourceOnlyNetworkService: FlexaNetworkService {
    var object: Decodable?
    var response: HTTPURLResponse?
    var error: Error?
    var sendRequestCalled: Bool?

    init(object: Decodable? = nil,
         response: HTTPURLResponse? = nil,
         error: Error? = nil) {
        self.object = object
        self.response = response
        self.error = error
    }

    override func sendRequest<T>(resource: APIResource) async -> FlexaNetworkService.ResponseTuple<T> where T: Decodable {
        self.sendRequestCalled = true
        return (object as? T, response, error)
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: FlexaNetworking.NetworkError, rhs: FlexaNetworking.NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case(.invalidStatus(let lhsStatus, _), .invalidStatus(let rhsStatus, _)):
            return lhsStatus == rhsStatus
        case(.decode(let lhsError), .decode(let rhsError)):
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        default:
            return false
        }
    }
}
// swiftlint:enable function_body_length force_unwrapping type_body_length file_length
