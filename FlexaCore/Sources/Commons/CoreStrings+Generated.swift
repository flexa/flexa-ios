// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum CoreStrings {
  internal enum Account {
    internal enum Alerts {
      internal enum SignOut {
        /// Signing out will remove all Flexa data that is stored with %s on this device. Your wallet and your transaction history will not be affected.
        internal static func message(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "account.alerts.sign_out.message", p1, fallback: "Signing out will remove all Flexa data that is stored with %s on this device. Your wallet and your transaction history will not be affected.")
        }
        /// Sign Out of Flexa?
        internal static let title = CoreStrings.tr("Localizable", "account.alerts.sign_out.title", fallback: "Sign Out of Flexa?")
        internal enum Buttons {
          internal enum SignOut {
            /// Sign Out
            internal static let title = CoreStrings.tr("Localizable", "account.alerts.sign_out.buttons.sign_out.title", fallback: "Sign Out")
          }
        }
      }
    }
    internal enum Header {
      internal enum Labels {
        /// Joined in %s
        internal static func joinedIn(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "account.header.labels.joined_in", p1, fallback: "Joined in %s")
        }
      }
    }
    internal enum Navigation {
      /// Account
      internal static let title = CoreStrings.tr("Localizable", "account.navigation.title", fallback: "Account")
    }
    internal enum Sections {
      internal enum DataAndPrivacy {
        internal enum Cells {
          internal enum DataAndPrivacy {
            /// Data & Privacy
            internal static let title = CoreStrings.tr("Localizable", "account.sections.data_and_privacy.cells.data_and_privacy.title", fallback: "Data & Privacy")
          }
        }
      }
      internal enum Limit {
        internal enum Footer {
          /// Limits reset on %s at %s.
          internal static func title(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
            return CoreStrings.tr("Localizable", "account.sections.limit.footer.title", p1, p2, fallback: "Limits reset on %s at %s.")
          }
        }
        internal enum Header {
          /// Your Flexa Account
          internal static let title = CoreStrings.tr("Localizable", "account.sections.limit.header.title", fallback: "Your Flexa Account")
        }
      }
      internal enum SignOut {
        internal enum Cells {
          internal enum SignOut {
            /// Sign Out of Flexa
            internal static let title = CoreStrings.tr("Localizable", "account.sections.sign_out.cells.sign_out.title", fallback: "Sign Out of Flexa")
          }
        }
      }
    }
  }
  internal enum AccountBalance {
    /// %s in your Flexa Account
    internal static func title(_ p1: UnsafePointer<CChar>) -> String {
      return CoreStrings.tr("Localizable", "account_balance.title", p1, fallback: "%s in your Flexa Account")
    }
    internal enum CurrentPayment {
      /// Applied to this payment
      internal static let text = CoreStrings.tr("Localizable", "account_balance.current_payment.text", fallback: "Applied to this payment")
    }
    internal enum FullAmount {
      /// The balance of your Flexa Account
      /// will cover this payment. You don’t
      /// need to send anything else.
      internal static let text = CoreStrings.tr("Localizable", "account_balance.full_amount.text", fallback: "The balance of your Flexa Account\nwill cover this payment. You don’t\nneed to send anything else.")
    }
    internal enum NextPayment {
      /// Applied to your next payment
      internal static let text = CoreStrings.tr("Localizable", "account_balance.next_payment.text", fallback: "Applied to your next payment")
    }
    internal enum PayRemaining {
      /// PAY REMAINING %s USING
      internal static func title(_ p1: UnsafePointer<CChar>) -> String {
        return CoreStrings.tr("Localizable", "account_balance.pay_remaining.title", p1, fallback: "PAY REMAINING %s USING")
      }
    }
  }
  internal enum AssetSwitcher {
    internal enum UsingFlexaAccount {
      /// Using your Flexa Account
      internal static let title = CoreStrings.tr("Localizable", "asset_switcher.using_flexa_account.title", fallback: "Using your Flexa Account")
    }
  }
  internal enum Auth {
    internal enum MagicCode {
      internal enum Alerts {
        internal enum NoCode {
          /// The 6-digit verification code is displayed after you approve the sign-in request that was sent to your email address. If you don’t remember seeing a code, try opening your verification email again on this device.
          internal static let message = CoreStrings.tr("Localizable", "auth.magic_code.alerts.no_code.message", fallback: "The 6-digit verification code is displayed after you approve the sign-in request that was sent to your email address. If you don’t remember seeing a code, try opening your verification email again on this device.")
          /// Didn't get a code?
          internal static let title = CoreStrings.tr("Localizable", "auth.magic_code.alerts.no_code.title", fallback: "Didn't get a code?")
        }
        internal enum SignedIn {
          /// You are signed in.
          internal static let message = CoreStrings.tr("Localizable", "auth.magic_code.alerts.signed_in.message", fallback: "You are signed in.")
          /// Success!
          internal static let title = CoreStrings.tr("Localizable", "auth.magic_code.alerts.signed_in.title", fallback: "Success!")
        }
      }
      internal enum Header {
        /// Enter your Verification Code
        internal static let title = CoreStrings.tr("Localizable", "auth.magic_code.header.title", fallback: "Enter your Verification Code")
      }
      internal enum Links {
        internal enum NoCode {
          /// Didn't get a code?
          internal static let title = CoreStrings.tr("Localizable", "auth.magic_code.links.no_code.title", fallback: "Didn't get a code?")
        }
      }
      internal enum Loading {
        /// Verifying...
        internal static let text = CoreStrings.tr("Localizable", "auth.magic_code.loading.text", fallback: "Verifying...")
      }
    }
    internal enum Main {
      internal enum Buttons {
        internal enum Next {
          /// Continue
          internal static let title = CoreStrings.tr("Localizable", "auth.main.buttons.next.title", fallback: "Continue")
        }
      }
      internal enum Header {
        /// Pay with Flexa
        internal static let subtitle = CoreStrings.tr("Localizable", "auth.main.header.subtitle", fallback: "Pay with Flexa")
        /// %s invites you to
        internal static func title(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "auth.main.header.title", p1, fallback: "%s invites you to")
        }
      }
      internal enum Links {
        internal enum About {
          /// About Flexa & Privacy...
          internal static let title = CoreStrings.tr("Localizable", "auth.main.links.about.title", fallback: "About Flexa & Privacy...")
        }
      }
      internal enum Menu {
        /// Don't show again
        internal static let dontShowAgain = CoreStrings.tr("Localizable", "auth.main.menu.dont_show_again", fallback: "Don't show again")
      }
      internal enum Sections {
        internal enum Privacy {
          /// Flexa was built from the ground up to keep your personal data private.
          internal static let description = CoreStrings.tr("Localizable", "auth.main.sections.privacy.description", fallback: "Flexa was built from the ground up to keep your personal data private.")
          /// Designed for Privacy
          internal static let title = CoreStrings.tr("Localizable", "auth.main.sections.privacy.title", fallback: "Designed for Privacy")
        }
        internal enum Spend {
          /// Use your assets at thousands of places—with no card required.
          internal static let description = CoreStrings.tr("Localizable", "auth.main.sections.spend.description", fallback: "Use your assets at thousands of places—with no card required.")
          /// Spend How You Want
          internal static let title = CoreStrings.tr("Localizable", "auth.main.sections.spend.title", fallback: "Spend How You Want")
        }
      }
      internal enum Textfields {
        internal enum Email {
          /// What’s your email address?
          internal static let placeholder = CoreStrings.tr("Localizable", "auth.main.textfields.email.placeholder", fallback: "What’s your email address?")
        }
      }
    }
    internal enum PersonalInfo {
      internal enum Buttons {
        internal enum About {
          /// About Flexa & Privacy...
          internal static let title = CoreStrings.tr("Localizable", "auth.personal_info.buttons.about.title", fallback: "About Flexa & Privacy...")
        }
        internal enum Next {
          /// Get Started
          internal static let title = CoreStrings.tr("Localizable", "auth.personal_info.buttons.next.title", fallback: "Get Started")
        }
      }
      internal enum Header {
        /// Please provide a few details to start making payments with Flexa.
        internal static let subtitle = CoreStrings.tr("Localizable", "auth.personal_info.header.subtitle", fallback: "Please provide a few details to start making payments with Flexa.")
        /// Create your
        /// Flexa Account
        internal static let title = CoreStrings.tr("Localizable", "auth.personal_info.header.title", fallback: "Create your\nFlexa Account")
      }
      internal enum Sections {
        /// The information you provide is used only to comply with local financial regulations, and will never be shared with %s or any of the businesses you pay. By creating an account, you agree to Flexa’s [Terms of Service](https://flexa.co/legal/terms).
        internal static func termsOfService(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "auth.personal_info.sections.terms_of_service", p1, fallback: "The information you provide is used only to comply with local financial regulations, and will never be shared with %s or any of the businesses you pay. By creating an account, you agree to Flexa’s [Terms of Service](https://flexa.co/legal/terms).")
        }
      }
      internal enum Textfields {
        internal enum DateOfBirth {
          /// Date of Birth
          internal static let placeholder = CoreStrings.tr("Localizable", "auth.personal_info.textfields.date_of_birth.placeholder", fallback: "Date of Birth")
        }
        internal enum FamilyName {
          /// Family Name
          internal static let placeholder = CoreStrings.tr("Localizable", "auth.personal_info.textfields.family_name.placeholder", fallback: "Family Name")
        }
        internal enum FullName {
          /// Your Name
          internal static let placeholder = CoreStrings.tr("Localizable", "auth.personal_info.textfields.full_name.placeholder", fallback: "Your Name")
        }
        internal enum GivenName {
          /// Given Name
          internal static let placeholder = CoreStrings.tr("Localizable", "auth.personal_info.textfields.given_name.placeholder", fallback: "Given Name")
        }
      }
    }
    internal enum Privacy {
      internal enum Alerts {
        internal enum About {
          /// Flexa uses your email address to sign you in and send you receipts for your payments. Your email address is never shared with %s or any other business.
          internal static func message(_ p1: UnsafePointer<CChar>) -> String {
            return CoreStrings.tr("Localizable", "auth.privacy.alerts.about.message", p1, fallback: "Flexa uses your email address to sign you in and send you receipts for your payments. Your email address is never shared with %s or any other business.")
          }
          /// Email Address Privacy
          internal static let title = CoreStrings.tr("Localizable", "auth.privacy.alerts.about.title", fallback: "Email Address Privacy")
        }
      }
    }
    internal enum RestrictedRegion {
      internal enum Header {
        /// Federal law prevents Flexa from making its services available in some regions. For more information, please contact Flexa support.
        internal static let subtitle = CoreStrings.tr("Localizable", "auth.restricted_region.header.subtitle", fallback: "Federal law prevents Flexa from making its services available in some regions. For more information, please contact Flexa support.")
        /// Pay with Flexa is not available in your region.
        internal static let title = CoreStrings.tr("Localizable", "auth.restricted_region.header.title", fallback: "Pay with Flexa is not available in your region.")
      }
    }
    internal enum VerifyEmail {
      internal enum Buttons {
        internal enum OpenEmail {
          /// Open "Mail"
          internal static let title = CoreStrings.tr("Localizable", "auth.verify_email.buttons.open_email.title", fallback: "Open \"Mail\"")
        }
      }
      internal enum Header {
        internal enum SignIn {
          /// Check your inbox and tap the link we just sent you to finish signing in.
          internal static let subtitle = CoreStrings.tr("Localizable", "auth.verify_email.header.sign_in.subtitle", fallback: "Check your inbox and tap the link we just sent you to finish signing in.")
          /// Sign in to Flexa
          internal static let title = CoreStrings.tr("Localizable", "auth.verify_email.header.sign_in.title", fallback: "Sign in to Flexa")
        }
        internal enum SignUp {
          /// Just one more step. Check your inbox and tap the link we sent you to verify your email address.
          internal static let subtitle = CoreStrings.tr("Localizable", "auth.verify_email.header.sign_up.subtitle", fallback: "Just one more step. Check your inbox and tap the link we sent you to verify your email address.")
          /// Verify your Email Address
          internal static let title = CoreStrings.tr("Localizable", "auth.verify_email.header.sign_up.title", fallback: "Verify your Email Address")
        }
      }
      internal enum Loading {
        /// Verifying...
        internal static let text = CoreStrings.tr("Localizable", "auth.verify_email.loading.text", fallback: "Verifying...")
      }
      internal enum Table {
        internal enum Rows {
          internal enum Email {
            /// Flexa
            internal static let company = CoreStrings.tr("Localizable", "auth.verify_email.table.rows.email.company", fallback: "Flexa")
            /// To: 
            internal static let to = CoreStrings.tr("Localizable", "auth.verify_email.table.rows.email.to", fallback: "To: ")
          }
          internal enum SignIn {
            /// Sign in to Flexa
            internal static let title = CoreStrings.tr("Localizable", "auth.verify_email.table.rows.sign_in.title", fallback: "Sign in to Flexa")
          }
          internal enum SignUp {
            /// Verify your email address
            internal static let title = CoreStrings.tr("Localizable", "auth.verify_email.table.rows.sign_up.title", fallback: "Verify your email address")
          }
        }
      }
    }
  }
  internal enum ConfirmAccountDeletion {
    internal enum Buttons {
      internal enum OpenEmail {
        /// Open "Mail"
        internal static let title = CoreStrings.tr("Localizable", "confirm_account_deletion.buttons.open_email.title", fallback: "Open \"Mail\"")
      }
    }
    internal enum Header {
      /// Because we won’t be able to contact you after your account is deleted, we just sent you an email with important details about how and when your deletion request will be processed.
      /// 
      /// Please check your inbox now to review this important information and to confirm the final and permanent deletion of your Flexa Account.
      internal static let subtitle = CoreStrings.tr("Localizable", "confirm_account_deletion.header.subtitle", fallback: "Because we won’t be able to contact you after your account is deleted, we just sent you an email with important details about how and when your deletion request will be processed.\n\nPlease check your inbox now to review this important information and to confirm the final and permanent deletion of your Flexa Account.")
      /// Confirm Deletion
      internal static let title = CoreStrings.tr("Localizable", "confirm_account_deletion.header.title", fallback: "Confirm Deletion")
    }
    internal enum Table {
      internal enum Rows {
        internal enum Delete {
          /// Delete your Flexa Account
          internal static let title = CoreStrings.tr("Localizable", "confirm_account_deletion.table.rows.delete.title", fallback: "Delete your Flexa Account")
        }
        internal enum Email {
          /// Flexa
          internal static let company = CoreStrings.tr("Localizable", "confirm_account_deletion.table.rows.email.company", fallback: "Flexa")
          /// To: 
          internal static let to = CoreStrings.tr("Localizable", "confirm_account_deletion.table.rows.email.to", fallback: "To: ")
        }
      }
    }
  }
  internal enum DataAndPrivacy {
    internal enum Navigation {
      /// Data & Privacy
      internal static let title = CoreStrings.tr("Localizable", "data_and_privacy.navigation.title", fallback: "Data & Privacy")
    }
    internal enum Sections {
      internal enum Advanced {
        internal enum Cells {
          /// Export Debug Data
          internal static let exportDebugData = CoreStrings.tr("Localizable", "data_and_privacy.sections.advanced.cells.export_debug_data", fallback: "Export Debug Data")
          /// Reset Local Flexa Storage
          internal static let resetLocalStorage = CoreStrings.tr("Localizable", "data_and_privacy.sections.advanced.cells.reset_local_storage", fallback: "Reset Local Flexa Storage")
          /// SDK Version
          internal static let sdkVersion = CoreStrings.tr("Localizable", "data_and_privacy.sections.advanced.cells.sdk_version", fallback: "SDK Version")
        }
        internal enum Header {
          /// Advanced
          internal static let title = CoreStrings.tr("Localizable", "data_and_privacy.sections.advanced.header.title", fallback: "Advanced")
        }
      }
      internal enum DeleteAccount {
        internal enum Cells {
          /// Delete Your Flexa Account
          internal static let deleteAccount = CoreStrings.tr("Localizable", "data_and_privacy.sections.delete_account.cells.delete_account", fallback: "Delete Your Flexa Account")
          internal enum DeletionPending {
            /// Please check your inbox to confirm the deletion of your Flexa Account
            internal static let subtitle = CoreStrings.tr("Localizable", "data_and_privacy.sections.delete_account.cells.deletion_pending.subtitle", fallback: "Please check your inbox to confirm the deletion of your Flexa Account")
            /// Account Deletion Pending
            internal static let title = CoreStrings.tr("Localizable", "data_and_privacy.sections.delete_account.cells.deletion_pending.title", fallback: "Account Deletion Pending")
          }
        }
      }
      internal enum Header {
        /// Account Email
        internal static let accountEmail = CoreStrings.tr("Localizable", "data_and_privacy.sections.header.account_email", fallback: "Account Email")
        /// Flexa is carefully designed to use only the data that’s directly necessary to process your payments. [Learn more…](https://flexa.co/legal/privacy)
        internal static let description = CoreStrings.tr("Localizable", "data_and_privacy.sections.header.description", fallback: "Flexa is carefully designed to use only the data that’s directly necessary to process your payments. [Learn more…](https://flexa.co/legal/privacy)")
        /// Your Data & Privacy
        internal static let title = CoreStrings.tr("Localizable", "data_and_privacy.sections.header.title", fallback: "Your Data & Privacy")
      }
    }
  }
  internal enum DeleteAccount {
    internal enum Buttons {
      internal enum Cancel {
        /// Not Now
        internal static let title = CoreStrings.tr("Localizable", "delete_account.buttons.cancel.title", fallback: "Not Now")
      }
      internal enum Next {
        /// Continue
        internal static let title = CoreStrings.tr("Localizable", "delete_account.buttons.next.title", fallback: "Continue")
      }
    }
    internal enum Header {
      /// Deleting your Flexa Account will permanently erase your account and associated data from all Flexa systems and apps where you are signed in.
      /// 
      /// After your account is deleted, you will no longer be able to receive refunds back to your wallet, and any active subscriptions will be canceled.
      /// 
      /// Depending on where you live, we may not be permitted to delete all of your account data right away. We will, however, delete all of your account data as quickly as permitted by law.
      internal static let subtitle = CoreStrings.tr("Localizable", "delete_account.header.subtitle", fallback: "Deleting your Flexa Account will permanently erase your account and associated data from all Flexa systems and apps where you are signed in.\n\nAfter your account is deleted, you will no longer be able to receive refunds back to your wallet, and any active subscriptions will be canceled.\n\nDepending on where you live, we may not be permitted to delete all of your account data right away. We will, however, delete all of your account data as quickly as permitted by law.")
      /// Delete Your Flexa Account
      internal static let title = CoreStrings.tr("Localizable", "delete_account.header.title", fallback: "Delete Your Flexa Account")
    }
  }
  internal enum Errors {
    internal enum Default {
      /// We’re sorry, we encountered a problem while connecting to Flexa. You can submit a report to help us fix the problem, or simply try again later.
      internal static let message = CoreStrings.tr("Localizable", "errors.default.message", fallback: "We’re sorry, we encountered a problem while connecting to Flexa. You can submit a report to help us fix the problem, or simply try again later.")
      /// Something went wrong.
      internal static let title = CoreStrings.tr("Localizable", "errors.default.title", fallback: "Something went wrong.")
    }
    internal enum InvalidValue {
      /// Invalid value.
      internal static let message = CoreStrings.tr("Localizable", "errors.invalid_value.message", fallback: "Invalid value.")
      /// Invalid value
      internal static let title = CoreStrings.tr("Localizable", "errors.invalid_value.title", fallback: "Invalid value")
    }
    internal enum Unimplemented {
      /// This feature is not available yet.
      internal static let message = CoreStrings.tr("Localizable", "errors.unimplemented.message", fallback: "This feature is not available yet.")
      /// Soon
      internal static let title = CoreStrings.tr("Localizable", "errors.unimplemented.title", fallback: "Soon")
    }
    internal enum Unknown {
      /// Unknown error occured.
      internal static let message = CoreStrings.tr("Localizable", "errors.unknown.message", fallback: "Unknown error occured.")
      /// An error has occurred
      internal static let title = CoreStrings.tr("Localizable", "errors.unknown.title", fallback: "An error has occurred")
    }
  }
  internal enum Global {
    /// Back
    internal static let back = CoreStrings.tr("Localizable", "global.back", fallback: "Back")
    /// Cancel
    internal static let cancel = CoreStrings.tr("Localizable", "global.cancel", fallback: "Cancel")
    /// Close
    internal static let close = CoreStrings.tr("Localizable", "global.close", fallback: "Close")
    /// Done
    internal static let done = CoreStrings.tr("Localizable", "global.done", fallback: "Done")
    /// flexa
    internal static let flexa = CoreStrings.tr("Localizable", "global.flexa", fallback: "flexa")
    /// OK
    internal static let ok = CoreStrings.tr("Localizable", "global.ok", fallback: "OK")
    /// Sending...
    internal static let sending = CoreStrings.tr("Localizable", "global.sending", fallback: "Sending...")
    /// Signing...
    internal static let signing = CoreStrings.tr("Localizable", "global.signing", fallback: "Signing...")
  }
  internal enum LegacyFlexcode {
    /// Flexa loves you <3
    internal static let preventScreenshotText = CoreStrings.tr("Localizable", "legacy_flexcode.prevent_screenshot_text", fallback: "Flexa loves you <3")
    internal enum AmountEntry {
      internal enum Buttons {
        internal enum BalanceUnavailable {
          /// Balance Not Yet Available
          internal static let title = CoreStrings.tr("Localizable", "legacy_flexcode.amount_entry.buttons.balance_unavailable.title", fallback: "Balance Not Yet Available")
        }
        internal enum Payment {
          internal enum Confirm {
            /// Confirm
            internal static let title = CoreStrings.tr("Localizable", "legacy_flexcode.amount_entry.buttons.payment.confirm.title", fallback: "Confirm")
          }
          internal enum EnterAmount {
            /// Enter Amount
            internal static let title = CoreStrings.tr("Localizable", "legacy_flexcode.amount_entry.buttons.payment.enter_amount.title", fallback: "Enter Amount")
          }
        }
      }
      internal enum Labels {
        /// Maximum Amount: %s
        internal static func maximumAmount(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "legacy_flexcode.amount_entry.labels.maximum_amount", p1, fallback: "Maximum Amount: %s")
        }
        /// Minimum Amount: %s
        internal static func minimumAmount(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "legacy_flexcode.amount_entry.labels.minimum_amount", p1, fallback: "Minimum Amount: %s")
        }
      }
    }
    internal enum Promotions {
      internal enum Labels {
        /// Saving %s
        internal static func saving(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "legacy_flexcode.promotions.labels.saving", p1, fallback: "Saving %s")
        }
      }
    }
  }
  internal enum Log {
    internal enum Hidden {
      /// [hidden value]
      internal static let text = CoreStrings.tr("Localizable", "log.hidden.text", fallback: "[hidden value]")
    }
  }
  internal enum NavigationMenu {
    internal enum Settings {
      internal enum Items {
        internal enum FindPlacesToPay {
          /// Find Places to Pay
          internal static let title = CoreStrings.tr("Localizable", "navigation_menu.settings.items.find_places_to_pay.title", fallback: "Find Places to Pay")
        }
        internal enum Help {
          /// Help
          internal static let title = CoreStrings.tr("Localizable", "navigation_menu.settings.items.help.title", fallback: "Help")
          internal enum Items {
            internal enum HowToPay {
              /// Learn How to Pay
              internal static let title = CoreStrings.tr("Localizable", "navigation_menu.settings.items.help.items.how_to_pay.title", fallback: "Learn How to Pay")
            }
            internal enum ReportIssue {
              /// Report an Issue
              internal static let title = CoreStrings.tr("Localizable", "navigation_menu.settings.items.help.items.report_issue.title", fallback: "Report an Issue")
            }
          }
        }
        internal enum ManageFlexaId {
          /// Manage Flexa Account
          internal static let title = CoreStrings.tr("Localizable", "navigation_menu.settings.items.manage_flexa_id.title", fallback: "Manage Flexa Account")
        }
      }
    }
  }
  internal enum Payment {
    /// Done
    internal static let done = CoreStrings.tr("Localizable", "payment.done", fallback: "Done")
    /// Not enough %s for this payment
    internal static func notEnough(_ p1: UnsafePointer<CChar>) -> String {
      return CoreStrings.tr("Localizable", "payment.not_enough", p1, fallback: "Not enough %s for this payment")
    }
    /// Pay %s
    internal static func payMerchant(_ p1: UnsafePointer<CChar>) -> String {
      return CoreStrings.tr("Localizable", "payment.pay_merchant", p1, fallback: "Pay %s")
    }
    /// Pay Now
    internal static let payNow = CoreStrings.tr("Localizable", "payment.pay_now", fallback: "Pay Now")
    /// Using
    internal static let using = CoreStrings.tr("Localizable", "payment.using", fallback: "Using")
    internal enum Asset {
      internal enum ExchangeRate {
        /// %s %s
        internal static func amount(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "payment.asset.exchange_rate.amount", p1, p2, fallback: "%s %s")
        }
        /// Network fee cannot be loaded
        internal static let cannotLoadNetworkFee = CoreStrings.tr("Localizable", "payment.asset.exchange_rate.cannot_load_network_fee", fallback: "Network fee cannot be loaded")
        /// Free
        internal static let free = CoreStrings.tr("Localizable", "payment.asset.exchange_rate.free", fallback: "Free")
        /// Less than %s network fee
        internal static func lessThanMinNetworkFee(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "payment.asset.exchange_rate.less_than_min_network_fee", p1, fallback: "Less than %s network fee")
        }
        /// %s network fee
        internal static func networkFee(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "payment.asset.exchange_rate.network_fee", p1, fallback: "%s network fee")
        }
        /// 1 %s = %s
        internal static func value(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "payment.asset.exchange_rate.value", p1, p2, fallback: "1 %s = %s")
        }
      }
    }
    internal enum Balance {
      /// %s Balance
      internal static func title(_ p1: UnsafePointer<CChar>) -> String {
        return CoreStrings.tr("Localizable", "payment.balance.title", p1, fallback: "%s Balance")
      }
    }
    internal enum BalanceUnavailable {
      /// Balance Not Yet Available
      internal static let title = CoreStrings.tr("Localizable", "payment.balance_unavailable.title", fallback: "Balance Not Yet Available")
    }
    internal enum CurrencyAvaliable {
      /// %s Available
      internal static func title(_ p1: UnsafePointer<CChar>) -> String {
        return CoreStrings.tr("Localizable", "payment.currency_avaliable.title", p1, fallback: "%s Available")
      }
    }
    internal enum HideShortBalances {
      /// Hide Short Balances
      internal static let title = CoreStrings.tr("Localizable", "payment.hide_short_balances.title", fallback: "Hide Short Balances")
    }
    internal enum PayUsing {
      /// Pay Using
      internal static let title = CoreStrings.tr("Localizable", "payment.pay_using.title", fallback: "Pay Using")
    }
    internal enum TransactionDetails {
      /// Flexa automatically selects the best exchange rate and network fee for your payments. [Learn more...](https://flexa.co)
      internal static let footer = CoreStrings.tr("Localizable", "payment.transaction_details.footer", fallback: "Flexa automatically selects the best exchange rate and network fee for your payments. [Learn more...](https://flexa.co)")
      /// Details
      internal static let title = CoreStrings.tr("Localizable", "payment.transaction_details.title", fallback: "Details")
    }
    internal enum UsingTicker {
      /// Using %s
      internal static func subtitle(_ p1: UnsafePointer<CChar>) -> String {
        return CoreStrings.tr("Localizable", "payment.using_ticker.subtitle", p1, fallback: "Using %s")
      }
    }
    internal enum YourFlexaAccount {
      /// Your Flexa Account
      internal static let title = CoreStrings.tr("Localizable", "payment.your_flexa_account.title", fallback: "Your Flexa Account")
    }
  }
  internal enum UpdatingBalance {
    /// Your recent transaction is still mining.
    /// You can spend up to **%s** now, or wait for your full balance to become available.
    internal static func text(_ p1: UnsafePointer<CChar>) -> String {
      return CoreStrings.tr("Localizable", "updating_balance.text", p1, fallback: "Your recent transaction is still mining.\nYou can spend up to **%s** now, or wait for your full balance to become available.")
    }
    /// Balance Updating...
    internal static let title = CoreStrings.tr("Localizable", "updating_balance.title", fallback: "Balance Updating...")
  }
  internal enum WebLinks {
    /// https://flexa.co/guides/how-to-pay
    internal static let howToPay = CoreStrings.tr("Localizable", "web_links.how_to_pay", fallback: "https://flexa.co/guides/how-to-pay")
    /// https://%@/directory
    internal static func merchantList(_ p1: Any) -> String {
      return CoreStrings.tr("Localizable", "web_links.merchant_list", String(describing: p1), fallback: "https://%@/directory")
    }
    /// %@/%@/locations
    internal static func merchantLocations(_ p1: Any, _ p2: Any) -> String {
      return CoreStrings.tr("Localizable", "web_links.merchant_locations", String(describing: p1), String(describing: p2), fallback: "%@/%@/locations")
    }
    /// https://flexa.co/legal/privacy
    internal static let privacy = CoreStrings.tr("Localizable", "web_links.privacy", fallback: "https://flexa.co/legal/privacy")
    /// https://flexa.co/report-an-issue
    internal static let reportIssue = CoreStrings.tr("Localizable", "web_links.report_issue", fallback: "https://flexa.co/report-an-issue")
  }
  internal enum Webview {
    internal enum Buttons {
      internal enum Retry {
        /// Retry
        internal static let title = CoreStrings.tr("Localizable", "webview.buttons.retry.title", fallback: "Retry")
      }
    }
    internal enum Errors {
      internal enum Load {
        /// Cannot load page
        internal static let title = CoreStrings.tr("Localizable", "webview.errors.load.title", fallback: "Cannot load page")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension CoreStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.coreBundle.stringsBundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
