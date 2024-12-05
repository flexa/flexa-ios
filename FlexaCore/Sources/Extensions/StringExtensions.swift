//
//  StringExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension String {
    private var defaultLocale: Locale {
        Locale(identifier: "en-US")
    }

    var decimalValue: Decimal? {
        guard let decimalString = self.digitsAndSeparator, !isEmpty else {
            return nil
        }

        return Decimal(string: decimalString)
    }

    var asCurrency: String {
        let currencySymbol = defaultLocale.currencySymbol
        return "\(currencySymbol ?? "")\(self)"
    }

    var isEmail: Bool {
        let detectorType = NSTextCheckingResult.CheckingType.link.rawValue
        let range = NSRange(location: 0, length: self.count)

        guard let detector = try? NSDataDetector(types: detectorType),
              let match = detector.matches(in: self, options: [], range: range).first,
              let matchURL = match.url,
              let matchURLComponents = URLComponents(url: matchURL, resolvingAgainstBaseURL: false),
              matchURLComponents.scheme == "mailto" else {
            return false
        }

        return true
    }

    var digits: String {
        let text = components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
            .replacingOccurrences(
                of: "^0+",
                with: "",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: "^\\.",
                with: "0.",
                options: .regularExpression
            )
        return text.isEmpty ? "0" : text
    }

    var digitsAndSeparator: String? {
        guard let decimalSeparator = defaultLocale.decimalSeparator else {
            return nil
        }

        var characterSet = CharacterSet.decimalDigits
        characterSet.insert(charactersIn: decimalSeparator)

        var text = components(separatedBy: characterSet.inverted)
            .joined()
        text = text
            .replacingOccurrences(
                of: "^0+",
                with: "",
                options: .regularExpression
            )
        text = text
            .replacingOccurrences(
                of: "^\\.",
                with: "0.",
                options: .regularExpression
            )
        return text.isEmpty ? "0" : text
    }

    func deletingSufix(_ sufix: String) -> String {
        guard hasSuffix(sufix) else {
            return self
        }
        return String(dropLast(sufix.count))
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {
            return self
        }
        return String(self.dropFirst(prefix.count))
    }

    func trims() -> String {
        return trimmingCharacters(in: .whitespaces)
    }
}

extension StringProtocol {
    public subscript(offset: Int) -> String {
        String(self[index(startIndex, offsetBy: offset)])
    }
}

extension String: FlexaModelProtocol {
}
