import Foundation
import Combine
import SwiftUI
import Factory

public class LegacyFlexcodeViewModel: ObservableObject, Identifiable {
    @Injected(\.flexcodeGenerator) private var flexcodeGenerator

    var brandName: String {
        brand?.name ?? ""
    }

    var merchantLogoUrl: URL? {
        brand?.logoUrl
    }

    var showInfoButton: Bool {
        false
    }

    var brandColor: Color {
        brand?.color ?? .flexaTintColor
    }

    var instructions: String {
        authorization.instructions ?? ""
    }

    var details: String {
        authorization.details ?? ""
    }

    var hasCodeImages: Bool {
        flexcodes.contains {
            $0.value.image != nil
        }
    }

    var brand: Brand?
    var authorization: CommerceSessionAuthorization
    private var flexcodes: [FlexcodeSymbology: Flexcode] = [:]

    @Published var pdf417Image: UIImage = UIImage()
    @Published var code128Image: UIImage = UIImage()
    @Published var privatePdf417Image: UIImage = UIImage()
    @Published var privateCode128Image: UIImage = UIImage()

    required init(brand: Brand?, authorization: CommerceSessionAuthorization) {
        self.brand = brand
        self.authorization = authorization
        self.flexcodes = flexcodeGenerator.flexcodes(forCode: authorization.number)
        self.pdf417Image = flexcodes[.pdf417]?.image ?? UIImage()
        self.code128Image = flexcodes[.code128]?.image ?? UIImage()

        let privateFlexcodes = flexcodeGenerator.flexcodes(forCode: CoreStrings.LegacyFlexcode.preventScreenshotText, useCache: true)
        self.privatePdf417Image = privateFlexcodes[.pdf417]?.image ?? UIImage()
        self.privateCode128Image = privateFlexcodes[.code128]?.image ?? UIImage()
    }
}
