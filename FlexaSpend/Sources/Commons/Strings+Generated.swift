// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Account {
    internal enum Alerts {
      internal enum SignOut {
        /// Signing out will remove all Flexa data that is stored with %s on this device. Your wallet and your transaction history will not be affected.
        internal static func message(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "account.alerts.sign_out.message", p1, fallback: "Signing out will remove all Flexa data that is stored with %s on this device. Your wallet and your transaction history will not be affected.")
        }
        /// Sign Out of Flexa?
        internal static let title = L10n.tr("Localizable", "account.alerts.sign_out.title", fallback: "Sign Out of Flexa?")
        internal enum Buttons {
          internal enum SignOut {
            /// Sign Out
            internal static let title = L10n.tr("Localizable", "account.alerts.sign_out.buttons.sign_out.title", fallback: "Sign Out")
          }
        }
      }
    }
    internal enum Header {
      internal enum Labels {
        /// Joined in %s
        internal static func joinedIn(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "account.header.labels.joined_in", p1, fallback: "Joined in %s")
        }
      }
    }
    internal enum Navigation {
      /// Account
      internal static let title = L10n.tr("Localizable", "account.navigation.title", fallback: "Account")
    }
    internal enum Sections {
      internal enum DataAndPrivacy {
        internal enum Cells {
          internal enum DataAndPrivacy {
            /// Data & Privacy
            internal static let title = L10n.tr("Localizable", "account.sections.data_and_privacy.cells.data_and_privacy.title", fallback: "Data & Privacy")
          }
        }
      }
      internal enum Limit {
        internal enum Footer {
          /// Limits reset on %s at %s.
          internal static func title(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
            return L10n.tr("Localizable", "account.sections.limit.footer.title", p1, p2, fallback: "Limits reset on %s at %s.")
          }
        }
        internal enum Header {
          /// Your Flexa Account
          internal static let title = L10n.tr("Localizable", "account.sections.limit.header.title", fallback: "Your Flexa Account")
        }
      }
      internal enum SignOut {
        internal enum Cells {
          internal enum SignOut {
            /// Sign Out of Flexa
            internal static let title = L10n.tr("Localizable", "account.sections.sign_out.cells.sign_out.title", fallback: "Sign Out of Flexa")
          }
        }
      }
    }
  }
  internal enum Brand {
    internal enum Links {
      /// https://flexa.network/directory
      internal static let merchantList = L10n.tr("Localizable", "brand.links.merchant_list", fallback: "https://flexa.network/directory")
      /// %@/%@/locations
      internal static func merchantLocations(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "brand.links.merchant_locations", String(describing: p1), String(describing: p2), fallback: "%@/%@/locations")
      }
    }
  }
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
    /// Updating
    internal static let updating = L10n.tr("Localizable", "common.updating", fallback: "Updating")
  }
  internal enum ConfirmAccountDeletion {
    internal enum Buttons {
      internal enum OpenEmail {
        /// Open "Mail"
        internal static let title = L10n.tr("Localizable", "confirm_account_deletion.buttons.open_email.title", fallback: "Open \"Mail\"")
      }
    }
    internal enum Header {
      /// Because we won’t be able to contact you after your account is deleted, we just sent you an email with important details about how and when your deletion request will be processed.
      /// 
      /// Please check your inbox now to review this important information and to confirm the final and permanent deletion of your Flexa Account.
      internal static let subtitle = L10n.tr("Localizable", "confirm_account_deletion.header.subtitle", fallback: "Because we won’t be able to contact you after your account is deleted, we just sent you an email with important details about how and when your deletion request will be processed.\n\nPlease check your inbox now to review this important information and to confirm the final and permanent deletion of your Flexa Account.")
      /// Confirm Deletion
      internal static let title = L10n.tr("Localizable", "confirm_account_deletion.header.title", fallback: "Confirm Deletion")
    }
    internal enum Table {
      internal enum Rows {
        internal enum Delete {
          /// Delete your Flexa Account
          internal static let title = L10n.tr("Localizable", "confirm_account_deletion.table.rows.delete.title", fallback: "Delete your Flexa Account")
        }
        internal enum Email {
          /// Flexa
          internal static let company = L10n.tr("Localizable", "confirm_account_deletion.table.rows.email.company", fallback: "Flexa")
          /// To: 
          internal static let to = L10n.tr("Localizable", "confirm_account_deletion.table.rows.email.to", fallback: "To: ")
        }
      }
    }
  }
  internal enum DataAndPrivacy {
    internal enum Navigation {
      /// Data & Privacy
      internal static let title = L10n.tr("Localizable", "data_and_privacy.navigation.title", fallback: "Data & Privacy")
    }
    internal enum Sections {
      internal enum Advanced {
        internal enum Cells {
          /// Export Debug Data
          internal static let exportDebugData = L10n.tr("Localizable", "data_and_privacy.sections.advanced.cells.export_debug_data", fallback: "Export Debug Data")
          /// Reset Local Flexa Storage
          internal static let resetLocalStorage = L10n.tr("Localizable", "data_and_privacy.sections.advanced.cells.reset_local_storage", fallback: "Reset Local Flexa Storage")
          /// SDK Version
          internal static let sdkVersion = L10n.tr("Localizable", "data_and_privacy.sections.advanced.cells.sdk_version", fallback: "SDK Version")
        }
        internal enum Header {
          /// Advanced
          internal static let title = L10n.tr("Localizable", "data_and_privacy.sections.advanced.header.title", fallback: "Advanced")
        }
      }
      internal enum DeleteAccount {
        internal enum Cells {
          /// Delete Your Flexa Account
          internal static let deleteAccount = L10n.tr("Localizable", "data_and_privacy.sections.delete_account.cells.delete_account", fallback: "Delete Your Flexa Account")
          internal enum DeletionPending {
            /// Please check your inbox to confirm the deletion of your Flexa Account
            internal static let subtitle = L10n.tr("Localizable", "data_and_privacy.sections.delete_account.cells.deletion_pending.subtitle", fallback: "Please check your inbox to confirm the deletion of your Flexa Account")
            /// Account Deletion Pending
            internal static let title = L10n.tr("Localizable", "data_and_privacy.sections.delete_account.cells.deletion_pending.title", fallback: "Account Deletion Pending")
          }
        }
      }
      internal enum Header {
        /// Account Email
        internal static let accountEmail = L10n.tr("Localizable", "data_and_privacy.sections.header.account_email", fallback: "Account Email")
        /// Flexa is carefully designed to use only the data that’s directly necessary to process your payments. [Learn more…](https://flexa.network/privacy/)
        internal static let description = L10n.tr("Localizable", "data_and_privacy.sections.header.description", fallback: "Flexa is carefully designed to use only the data that’s directly necessary to process your payments. [Learn more…](https://flexa.network/privacy/)")
        /// Your Data & Privacy
        internal static let title = L10n.tr("Localizable", "data_and_privacy.sections.header.title", fallback: "Your Data & Privacy")
      }
    }
  }
  internal enum DeleteAccount {
    internal enum Buttons {
      internal enum Cancel {
        /// Not Now
        internal static let title = L10n.tr("Localizable", "delete_account.buttons.cancel.title", fallback: "Not Now")
      }
      internal enum Next {
        /// Continue
        internal static let title = L10n.tr("Localizable", "delete_account.buttons.next.title", fallback: "Continue")
      }
    }
    internal enum Header {
      /// Deleting your Flexa Account will permanently erase your account and associated data from all Flexa systems and apps where you are signed in.
      /// 
      /// After your account is deleted, you will no longer be able to receive refunds back to your wallet, and any active subscriptions will be canceled.
      /// 
      /// Depending on where you live, we may not be permitted to delete all of your account data right away. We will, however, delete all of your account data as quickly as permitted by law.
      internal static let subtitle = L10n.tr("Localizable", "delete_account.header.subtitle", fallback: "Deleting your Flexa Account will permanently erase your account and associated data from all Flexa systems and apps where you are signed in.\n\nAfter your account is deleted, you will no longer be able to receive refunds back to your wallet, and any active subscriptions will be canceled.\n\nDepending on where you live, we may not be permitted to delete all of your account data right away. We will, however, delete all of your account data as quickly as permitted by law.")
      /// Delete Your Flexa Account
      internal static let title = L10n.tr("Localizable", "delete_account.header.title", fallback: "Delete Your Flexa Account")
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
    internal enum AmountEntry {
      internal enum Buttons {
        internal enum BalanceUnavailable {
          /// Balance Not Yet Available
          internal static let title = L10n.tr("Localizable", "legacy_flexcode.amount_entry.buttons.balance_unavailable.title", fallback: "Balance Not Yet Available")
        }
        internal enum EnterAmount {
          /// Enter Amount
          internal static let title = L10n.tr("Localizable", "legacy_flexcode.amount_entry.buttons.enter_amount.title", fallback: "Enter Amount")
        }
        internal enum PayNow {
          /// Confirm
          internal static let title = L10n.tr("Localizable", "legacy_flexcode.amount_entry.buttons.pay_now.title", fallback: "Confirm")
        }
      }
      internal enum Labels {
        /// Maximum Amount: %s
        internal static func maximumAmount(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "legacy_flexcode.amount_entry.labels.maximum_amount", p1, fallback: "Maximum Amount: %s")
        }
        /// Minimum Amount: %s
        internal static func minimumAmount(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "legacy_flexcode.amount_entry.labels.minimum_amount", p1, fallback: "Minimum Amount: %s")
        }
      }
    }
  }
  internal enum LegacyFlexcodeTray {
    /// More instant payments
    internal static let title = L10n.tr("Localizable", "legacy_flexcode_tray.title", fallback: "More instant payments")
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
    /// Not enough %s for this payment
    internal static func notEnough(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "payment.not_enough", p1, fallback: "Not enough %s for this payment")
    }
    /// Pay %s
    internal static func payMerchant(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "payment.pay_merchant", p1, fallback: "Pay %s")
    }
    /// Pay Now
    internal static let payNow = L10n.tr("Localizable", "payment.pay_now", fallback: "Pay Now")
    /// Using
    internal static let using = L10n.tr("Localizable", "payment.using", fallback: "Using")
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
        /// Network fee cannot be loaded
        internal static let cannotLoadNetworkFee = L10n.tr("Localizable", "payment.asset.exchange_rate.cannot_load_network_fee", fallback: "Network fee cannot be loaded")
        /// %s network fee
        internal static func networkFee(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "payment.asset.exchange_rate.network_fee", p1, fallback: "%s network fee")
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
    internal enum BalanceUnavailable {
      /// Balance Not Yet Available
      internal static let title = L10n.tr("Localizable", "payment.balance_unavailable.title", fallback: "Balance Not Yet Available")
    }
    internal enum CurrencyAvaliable {
      /// %s Available
      internal static func title(_ p1: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "payment.currency_avaliable.title", p1, fallback: "%s Available")
      }
    }
    internal enum HideShortBalances {
      /// Hide Short Balances
      internal static let title = L10n.tr("Localizable", "payment.hide_short_balances.title", fallback: "Hide Short Balances")
    }
    internal enum Message {
      /// Learn More
      internal static let button = L10n.tr("Localizable", "payment.message.button", fallback: "Learn More")
      /// Upgrade your Flexa ID for unlimited spending.
      internal static let description = L10n.tr("Localizable", "payment.message.description", fallback: "Upgrade your Flexa ID for unlimited spending.")
      /// You’re approaching your weekly spending limit.
      internal static let title = L10n.tr("Localizable", "payment.message.title", fallback: "You’re approaching your weekly spending limit.")
    }
    internal enum PayUsing {
      /// Pay Using
      internal static let title = L10n.tr("Localizable", "payment.pay_using.title", fallback: "Pay Using")
    }
    internal enum PayWithFlexa {
      /// Pay with Flexa
      internal static let title = L10n.tr("Localizable", "payment.pay_with_flexa.title", fallback: "Pay with Flexa")
    }
    internal enum Settings {
      internal enum Items {
        internal enum FindPlacesToPay {
          /// Find Places to Pay
          internal static let title = L10n.tr("Localizable", "payment.settings.items.find_places_to_pay.title", fallback: "Find Places to Pay")
        }
        internal enum Help {
          /// Help
          internal static let title = L10n.tr("Localizable", "payment.settings.items.help.title", fallback: "Help")
          internal enum Items {
            internal enum HowToPay {
              /// Learn How to Pay
              internal static let title = L10n.tr("Localizable", "payment.settings.items.help.items.how_to_pay.title", fallback: "Learn How to Pay")
            }
            internal enum ReportIssue {
              /// Report an Issue
              internal static let title = L10n.tr("Localizable", "payment.settings.items.help.items.report_issue.title", fallback: "Report an Issue")
            }
          }
        }
        internal enum ManageFlexaId {
          /// Manage Flexa Account
          internal static let title = L10n.tr("Localizable", "payment.settings.items.manage_flexa_id.title", fallback: "Manage Flexa Account")
        }
      }
    }
    internal enum TransactionDetails {
      /// Flexa automatically selects the best exchange rate and network fee for your payments. [Learn more...](https://flexa.co)
      internal static let footer = L10n.tr("Localizable", "payment.transaction_details.footer", fallback: "Flexa automatically selects the best exchange rate and network fee for your payments. [Learn more...](https://flexa.co)")
      /// Details
      internal static let title = L10n.tr("Localizable", "payment.transaction_details.title", fallback: "Details")
    }
    internal enum UsingTicker {
      /// Using %s
      internal static func subtitle(_ p1: UnsafePointer<CChar>) -> String {
        return L10n.tr("Localizable", "payment.using_ticker.subtitle", p1, fallback: "Using %s")
      }
    }
  }
  internal enum UpdatingBalance {
    /// Your recent transaction is still mining. You can spend up to **%s** now, or wait for your full balance to become available.
    internal static func text(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "updating_balance.text", p1, fallback: "Your recent transaction is still mining. You can spend up to **%s** now, or wait for your full balance to become available.")
    }
    /// Balance Updating...
    internal static let title = L10n.tr("Localizable", "updating_balance.title", fallback: "Balance Updating...")
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
