//
//  CommerceSessionModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/13/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import Factory

extension Models {
    struct CommerceSession: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, asset, label, amount
            case sessionBrand = "brand"
            case sessionRate = "rate"
            case sessionPreferences = "preferences"
            case statusString = "status"
            case sessionTransactions = "transactions"
            case sessionAuthorization = "authorization"
            case sessionCredits = "credits"
        }
        var id: String
        var asset: String
        var label: String?
        var amount: String
        var sessionBrand: Brand?
        var sessionPreferences: Preference
        var statusString: String
        var sessionRate: Models.Rate
        var sessionTransactions: [Models.Transaction]?
        var sessionAuthorization: Authorization?
        var sessionCredits: [Credit]

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Models.CommerceSession.CodingKeys> = try decoder.container(
                keyedBy: CodingKeys.self
            )
            self.id = try container.decode(String.self, forKey: CodingKeys.id)
            self.asset = try container.decode(String.self, forKey: CodingKeys.asset)
            self.label = try container.decodeIfPresent(String.self, forKey: CodingKeys.label)
            self.amount = try container.decode(String.self, forKey: CodingKeys.amount)
            self.sessionRate = try container.decode(Models.Rate.self, forKey: CodingKeys.sessionRate)
            self.statusString = try container.decode(String.self, forKey: CodingKeys.statusString)

            self.sessionPreferences = try container.decode(
                Models.CommerceSession.Preference.self,
                forKey: CodingKeys.sessionPreferences
            )
            self.sessionTransactions = try container.decodeIfPresent(
                [Models.Transaction].self,
                forKey: CodingKeys.sessionTransactions
            )
            self.sessionAuthorization = try container.decodeIfPresent(
                Models.CommerceSession.Authorization.self,
                forKey: CodingKeys.sessionAuthorization
            )

            self.sessionCredits = try container.decodeIfPresent(
                [Models.CommerceSession.Credit].self,
                forKey: CodingKeys.sessionCredits
            ) ?? []

            do {
                self.sessionBrand = try container.decodeIfPresent(Models.Brand.self, forKey: CodingKeys.sessionBrand)
            } catch {
                if let brandId = try container.decodeIfPresent(String.self, forKey: .sessionBrand) {
                    self.sessionBrand = Container.shared.brandsRepository()
                        .all
                        .first(where: { $0.id == brandId }) as? Models.Brand
                }
            }
        }
    }
}

extension Models.CommerceSession {
    struct Preference: FlexaModelProtocol, CommerceSessionPreference {
        enum CodingKeys: String, CodingKey {
            case app
            case paymentAsset = "payment_asset"
        }

        var app: String?
        var paymentAsset: String
    }
}

extension Models.CommerceSession {
    struct Authorization: FlexaModelProtocol, CommerceSessionAuthorization {
        enum CodingKeys: String, CodingKey {
            case instructions, details, number
            case statusString = "status"
        }

        var instructions, details: String?
        var number: String
        var statusString: String

        var status: CommerceSessionAuthorizationStatus {
            CommerceSessionAuthorizationStatus(rawValue: statusString) ?? .pending
        }
    }
}

extension Models.CommerceSession {
    struct Credit: FlexaModelProtocol, CommerceSessionCredit {
        var id: String
        var amount: String
        var asset: String
        var label: String
        var status: String
    }
}

extension Models.CommerceSession: CommerceSession {
    var status: CommerceSessionStatus {
        CommerceSessionStatus(rawValue: statusString) ?? .unknown
    }

    var preferences: CommerceSessionPreference {
        sessionPreferences
    }

    var rate: Rate {
        sessionRate
    }

    var transactions: [FlexaCore.Transaction] {
        sessionTransactions ?? []
    }

    var brand: Brand? {
        sessionBrand
    }

    var authorization: CommerceSessionAuthorization? {
        get {
            sessionAuthorization
        }
        set {
            if let newValue {
                sessionAuthorization =
                Models.CommerceSession.Authorization(
                    instructions: newValue.instructions,
                    details: newValue.details,
                    number: newValue.number,
                    statusString: newValue.status.rawValue
                )
            } else {
                sessionAuthorization = nil
            }
        }
    }

    var credits: [CommerceSessionCredit] {
        sessionCredits
    }
}
