import Foundation
import FlexaCore
import Combine
import SwiftUI
import Factory

class LegacyFlexcodeViewModel: ObservableObject, Identifiable {

    var brandName: String {
        brand?.name ?? ""
    }

    var merchantLogoUrl: URL? {
        brand?.logoUrl
    }

    var showInfoButton: Bool {
        false
    }

    var brand: Brand?

    required init(brand: Brand?) {
        self.brand = brand
    }
}
