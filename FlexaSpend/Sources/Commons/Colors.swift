// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let commonCloseButton = ColorAsset(name: "CommonCloseButton")
  internal static let commonGrabber = ColorAsset(name: "CommonGrabber")
  internal static let commonLink = ColorAsset(name: "CommonLink")
  internal static let commonMainBackground = ColorAsset(name: "CommonMainBackground")
  internal static let commonSettingsButton = ColorAsset(name: "CommonSettingsButton")
  internal static let flexaIdBackground = ColorAsset(name: "FlexaIdBackground")
  internal static let flexaIdCheckmark = ColorAsset(name: "FlexaIdCheckmark")
  internal static let flexaIdChevronImage = ColorAsset(name: "FlexaIdChevronImage")
  internal static let flexaIdDetailDisclosureImage = ColorAsset(name: "FlexaIdDetailDisclosureImage")
  internal static let flexaIdEmailText = ColorAsset(name: "FlexaIdEmailText")
  internal static let flexaIdJoinedDateText = ColorAsset(name: "FlexaIdJoinedDateText")
  internal static let flexaIdNameText = ColorAsset(name: "FlexaIdNameText")
  internal static let flexaIdTitle = ColorAsset(name: "FlexaIdTitle")
  internal static let messageBackground = ColorAsset(name: "MessageBackground")
  internal static let messageCloseButton = ColorAsset(name: "MessageCloseButton")
  internal static let messageDescriptionText = ColorAsset(name: "MessageDescriptionText")
  internal static let messageLogoBackground = ColorAsset(name: "MessageLogoBackground")
  internal static let messageSeparator = ColorAsset(name: "MessageSeparator")
  internal static let payWithFlexaWalletSwitcherButton = ColorAsset(name: "PayWithFlexaWalletSwitcherButton")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = Bundle.spendBundle.colorsBundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = Bundle.spendBundle.colorsBundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = Bundle.spendBundle.colorsBundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif
