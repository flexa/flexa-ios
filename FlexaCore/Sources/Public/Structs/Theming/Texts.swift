//
//  Texts.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension FXTheme {
    struct Texts: Codable {
        var title: Title
        var heading: Heading
        var table: Table
        var body: Body
        var card: Card
    }
}

public extension FXTheme.Texts {
    struct Text: Codable {

    }

    struct Title: Codable {
        var largeTitle: Text
        var title1: Text
        var title2: Text
    }

    struct Heading: Codable {
        var subheading1: Text
        var subheading2: Text
        var subheading3: Text
        var subheading4: Text
        var dropdownSuheading: Text
    }

    struct Table: Codable {
        var cellLabel: Text
        var largeCellLabel: Text
        var cellTitle: Text
        var cellSubtitle: Text
        var cellDetail: Text
        var cellFooter: Text
    }

    struct Body: Codable {
        var body: Text
        var caption: Text
        var captionLight: Text
    }

    struct Card: Codable {
        var title: Text
        var summary: Text
        var actionState: Text
    }
}
