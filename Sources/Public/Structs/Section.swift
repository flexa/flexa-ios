//
//  Section.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

/// Represents the differnt sections of Flexa SDK
///
/// When the parent application configures Flexa SDK prior to call ``Flexa/open()``, it may specify the different sections to be shown.
extension Flexa {
    public enum Section: Int {
        case scan, load, spend
    }
}
