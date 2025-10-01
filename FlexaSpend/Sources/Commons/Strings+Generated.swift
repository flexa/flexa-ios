// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Done
    internal static let done = L10n.tr("Localizable", "common.done", fallback: "Done")
    /// flexa
    internal static let flexa = L10n.tr("Localizable", "common.flexa", fallback: "flexa")
    /// Loading
    internal static let loading = L10n.tr("Localizable", "common.loading", fallback: "Loading")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "Ok")
    /// Sending...
    internal static let sending = L10n.tr("Localizable", "common.sending", fallback: "Sending...")
    /// Signing...
    internal static let signing = L10n.tr("Localizable", "common.signing", fallback: "Signing...")
    /// Updating
    internal static let updating = L10n.tr("Localizable", "common.updating", fallback: "Updating")
  }
  internal enum Errors {
    internal enum RestrictedRegion {
      /// Flexa is running on a restricted region and spends are disabled. Please check Flexa.canSpend
      internal static let message = L10n.tr("Localizable", "errors.restricted_region.message", fallback: "Flexa is running on a restricted region and spends are disabled. Please check Flexa.canSpend")
    }
  }
  internal enum LegacyFlexcode {
    internal enum Alerts {
      internal enum ScanHelp {
        /// Tips for Using Flexcodes at %@
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "legacy_flexcode.alerts.scan_help.title", String(describing: p1), fallback: "Tips for Using Flexcodes at %@")
        }
      }
    }
  }
  internal enum LegacyFlexcodeTray {
    /// Get a one-time code
    internal static let title = L10n.tr("Localizable", "legacy_flexcode_tray.title", fallback: "Get a one-time code")
    internal enum EditButton {
      /// Edit
      internal static let title = L10n.tr("Localizable", "legacy_flexcode_tray.edit_button.title", fallback: "Edit")
    }
  }
  internal enum MerchantSorter {
    /// Using Flexa at these brands requires an extra tap. To access your favorite brands more quickly, pin them to the beginning of the list.
    internal static let description = L10n.tr("Localizable", "merchant_sorter.description", fallback: "Using Flexa at these brands requires an extra tap. To access your favorite brands more quickly, pin them to the beginning of the list.")
    /// Edit Pins
    internal static let title = L10n.tr("Localizable", "merchant_sorter.title", fallback: "Edit Pins")
    internal enum Sections {
      internal enum OtherBrands {
        internal enum Footer {
          /// Looks like you already pinned all the merchants!
          internal static let title = L10n.tr("Localizable", "merchant_sorter.sections.other_brands.footer.title", fallback: "Looks like you already pinned all the merchants!")
        }
        internal enum Header {
          /// Other brands
          internal static let title = L10n.tr("Localizable", "merchant_sorter.sections.other_brands.header.title", fallback: "Other brands")
        }
      }
      internal enum Pinned {
        internal enum Footer {
          /// There are not pinned merchants. You can select some from the list below.
          internal static let title = L10n.tr("Localizable", "merchant_sorter.sections.pinned.footer.title", fallback: "There are not pinned merchants. You can select some from the list below.")
        }
        internal enum Header {
          /// Pinned
          internal static let title = L10n.tr("Localizable", "merchant_sorter.sections.pinned.header.title", fallback: "Pinned")
        }
      }
    }
  }
  internal enum NoAssets {
    /// Nothing to Spend
    internal static let title = L10n.tr("Localizable", "no_assets.title", fallback: "Nothing to Spend")
    internal enum AddAssetButton {
      /// Add Assets
      internal static let label = L10n.tr("Localizable", "no_assets.add_asset_button.label", fallback: "Add Assets")
    }
    internal enum Description {
      /// Flexa doesn’t currently support %s.
      internal static func oneInvalidAsset(_ p1: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "no_assets.description.one_invalid_asset", p1, fallback: "Flexa doesn’t currently support %s.")
      }
      /// Flexa doesn’t currently support %s, %s, or any of the other assets in your wallet.
      internal static func otherInvalidAssets(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "no_assets.description.other_invalid_assets", p1, p2, fallback: "Flexa doesn’t currently support %s, %s, or any of the other assets in your wallet.")
      }
      /// Flexa doesn’t currently support %s or %s.
      internal static func twoInvalidAssets(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "no_assets.description.two_invalid_assets", p1, p2, fallback: "Flexa doesn’t currently support %s or %s.")
      }
      /// There are no assets in your wallet
      internal static let zeroAssets = L10n.tr("Localizable", "no_assets.description.zero_assets", fallback: "There are no assets in your wallet")
    }
  }
  internal enum Payment {
    /// %s avaliable
    internal static func description(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "payment.description", p1, fallback: "%s avaliable")
    }
    /// Done
    internal static let done = L10n.tr("Localizable", "payment.done", fallback: "Done")
    /// Login to authorize the transaction.
    internal static let errorLoginToAuthorize = L10n.tr("Localizable", "payment.error_login_to_authorize", fallback: "Login to authorize the transaction.")
    internal enum Asset {
      internal enum ExchangeRate {
        /// %s %s
        internal static func amount(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "payment.asset.exchange_rate.amount", p1, p2, fallback: "%s %s")
        }
        /// %s avaliable
        internal static func avaliable(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "payment.asset.exchange_rate.avaliable", p1, fallback: "%s avaliable")
        }
        /// No network fees
        internal static let noNetworkFee = L10n.tr("Localizable", "payment.asset.exchange_rate.no_network_fee", fallback: "No network fees")
        /// 1 %s = %s
        internal static func value(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "payment.asset.exchange_rate.value", p1, p2, fallback: "1 %s = %s")
        }
      }
    }
    internal enum Balance {
      /// %s Balance
      internal static func title(_ p1: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "payment.balance.title", p1, fallback: "%s Balance")
      }
    }
    internal enum CurrencyAvaliable {
      /// %s Available
      internal static func title(_ p1: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "payment.currency_avaliable.title", p1, fallback: "%s Available")
      }
    }
    internal enum Message {
      /// Learn More
      internal static let button = L10n.tr("Localizable", "payment.message.button", fallback: "Learn More")
      /// Upgrade your Flexa ID for unlimited spending.
      internal static let description = L10n.tr("Localizable", "payment.message.description", fallback: "Upgrade your Flexa ID for unlimited spending.")
      /// You’re approaching your weekly spending limit.
      internal static let title = L10n.tr("Localizable", "payment.message.title", fallback: "You’re approaching your weekly spending limit.")
    }
    internal enum PayWithFlexa {
      /// Pay with Flexa
      internal static let title = L10n.tr("Localizable", "payment.pay_with_flexa.title", fallback: "Pay with Flexa")
    }
    internal enum TransactionDetails {
      /// Flexa automatically selects the best exchange rate and network fee for your payments. [Learn more...](https://flexa.co)
      internal static let footer = L10n.tr("Localizable", "payment.transaction_details.footer", fallback: "Flexa automatically selects the best exchange rate and network fee for your payments. [Learn more...](https://flexa.co)")
    }
    internal enum UsingTicker {
      /// Using %s
      internal static func subtitle(_ p1: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "payment.using_ticker.subtitle", p1, fallback: "Using %s")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
