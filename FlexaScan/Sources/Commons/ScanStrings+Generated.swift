// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum ScanStrings {
  internal enum Alerts {
    internal enum SpendOptOut {
      /// If you want to use Flexa in the future, just tap the More button, and then tap Pay with Flexa.
      internal static let message = ScanStrings.tr("Localizable", "alerts.spend_opt_out.message", fallback: "If you want to use Flexa in the future, just tap the More button, and then tap Pay with Flexa.")
      /// "Pay" is Now Hidden
      internal static let title = ScanStrings.tr("Localizable", "alerts.spend_opt_out.title", fallback: "\"Pay\" is Now Hidden")
    }
  }
  internal enum Common {
    /// OK
    internal static let ok = ScanStrings.tr("Localizable", "common.ok", fallback: "OK")
    /// Undo
    internal static let undo = ScanStrings.tr("Localizable", "common.undo", fallback: "Undo")
  }
  internal enum Errors {
    internal enum CameraAccess {
      /// There was an error getting the video device
      internal static let message = ScanStrings.tr("Localizable", "errors.camera_access.message", fallback: "There was an error getting the video device")
      /// Camera error
      internal static let title = ScanStrings.tr("Localizable", "errors.camera_access.title", fallback: "Camera error")
    }
  }
  internal enum Scan {
    /// Send, pay, or connect to a desktop website
    internal static let title = ScanStrings.tr("Localizable", "scan.title", fallback: "Send, pay, or connect to a desktop website")
    internal enum Buttons {
      internal enum EnableCamera {
        /// Enable camera Access
        internal static let title = ScanStrings.tr("Localizable", "scan.buttons.enable_camera.title", fallback: "Enable camera Access")
      }
    }
  }
  internal enum SettingsMenu {
    internal enum Items {
      internal enum ManageFlexaId {
        /// Manage Flexa Account
        internal static let title = ScanStrings.tr("Localizable", "settings_menu.items.manage_flexa_id.title", fallback: "Manage Flexa Account")
      }
      internal enum PayWithFlexa {
        /// Pay with Flexa
        internal static let title = ScanStrings.tr("Localizable", "settings_menu.items.pay_with_flexa.title", fallback: "Pay with Flexa")
      }
      internal enum ReportIssue {
        /// Report an Issue
        internal static let title = ScanStrings.tr("Localizable", "settings_menu.items.report_issue.title", fallback: "Report an Issue")
      }
      internal enum ScanFromPhoto {
        /// Scan from photo
        internal static let title = ScanStrings.tr("Localizable", "settings_menu.items.scan_from_photo.title", fallback: "Scan from photo")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension ScanStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.scanBundle.stringsBundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
