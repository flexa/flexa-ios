//
//  OneTimeKeysResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum OneTimeKeysResource: FlexaAPIResource, JWTAuthenticable {
    case sync(_ assets: SyncOneTimeKeysInput)

    var method: RequestMethod {
        .put
    }

    var path: String {
        "/accounts/me/one_time_keys"
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .sync(let input):
            input.dictionary
        }
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
       ReasonableError.withReason(.cannotSyncOneTimeKeys(error))
    }
}
