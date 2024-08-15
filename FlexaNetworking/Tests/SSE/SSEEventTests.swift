//
//  SSEEventTests.swift
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
@testable import FlexaNetworking

// swiftlint:disable force_unwrapping function_body_length
final class SSEEventTests: QuickSpec {
    static let faker = Faker()

    override class func spec() {
        describe("init(url:)") {
            let id = UUID().uuidString
            let event = faker.hobbit.character()
            let data = faker.lorem.paragraph()
            let retry = String(faker.number.randomInt())
            let subject = SSE.Event(id: id, event: event, data: data, retry: retry)

            it("sets the Event properties") {
                expect(subject.id).to(equal(id))
                expect(subject.eventType).to(equal(event))
                expect(subject.data).to(equal(data))
                expect(subject.retry).to(equal(retry))
            }
        }

        describe("init(dictionary:)") {
            var dictionary = [
                "id": UUID().uuidString,
                "event": faker.hobbit.character(),
                "data": faker.lorem.paragraph(),
                "retry": String(faker.number.randomInt())
            ]
            let subject = SSE.Event(from: dictionary)

            it("sets the Event properties") {
                expect(subject.id).to(equal(dictionary["id"]))
                expect(subject.eventType).to(equal(dictionary["event"]))
                expect(subject.data).to(equal(dictionary["data"]))
                expect(subject.retry).to(equal(dictionary["retry"]))
            }
        }

        describe("isEmpty") {
            context("all values are nil") {
                let subject = SSE.Event()
                it("returns true") {
                    expect(subject.isEmpty).to(beTrue())
                }
            }

            context("all values are empty") {
                let subject = SSE.Event(id: "", event: "", data: "", retry: "")
                it("returns true") {
                    expect(subject.isEmpty).to(beTrue())
                }
            }

            context("contains at least 1 no nil and no empty value") {
                let subject = SSE.Event(id: "id", event: "", data: "", retry: "")
                it("returns false") {
                    expect(subject.isEmpty).to(beFalse())
                }
            }
        }

        describe("isMessage") {
            context("event is nil") {
                let subject = SSE.Event()
                it("is true") {
                    expect(subject.isMessage).to(beTrue())
                }
            }

            context("event is `message`") {
                let subject = SSE.Event(event: "message")
                it("is true") {
                    expect(subject.isMessage).to(beTrue())
                }
            }

            context("event is not nil and is not `message`") {
                let subject = SSE.Event(event: "NotAMessage")
                it("is false") {
                    expect(subject.isMessage).to(beFalse())
                }
            }
        }

        describe("isRetryOnly") {
            context("retry is nil") {
                context("other properties are nil") {
                    let subject = SSE.Event(id: String(faker.number.randomInt()))
                    it("is false") {
                        expect(subject.isRetryOnly).to(beFalse())
                    }
                }

                context("some property is not nil") {
                    let subject = SSE.Event(id: String(faker.number.randomInt()))
                    it("is false") {
                        expect(subject.isRetryOnly).to(beFalse())
                    }
                }
            }

            context("retry is not nil") {
                context("other properties are nil") {
                    let subject = SSE.Event(retry: String(faker.number.randomInt()))
                    it("is false") {
                        expect(subject.isRetryOnly).to(beTrue())
                    }
                }

                context("some other property is not nil") {
                    let subject = SSE.Event(id: String(faker.number.randomInt()), retry: String(faker.number.randomInt()))
                    it("is false") {
                        expect(subject.isRetryOnly).to(beFalse())
                    }
                }
            }
        }

        describe("event(from:)") {
            context("single message") {
                let data = faker.lorem.characters(amount: 5)
                let messageData = "data: \(data)".data(using: .utf8)!
                let subject = SSE.Event.eventFrom(data: messageData)!

                it("returns an event with data only") {
                    expect(subject.id).to(beNil())
                    expect(subject.eventType).to(beNil())
                    expect(subject.data).to(equal(data))
                    expect(subject.retry).to(beNil())
                }
            }

            context("message with multiple data (rows)") {
                let data1 = faker.lorem.characters(amount: 5)
                let data2 = faker.lorem.characters(amount: 5)
                let messageData = """
                        data: \(data1)
                        data: \(data2)
                    """.data(using: .utf8)!
                let subject = SSE.Event.eventFrom(data: messageData)!

                it("returns an event with the concatenated data") {
                    expect(subject.id).to(beNil())
                    expect(subject.eventType).to(beNil())
                    expect(subject.data).to(equal("\(data1)\n\(data2)"))
                    expect(subject.retry).to(beNil())
                }
            }

            context("event with data") {
                let data = faker.lorem.characters(amount: 5)
                let event = faker.lorem.characters(amount: 5)
                let messageData = """
                        data: \(data)
                        event: \(event)
                    """.data(using: .utf8)!

                let subject = SSE.Event.eventFrom(data: messageData)!

                it("returns an event with data and event") {
                    expect(subject.id).to(beNil())
                    expect(subject.eventType).to(equal(event))
                    expect(subject.data).to(equal(data))
                    expect(subject.retry).to(beNil())
                }
            }

            context("event with id and data") {
                let id = String(faker.number.increasingUniqueId())
                let data = faker.lorem.characters(amount: 5)
                let event = faker.lorem.characters(amount: 5)
                let messageData = """
                        id: \(id)
                        data: \(data)
                        event: \(event)
                    """.data(using: .utf8)!

                let subject = SSE.Event.eventFrom(data: messageData)!

                it("returns an event with id, data and event") {
                    expect(subject.id).to(equal(id))
                    expect(subject.eventType).to(equal(event))
                    expect(subject.data).to(equal(data))
                    expect(subject.retry).to(beNil())
                }
            }

            context("empty rows") {
                let messageData = "\n\n\n".data(using: .utf8)!
                let subject = SSE.Event.eventFrom(data: messageData)

                it("returns nil") {
                    expect(subject).to(beNil())
                }
            }

            context("rows starting with colon") {
                let messageData = """
                        :

                        :
                    """.data(using: .utf8)!
                let subject = SSE.Event.eventFrom(data: messageData)
                it("returns nil") {
                    expect(subject).to(beNil())
                }
            }

            context("missing key") {
                let id = String(faker.number.increasingUniqueId())
                let data = faker.lorem.characters(amount: 5)
                let event = faker.lorem.characters(amount: 5)
                let messageData = "id: \(id)\n: \(data)\nevent: \(event)".data(using: .utf8)!

                let subject = SSE.Event.eventFrom(data: messageData)!

                it("returns an event with id and event only") {
                    expect(subject.id).to(equal(id))
                    expect(subject.eventType).to(equal(event))
                    expect(subject.data).to(beNil())
                    expect(subject.retry).to(beNil())
                }

            }

            context("missing value") {
                let id = String(faker.number.increasingUniqueId())
                let data = faker.lorem.characters(amount: 5)
                let event = faker.lorem.characters(amount: 5)
                let messageData = """
                        id: \(id)
                        data: \(data)
                        data:
                        event: \(event)
                    """.data(using: .utf8)!

                let subject = SSE.Event.eventFrom(data: messageData)!

                it("returns an event with the first piece of data + \n") {
                    expect(subject.id).to(equal(id))
                    expect(subject.eventType).to(equal(event))
                    expect(subject.data).to(equal(data + "\n"))
                    expect(subject.retry).to(beNil())
                }
            }
        }

        describe("events(from:)") {
            let data = """
                data: data-1

                data: data-2.1
                data: data-2.2

                event: event-3
                data: data-3

                :

                event: event-4
                data: data-4

                id: event-id-5
                event: event-5
                data: data-5
                retry: 3000
            """.data(using: .utf8)!

            let messages = SSE.Event.eventsFrom(data: data)
            it("returns 5 messages") {
                expect(messages.count).to(equal(5))
            }

            it("parses messges properly") {
                expect(messages[0].id).to(beNil())
                expect(messages[0].eventType).to(beNil())
                expect(messages[0].data).to(equal("data-1"))
                expect(messages[0].retry).to(beNil())

                expect(messages[1].id).to(beNil())
                expect(messages[1].eventType).to(beNil())
                expect(messages[1].data).to(equal("data-2.1\ndata-2.2"))
                expect(messages[1].retry).to(beNil())

                expect(messages[2].id).to(beNil())
                expect(messages[2].eventType).to(equal("event-3"))
                expect(messages[2].data).to(equal("data-3"))
                expect(messages[2].retry).to(beNil())

                expect(messages[3].id).to(beNil())
                expect(messages[3].eventType).to(equal("event-4"))
                expect(messages[3].data).to(equal("data-4"))
                expect(messages[3].retry).to(beNil())

                expect(messages[4].id).to(equal("event-id-5"))
                expect(messages[4].eventType).to(equal("event-5"))
                expect(messages[4].data).to(equal("data-5"))
                expect(messages[4].retry).to(equal("3000"))
            }
        }
    }
}
// swiftlint:enable force_unwrapping function_body_length
