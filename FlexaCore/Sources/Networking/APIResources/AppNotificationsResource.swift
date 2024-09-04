//
//  AppNotificationsResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum AppNotificationsResource: FlexaAPIResource, JWTAuthenticable {
    case delete(String)

    private static let idUrlParameter = ":id"

    var method: RequestMethod {
        .delete
    }

    var path: String {
        "/app_notifications/\(Self.idUrlParameter)"
    }

    var pathParams: [String: String]? {
        switch self {
        case .delete(let id):
            [Self.idUrlParameter: id]
        }
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
        ReasonableError(reason: .cannotDeleteAppNotification(error))
    }
}
