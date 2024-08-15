# Flexa SDK for iOS

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen)](http://cocoapods.org/)
[![SwiftUI compatible](https://img.shields.io/badge/SwiftUI-compatible-brightgreen)](https://developer.apple.com/documentation/swiftui)
[![UIKit compatible](https://img.shields.io/badge/UIKit-compatible-brightgreen)](https://developer.apple.com/documentation/uikit)
![GitHub License](https://img.shields.io/github/license/flexa/flexa-ios)

With Flexa SDK, you can quickly and easily add new layers of functionality to your wallet app.

In the current release, Flexa offers a privacy-focused payments experience for in-person and online spending anywhere Flexa is accepted (Flexa Spend), along with a simple scanner module for parsing QR code–formatted payment requests (Flexa Scan).

## Modules

| Module        | Description                                            |
| ------------- | ------------------------------------------------------ |
| Flexa         | Core functionality required by all other modules       |
| FlexaScan     | Camera-based parsing of QR codes for payments and more |
| FlexaSpend    | Instant retail payments, powered by Flexa              |

## Releases

Flexa SDK is supported via CocoaPods and Swift Package Manager.

### To install via Swift Package Manager

The simplest way to install Flexa is by adding the Swift package directly from https://github.com/flexa/flexa-ios.git

Alternatively, you can directly update Package.swift with this dependency:

```swift
dependencies: [
    .package(url: "https://github.com/flexa/flexa-ios.git", from: "0.0.1")
]
```

And then add the `Flexa` dependency to the relevant targets:

```swift
.target(
  name: ...,
  dependencies: [
    .product(name: "Flexa", package: "flexa-ios"),
  ]
)
```

### To install via CocoaPods

Add the following to your Podfile:

```ruby
source 'git@github.com:flexa/flexa-cocoapods.git'

pod 'Flexa'
```

## Requirements

Flexa SDK for iOS requires Xcode 15 or later and is compatible with apps that target iOS 15 or above.

## Integration

### Permissions

If you choose to enable Flexa Scan, you must also request permission to the **Camera** by providing `Privacy - Camera Usage Description` in `Info.plist`. We recommend using a simple, one-sentence description, such as:
“Allow camera access so that you can scan barcodes for payments.”

### Authentication

Flexa SDK requires your app to embed a valid publishable key, which will enable it to communicate with Flexa in order to request details of currently supported assets, the equivalent US dollar (or other local currency) balances for your user’s assets, and payment session details whenever a payment is initiated.

To obtain your publishable key, please contact a member of the Flexa team.

### Initialization for SwiftUI–based applications

1. Import the **Flexa** module in your main application file:

```swift
import Flexa
```

2. Gather the current balances of all assets available in your user’s wallet accounts:

```swift
struct FXAvailableAsset {
    let accentColor: UIColor?
    let assetId: String
    let balance: Decimal
    let displayName: String?
    let icon: UIImage
    let symbol: String?
}

 struct FXAppAccount {
    let accountId: String
    let displayName: String
    let icon: UIImage?
    let availableAssets: [FXAvailableAsset]
}
```

3. Initialize **Flexa**, typically in your application initializer:

```swift
@main
struct YourApp: App {
    init() {
        Flexa.initialize(
            FXClient(
                publishableKey: "{YOUR_PUBLISHABLE_KEY}",
                appAccounts: [FXAppAccount],
                theme: .default
            )
        )
    }

    var body: some Scene {
        ...
    }

```

### Initialization for UIKit-based applications

1. Import the **Flexa** module in your `UIApplicationDelegate`:

```swift
import Flexa
```

2. Gather the current balances of all assets available in your user’s wallet accounts:

```swift
struct FXAvailableAsset {
    let accentColor: UIColor?
    let assetId: String
    let balance: Decimal
    let displayName: String?
    let icon: UIImage
    let symbol: String?
}

 struct FXAppAccount {
    let accountId: String
    let displayName: String
    let icon: UIImage?
    let availableAssets: [FXAvailableAsset]
}
```

3. Initialize **Flexa**, typically in your app's `application:didFinishLaunchingWithOptions`:

```swift
Flexa.initialize(FXClient(
    publishableKey: "{YOUR_PUBLISHABLE_KEY}",
    appAccounts: [FXAppAccount],
    theme: .default)
)
```

### Universal Links
Currently Flexa allows to use universal links to speed up the sign in/sign up process
For Universal Link handling the SDK provides the `processUniversalLink` method:
```swift
static func processUniversalLink(url: UR) -> Bool
```

The `url` parameter should contain the universal link received, and the method will return `true` if the SDK can handle the Universal Link and `false` otherwise (and parent apps could choose if they process the link in a different way)

**Configuration**
In order to allow Universal Links the parent app should be configured properly and should include  the next associated domains:

```swift
applinks:{YOUR_APP_NAME}.flexa.link
```

### UIKit based applications

On your `AppDelegate` implement:

```swift
func application(
  _ application: UIApplication,
  continue userActivity: NSUserActivity,
  restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
  guard let url = userActivity.webpageURL else {
    return false
  }
  return Flexa.processUniversalLink(url: url)
}
```

### SwiftUI based applications

```swift
@main
struct SPMApp: App {
    init() {
        Flexa.initialize(
            ...
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Flexa.processUniversalLink(url: url)
                }
        }
    }
}
```

### Usage

```swift
// Open Flexa
Flexa.sections([.spend])
    .appAccounts(appAccounts) // Optional
    .selectedAsset(selectedAccountId, selectedAssetId) // Optional
    .onTransactionRequest(onTransactionRequest)
    .open()

// Callback handler
func onTransactionRequest(result: Result<FXTransaction, Error>) {
    debugPrint(result)
    switch result {
    case .success(let transaction):
        // Sign and send the transaction
        // Once the transaction is sent the parent application can pass the signature (String) to Flexa through Flexa.transactionSent
        let signature = ...
        Flexa.transactionSent(commerceSessionId: transaction.commerceSessionId, signature: signature)
    default:
        break
    }
}
```

The `FXTransaction` struct:
```swift
/// Represents a Transaction to be made
///
/// Flexa will pass back a Transaction object to the parent application in order to be reviewed, signed and sent
public struct FXTransaction {
    /// The Commerce Sessions identifier associated to the transaction
    public let commerceSessionId: String
    /// Amount of the transaction
    public let amount: String
    /// The appAccountId the funds will be taken from
    public let appAccountId: String
    /// The appAccounts's asset that must be used
    public let assetId: String
    /// Destination address of the transaction
    public let destinationAddress: String
    /// Calculated fee amount
    public let feeAmount: String
    /// The fee assetId, ETH for Ethereum, BTC for bitcoin network etc
    public let feeAssetId: String
    /// Fee price. Gas price on Ethereum, or the sats/vByte fee on Bitcoin
    public let feePrice: String
    /// Priority fee amount (Ethereum only)
    public let feePriorityPrice: String?
    /// Gas limit (Ethereum only)
    public let size: String?
    // Brand'fields
    public let brandLogo, brandName, brandColor: String?
}
```

A builder pattern is used to configure and open Flexa:

- `sections`: allows you to specify the different Components to be displayed.
- `appAccounts`: sets the user's app accounts
- `selectedAsset`: selects a default app account's asset to be used on future transactions
- `onTransactionRequest`: is called when Flexa has all the information about a transaction and needs the parent application to send it. In this callback parent applications should do any validation and send the transaction. Once the transaction is sent the parent application can pass the transaction's signature to Flexa through `Flexa.transactionSent`.
- `open`: opens Flexa's main screen


## Privacy

Flexa will **never** attempt to access your users’ private keys, wallet addresses, a history of any actions taken in-app, or other sensitive wallet details. There is no method that enables you to provide any of this information to Flexa SDK, and Flexa SDK does not automatically extract any of this information from your app.

In order to enable payments for your users, federal regulations require Flexa to collect some personal information. This information typically consists of a user’s full name and date of birth. For higher-value payments, it can also include a photo ID document and photograph. This information is used only for verification purposes, and Flexa will never share this information with you or with any of the business your users pay.

Please note that making any modifications to your app or any of Flexa’s code with the intent to gather, retain, or otherwise access this personal information is expressly prohibited by the Flexa Developer Agreement, and will result in a permanent ban from using Flexa software for your business and any related individuals.

## Contributing

We welcome and appreciate contributions to Flexa SDK from the open source community.

- For larger changes, please open an issue describing your objectives so that we can coordinate efforts.
- Or, if you would like to make a minor edit (such as a single-line modification or to fix a typo), please feel free to open a pull request with your changes and we will review it promptly.

## License

Flexa SDK for iOS is [available under the MIT License](LICENSE).
