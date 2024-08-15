//
//  FlexaModelProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol FlexaModelProtocol: Codable, Hashable {
    init(data: Data) throws
    init(data: Data?) throws
    init(_ json: String, using encoding: String.Encoding) throws
    init(fromURL url: URL) throws

    var dictionary: [String: Any]? { get }
    func jsonData() throws -> Data
    func jsonString(encoding: String.Encoding) throws -> String?
}

public extension FlexaModelProtocol {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    init(data: Data?) throws {
        guard let data = data else {
            throw ReasonableError.invalidValue
        }

        self = try JSONDecoder().decode(Self.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }

        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    var dictionary: [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: jsonData()) as? [String: Any]
        } catch let error {
            FlexaLogger.error(error)
        }
        return nil
    }

    func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension Array: FlexaModelProtocol where Iterator.Element: FlexaModelProtocol {
}
