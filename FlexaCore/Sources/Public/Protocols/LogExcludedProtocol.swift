//
//  LogExcludedProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/29/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol LogExcludedProtocol: CustomStringConvertible, CustomDebugStringConvertible, CustomLeafReflectable {
}

public extension LogExcludedProtocol {
    private var descriptionString: String {
        CoreStrings.Log.Hidden.text
    }

    var description: String {
        descriptionString
    }

    var debugDescription: String {
        descriptionString
    }

    var customMirror: Mirror {
        Mirror(reflecting: descriptionString)
    }
}
