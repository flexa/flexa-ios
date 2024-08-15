//
//  CreateAccountInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/15/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct CreateAccountInput: FlexaModelProtocol {
    enum CodingKeys: String, CodingKey {
        case email
        case givenName = "given_name"
        case familyName = "family_name"
        case dateOfBirth = "date_of_birth"
        case countryCode = "country"
    }

    var email: String
    var givenName: String
    var familyName: String
    var dateOfBirth: String
    var countryCode: String

    init(email: String,
         givenName: String,
         familyName: String,
         dateOfBirth: Date,
         countryCode: String) {
        self.email = email
        self.givenName = givenName
        self.familyName = familyName
        self.dateOfBirth = dateOfBirth.apiFormatted
        self.countryCode = countryCode
    }
}
