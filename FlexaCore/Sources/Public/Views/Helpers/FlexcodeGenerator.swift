//
//  FlexcodeGenerator.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 5/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit
import Factory
import CoreImage.CIFilterBuiltins
import Base32

public enum FlexcodeSymbology: Hashable {
    case qr, pdf417, code128
    case custom(String)
}

public struct Flexcode {
    public var code: String
    public var image: UIImage?
}

public protocol FlexcodeGeneratorProtocol {
    func flexcodes(for: OneTimeKey?, types: [FlexcodeSymbology], scale: CGFloat) -> [FlexcodeSymbology: Flexcode]
    func flexcodes(forCode: String, types: [FlexcodeSymbology], scale: CGFloat, useCache: Bool) -> [FlexcodeSymbology: Flexcode]
}

public extension FlexcodeGeneratorProtocol {
    func flexcodes(for key: OneTimeKey?) -> [FlexcodeSymbology: Flexcode] {
        flexcodes(for: key, types: [.pdf417, .code128], scale: 5)
    }

    func flexcodes(forCode code: String, useCache: Bool = false) -> [FlexcodeSymbology: Flexcode] {
        flexcodes(forCode: code, types: [.pdf417, .code128], scale: 5, useCache: false)
    }
}

class FlexcodeGenerator: FlexcodeGeneratorProtocol {
    private var cachedCodes: [String: [FlexcodeSymbology: Flexcode]] = [:]

    func flexcode(for key: OneTimeKey?, type: FlexcodeSymbology, scale: CGFloat) -> Flexcode? {
        guard let key else {
            FlexaLogger.error("Missing key")
            return nil
        }

        guard let data = MF_Base32Codec.data(fromBase32String: key.secret) else {
            FlexaLogger.error("Cannot convert key to data")
            return nil
        }

        let totpGenerator = Container.shared.totpGenerator((data, key.length))
        let seconds = Date().timeIntervalSince1970 - key.serverTimeOffset
        let intSeconds = Int(exactly: seconds.rounded(.toNearestOrEven)) ?? 0

        guard let totp = totpGenerator.generate(secondsSince1970: intSeconds) else {
            FlexaLogger.error("Cannot generate a TOTP")
            return nil
        }

        let code = key.prefix + totp
        let image = createImageCode(from: code, type: type, scale: scale)
        return Flexcode(code: code, image: image)
    }

    func flexcodes(
        for key: OneTimeKey?,
        types: [FlexcodeSymbology],
        scale: CGFloat
    ) -> [FlexcodeSymbology: Flexcode] {
        types.reduce([FlexcodeSymbology: Flexcode]()) { partialResult, type in
            guard let flexcode = flexcode(for: key, type: type, scale: scale) else {
                return partialResult
            }
            var dictionary = partialResult
            dictionary[type] = flexcode
            return dictionary
        }
    }

    func flexcodes(forCode code: String, types: [FlexcodeSymbology], scale: CGFloat, useCache: Bool) -> [FlexcodeSymbology: Flexcode] {
        if let flexcodes = cachedCodes[code], !flexcodes.isEmpty, useCache {
            return flexcodes
        }

        let flexcodes = types
            .reduce(into: [FlexcodeSymbology: Flexcode]()) {
                $0[$1] = Flexcode(
                    code: code,
                    image: createImageCode(from: code, type: $1, scale: scale)
                )
            }

        if useCache {
            cachedCodes[code] = flexcodes
        }
        return flexcodes
    }

    func createImageCode(from code: String, type: FlexcodeSymbology, scale: CGFloat) -> UIImage? {
        guard let generator = generator(for: type, with: code) else {
            FlexaLogger.error("Cannot find create the generator for \(code) with \(type)")
            return nil
        }

        guard let ciImage = generator.outputImage else {
            FlexaLogger.error("Cannot generate the code image")
            return nil
        }

        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func generator(for type: FlexcodeSymbology, with code: String) -> CIFilter? {
        guard let data = code.data(using: .ascii) else {
            return nil
        }

        switch type {
        case .code128:
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = data
            return filter
        case .pdf417:
            let filter = CIFilter.pdf417BarcodeGenerator()
            filter.compactStyle = 1
            filter.dataColumns = 1
            filter.message = data
            return filter
        case .qr:
            let filter = CIFilter.qrCodeGenerator()
            filter.message = data
            return filter
        case .custom(let name):
            let filter = CIFilter(name: name)
            filter?.setValue(data, forKey: "inputMessage")
            return filter
        }
    }
}
