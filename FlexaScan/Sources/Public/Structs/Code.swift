//
//  Code.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 10/18/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Vision

public extension FlexaScan {
    struct Code {
        private let components: URLComponents?
        public let uriString: String
        public let symbology: VNBarcodeSymbology

        public var url: URL? {
            components?.url
        }

        public var scheme: String? {
            components?.scheme
        }

        public var host: String? {
            components?.host
        }

        public var path: String? {
            components?.path
        }

        public var query: String? {
            components?.query
        }

        public var queryItems: [URLQueryItem] {
            components?.queryItems ?? []
        }

        init(uriString: String, symbology: VNBarcodeSymbology) {
            self.uriString = uriString
            self.symbology = symbology
            self.components = URLComponents(string: uriString)
        }
    }
}

extension FlexaScan.Code: CustomStringConvertible {
    public var description: String {
        "Format: \(symbology.rawValue)\nPayload: \(uriString)"
    }
}
