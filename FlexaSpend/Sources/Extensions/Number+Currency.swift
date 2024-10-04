import Foundation

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    public var asCurrency: String {
        asCurrency()
    }

    func asCurrency(usesGroupingSeparator: Bool = false,
                    locale: Locale = Locale(identifier: "en-US"),
                    minimumFractionDigits: Int = 2,
                    maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: self as NSNumber) ?? ""
    }

    func formatted(usesGroupingSeparator: Bool = false,
                   locale: Locale = Locale(identifier: "en-US"),
                   minimumFractionDigits: Int = 0,
                   maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.locale = locale
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: self as NSNumber) ?? ""
    }
}
