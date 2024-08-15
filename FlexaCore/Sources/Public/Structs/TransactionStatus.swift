//
//  TransactionStatus.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

public enum TransactionStatus: String {
    case requested, approved, confirmed, canceled, unused, unkown
}
