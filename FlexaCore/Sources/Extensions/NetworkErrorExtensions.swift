//
//  NetworkErrorExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/21/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking

extension NetworkError {
    var apiError: APIError? {
        guard case .invalidStatus(_, _, _, let data) = self else {
            return nil
        }

        let apiErrorWrapper = try? APIErrorWrapper(data: data)
        return apiErrorWrapper?.error
    }
}
