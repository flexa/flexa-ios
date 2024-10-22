//
//  SSEClientTests.swift
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

// swiftlint:disable force_unwrapping function_body_length
final class SSEClientTests: QuickSpec {
    static let faker = Faker()

    override class func spec() {

        describe("init(request:timeoutInterval:") {
            let (subject, request, timeout) = buildClient()

            it("initialize properties") {
                expect(subject!.request).to(equal(request))
                expect(subject!.timeoutInterval).to(equal(timeout))
                expect(subject!.readyState).to(equal(.closed))
            }
        }

        describe("init(resource:timeoutInterval:") {
            context("resource's request is nil") {
                let resource = TestAPIResource(host: "inavalid%host", path: "/invalid path")
                let timeout = faker.number.randomDouble()
                let subject = SSEClient(resource: resource, timeoutInterval: timeout)

                it("returns nil") {
                    expect(subject).to(beNil())
                }
            }

            context("resource's request is not nil") {
                let resource = TestAPIResource()
                let timeout = faker.number.randomDouble()
                let subject = SSEClient(resource: resource, timeoutInterval: timeout)!

                it("initialize properties") {
                    expect(subject.request).to(equal(resource.request))
                    expect(subject.timeoutInterval).to(equal(timeout))
                    expect(subject.readyState).to(equal(.closed))
                }
            }
        }

        describe("connect") {
            context("with nil lastEventId") {
                let subject = buildClient().0!
                subject.connect(lastEventId: nil)

                it("does not set a lastEventId") {
                    expect(subject.lastEventId).to(beNil())
                }

                it("initializes url session") {
                    expect(subject.urlSession).notTo(beNil())
                }

                it("sets readyState to connecting") {
                    expect(subject.readyState).to(equal(.connecting))
                }
            }

            context("with a non nil lastEventId") {
                let subject = buildClient().0!
                let lastEventId = String(faker.number.randomInt())
                subject.connect(lastEventId: lastEventId)

                it("sets lastEventId") {
                    expect(subject.lastEventId).to(equal(lastEventId))
                }

                it("initializes url session") {
                    expect(subject.urlSession).notTo(beNil())
                }

                it("sets readyState to connecting") {
                    expect(subject.readyState).to(equal(.connecting))
                }
            }
        }

        describe("disconnect") {
            let subject = buildClient().0!
            subject.connect(lastEventId: nil)
            subject.disconnect()

            it("sets readyState to closed") {
                expect(subject.readyState).to(equal(.closed))
            }

            it("sets urlSession as nil") {
                expect(subject.urlSession).to(beNil())
            }
        }

        describe("addListener") {
            let subject = buildClient().0!
            let eventName = faker.lorem.characters(amount: 5)
            subject.addListener(for: eventName) { _ in }

            it("adds the listener") {
                expect(Array(subject.listeners.keys)).to(equal([eventName]))
            }

        }

        describe("removeListener") {
            let subject = buildClient().0!
            let eventName = faker.lorem.characters(amount: 5)
            subject.addListener(for: eventName) { _ in }
            subject.removeListener(for: eventName)

            it("removes the listener") {
                expect(Array(subject.listeners.keys)).to(beEmpty())
            }
        }

        describe("onOpen callback") {
            let subject = buildClient().0!
            var onOpenCalled = false
            subject.onOpen = {
                onOpenCalled = true
            }

            let response = URLResponse(
                url: subject.request.url!,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )

            subject.connect(lastEventId: nil)
            let dataTask = subject.urlSession!.dataTask(with: subject.request)
            subject.urlSession(subject.urlSession!, dataTask: dataTask, didReceive: response) { _ in }

            it("calls onOpen") {
                expect(onOpenCalled).toEventually(beTrue())
            }
        }

        describe("onComplete callback") {
            context("completed with error") {
                let subject = buildClient().0!
                var onCompleteCalled = false
                var error: Error?

                subject.onComplete = { _, _, resultError in
                    onCompleteCalled = true
                    error = resultError
                }

                subject.connect(lastEventId: nil)

                let dataTask = MockDataTask(response: nil)
                let networkError = NetworkError.unknown(nil)
                subject.urlSession(subject.urlSession!, task: dataTask, didCompleteWithError: networkError)

                it("calls onComplete") {
                    expect(onCompleteCalled).toEventually(beTrue())
                }

                it("sent back an error") {
                    expect(error).toNotEventually(beNil())
                }
            }

            context("completed with status code in 201..<300") {
                let subject = buildClient().0!
                var onCompleteCalled = false
                var status: Int?
                var retry: Bool?
                let responseStatus = faker.number.randomInt(min: 201, max: 299)

                subject.onComplete = { resultStatus, resultRetry, _ in
                    onCompleteCalled = true
                    status = resultStatus
                    retry = resultRetry
                }

                let response = HTTPURLResponse(
                    url: subject.request.url!,
                    statusCode: responseStatus,
                    httpVersion: nil,
                    headerFields: [:]
                )

                subject.connect(lastEventId: nil)

                let dataTask = MockDataTask(response: response)
                subject.urlSession(subject.urlSession!, task: dataTask, didCompleteWithError: nil)

                it("calls onComplete") {
                    expect(onCompleteCalled).toEventually(beTrue())
                }
            }

            context("completed with status code outside 204") {
                let subject = buildClient().0!
                var onCompleteCalled = false
                var status: Int?
                var retry: Bool?
                let responseStatus = 204

                subject.onComplete = { resultStatus, resultRetry, _ in
                    onCompleteCalled = true
                    status = resultStatus
                    retry = resultRetry
                }

                let response = HTTPURLResponse(
                    url: subject.request.url!,
                    statusCode: responseStatus,
                    httpVersion: nil,
                    headerFields: [:]
                )

                subject.connect(lastEventId: nil)

                let dataTask = MockDataTask(response: response)
                subject.urlSession(subject.urlSession!, task: dataTask, didCompleteWithError: nil)

                it("calls onComplete") {
                    expect(onCompleteCalled).toEventually(beTrue())
                }

                it("sends retry as false") {
                    expect(retry).toEventually(beFalse())
                }
            }
        }

        describe("onMessage callback") {
            let subject = buildClient().0!
            var onMessageCalledTimes = 0
            var messages: [SSE.Event] = []

            var messageIds: [String?] = []
            var messageDatas: [String?] = []
            var messageRetries: [String?] = []
            var messageEvents: [String?] = []

            let data = """
                data: data-1

                data: data-2.1
                data: data-2.2

                event: event-3
                data: data-3
            """.data(using: .utf8)!

            subject.onMessage = { event in
                onMessageCalledTimes += 1
                messages.append(event)
                messageIds.append(event.id)
                messageDatas.append(event.data)
                messageEvents.append(event.eventType)
                messageRetries.append(event.retry)
            }
            subject.connect(lastEventId: nil)
            subject.readyState = .open

            let dataTask = subject.urlSession!.dataTask(with: subject.request)
            subject.urlSession(subject.urlSession!, dataTask: dataTask, didReceive: data)

            it("calls onMessage 2 times") {
                expect(onMessageCalledTimes).toEventually(equal(2))
            }

            it("returns the right events") {
                expect(messages.count).toEventually(equal(2))
                expect(messageIds).toEventually(equal([nil, nil]))
                expect(messageEvents).toEventually(equal([nil, nil]))
                expect(messageRetries).toEventually(equal([nil, nil]))
                expect(messageDatas).toEventually(equal(["data-1", "data-2.1\ndata-2.2"]))
            }
        }
    }

    private static func buildClient() -> (SSEClient?, URLRequest, TimeInterval) {
        let request = URLRequest(url: URL(string: faker.internet.url())!)
        let timeout = faker.number.randomDouble()
        let client = SSEClient(request: request, timeoutInterval: timeout)
        return (client, request, timeout)
    }
}

// swiftlint:enable force_unwrapping function_body_length
