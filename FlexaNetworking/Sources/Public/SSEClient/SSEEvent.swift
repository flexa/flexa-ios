//
//  SSEEvent.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 06/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension SSE {
    struct Event {
        enum Fields: String, CaseIterable {
            case id, event, data, retry
        }

        public var id: String?
        public var eventType: String?
        public var data: String?
        public var retry: String?

        public var isMessage: Bool {
            eventType == nil || eventType == "message"
        }

        public var isRetryOnly: Bool {
            let otherProperties: [String] = [id, eventType, data].compactMap { $0 }
            return otherProperties.isEmpty && retry != nil
        }

        public init(id: String? = nil, event: String? = nil, data: String? = nil, retry: String? = nil) {
            self.id = id
            self.eventType = event
            self.data = data
            self.retry = retry
        }

        public init(from dictionary: [String: String]) {
            id = dictionary[Fields.id.rawValue]
            eventType = dictionary[Fields.event.rawValue]
            data = dictionary[Fields.data.rawValue]
            retry = dictionary[Fields.retry.rawValue]
        }

        var isEmpty: Bool {
            let properties: [String?] = [id, eventType, data, retry]
            return !properties
                .compactMap { $0 }
                .contains { !$0.isEmpty }
        }

        static func eventFrom(data: Data) -> SSE.Event? {
            let rows = data.split(separator: SSE.lfChar)
            var dictionary: [String: String?] = [:]
            for row in rows {
                if row.isEmpty || row.first == SSE.colonChar {
                    continue
                }

                let keyValue = row.split(separator: SSE.colonChar, maxSplits: 1)
                let key = keyValue.first?.utf8String.trimmingCharacters(in: .whitespaces)
                let value = keyValue.count > 1 ? keyValue.last?.utf8String.trimmingCharacters(in: .whitespaces) : nil

                guard let key, !key.isEmpty else {
                    continue
                }

                if key == Fields.data.rawValue, let currentData = dictionary[key], let data = currentData {
                    let newData = value?.trimmingCharacters(in: .whitespaces) ?? ""
                    dictionary[key] = "\(data)\n\(newData)"
                } else {
                    dictionary[key] = value?.trimmingCharacters(in: .whitespaces)
                }
            }

            let event = Self.init(from: dictionary.compactMapValues({ $0 }))
            return event.isEmpty ? nil : event
        }

        static func eventsFrom(data: Data) -> [Self] {
            data.split(with: [SSE.lfChar, SSE.lfChar]).compactMap { eventFrom(data: $0) }
        }
    }
}

public extension SSE {
    struct Parser {
        private var data = Data()

        mutating func append(data: Data?) -> [SSE.Event] {
            guard let data else {
                return []
            }
            self.data.append(data)

            guard let parsedData = parseEvents() else {
                return []
            }
            let events = SSE.Event.eventsFrom(data: parsedData)
            return events
        }

        private mutating func parseEvents() -> Data? {
            guard let range = data.lastRange(of: [SSE.lfChar, SSE.lfChar]), !range.isEmpty else {
                return nil
            }
            let completedEventsRange = Range<Int>(uncheckedBounds: (lower: 0, upper: range.lowerBound))
            let completedEventsData = data.subdata(in: completedEventsRange)
            if range.upperBound < data.count {
                let remainingRange = Range<Int>(uncheckedBounds: (lower: range.upperBound, upper: data.count))
                data = data.subdata(in: remainingRange)
            } else {
                data = Data()
            }
            return completedEventsData
        }
    }
}
