// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum CoreStrings {
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
        /// The information you provide is used only to comply with local financial regulations, and will never be shared with %s or any of the businesses you pay. By creating an account, you agree to Flexa’s [Terms of Service](https://flexa.network/legal/terms).
        internal static func termsOfService(_ p1: UnsafePointer<CChar>) -> String {
          return CoreStrings.tr("Localizable", "auth.personal_info.sections.terms_of_service", p1, fallback: "The information you provide is used only to comply with local financial regulations, and will never be shared with %s or any of the businesses you pay. By creating an account, you agree to Flexa’s [Terms of Service](https://flexa.network/legal/terms).")
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
  internal enum Global {
    /// Back
    internal static let back = CoreStrings.tr("Localizable", "global.back", fallback: "Back")
    /// OK
    internal static let ok = CoreStrings.tr("Localizable", "global.ok", fallback: "OK")
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
