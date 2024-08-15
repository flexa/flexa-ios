//
//  AccountModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct AppNotification: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, title, body
            case notificationAction = "action"
            case iconUrlString = "icon_url"
        }

        var id, title, body: String
        var iconUrlString: String?
        var notificationAction: Action?
    }
}

extension Models.AppNotification {
    struct Action: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case label
            case urlString = "url"
        }

        var label: String
        var urlString: String?
    }
}

extension Models.AppNotification: AppNotification {
    var action: (any AppNotificationAction)? {
        notificationAction
    }

    var iconUrl: URL? {
        URL(string: iconUrlString ?? "")
    }
}

extension Models.AppNotification.Action: AppNotificationAction {
    var url: URL? {
        URL(string: urlString ?? "")
    }
}
