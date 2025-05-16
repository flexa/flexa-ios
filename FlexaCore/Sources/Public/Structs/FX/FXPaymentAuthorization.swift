//
//  FXPaymentAuthorization.swift
//  FlexaCire
//
//  Created by Rodrigo Ordeix on 5/16/25.
//  Copyright © 2025 Flexa. All rights reserved.
//

import Foundation

public struct FXPaymentAuthorization: FlexaModelProtocol {
    public enum Status: String, Codable {
        case succeeded, failed
    }

    public let status: Status
    public let commerceSessionId: String
    public let brandName: String
    public let brandLogoUrl: URL?
}
