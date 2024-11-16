// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flexa",
    defaultLocalization: LanguageTag("en"),
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Flexa",
            targets: ["Flexa"]),
        .library(
            name: "FlexaCore",
            targets: ["FlexaCore"]),
        .library(
            name: "FlexaScan",
            targets: ["FlexaScan"]),
        .library(
            name: "FlexaLoad",
            targets: ["FlexaLoad"]),
        .library(
            name: "FlexaSpend",
            targets: ["FlexaSpend"]),
        .library(
            name: "FlexaUICore",
            targets: ["FlexaUICore"]),
        .library(
            name: "FlexaNetworking",
            targets: ["FlexaNetworking"]),
        .plugin(name: "SwiftLintPlugin", targets: ["SwiftLintPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.0.0"),
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "5.0.0"),
        .package(url: "https://github.com/exyte/SVGView.git", from: "1.0.4"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.2.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/vadymmarkov/Fakery.git", from: "5.1.0"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
        .package(url: "https://github.com/ekscrypto/Base32.git", from: "1.2.0")
    ],
    targets: [
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.55.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "722a705de1cf4e0e07f2b7d2f9f631f3a8b2635a0c84cce99f9677b38aa4a1d6"
        ),
        .target(
            name: "Flexa",
            dependencies: ["FlexaCore", "FlexaScan", "FlexaLoad", "FlexaSpend", "FlexaUICore"],
            path: "Sources",
            plugins: ["SwiftLintPlugin"]),
        .testTarget(
            name: "FlexaTests",
            dependencies: ["FlexaCore", "Flexa"],
            path: "Tests",
            plugins: ["SwiftLintPlugin"]),
        .target(
            name: "FlexaCore",
            dependencies: [
                "FlexaNetworking",
                "Factory",
                "DeviceKit",
                "KeychainAccess",
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")
            ],
            path: "FlexaCore/Sources",
            plugins: ["SwiftLintPlugin"]),
        .testTarget(
            name: "FlexaCoreTests",
            dependencies: ["FlexaCore", "Nimble", "Quick", "Fakery"],
            path: "FlexaCore/Tests",
            plugins: ["SwiftLintPlugin"]),
        .target(
            name: "FlexaUICore",
            dependencies: [
                "FlexaCore",
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")
            ],
            path: "FlexaUICore/Sources",
            plugins: ["SwiftLintPlugin"]),
        .testTarget(
            name: "FlexaUICoreTests",
            dependencies: [
                "FlexaUICore",
                "FlexaCore",
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")
            ],
            path: "FlexaUICore/Tests",
            plugins: ["SwiftLintPlugin"]),
        .target(
            name: "FlexaScan",
            dependencies: ["FlexaCore"],
            path: "FlexaScan/Sources",
            plugins: ["SwiftLintPlugin"]),
        .testTarget(
            name: "FlexaScanTests",
            dependencies: ["FlexaCore", "FlexaScan"],
            path: "FlexaScan/Tests",
            plugins: ["SwiftLintPlugin"]),
        .target(
            name: "FlexaLoad",
            dependencies: ["FlexaCore"],
            path: "FlexaLoad/Sources",
            plugins: ["SwiftLintPlugin"]),
        .testTarget(
            name: "FlexaLoadTests",
            dependencies: ["FlexaCore", "FlexaLoad"],
            path: "FlexaLoad/Tests",
            plugins: ["SwiftLintPlugin"]),
        .target(
            name: "FlexaSpend",
            dependencies: ["FlexaCore", "FlexaUICore", "SVGView", "Factory", "Base32"],
            path: "FlexaSpend/Sources",
            resources: [.process("Resources")],
            plugins: ["SwiftLintPlugin", .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")]),
        .testTarget(
            name: "FlexaSpendTests",
            dependencies: ["FlexaCore", "FlexaSpend", "FlexaUICore", "SVGView", "Nimble", "Quick", "Fakery"],
            path: "FlexaSpend/Tests",
            plugins: ["SwiftLintPlugin"]),
        .target(
            name: "FlexaNetworking",
            dependencies: ["Factory"],
            path: "FlexaNetworking/Sources",
            plugins: ["SwiftLintPlugin"]),
        .testTarget(
            name: "FlexaNetworkingTests",
            dependencies: ["FlexaNetworking", "Factory", "Nimble", "Quick", "Fakery"],
            path: "FlexaNetworking/Tests",
            plugins: ["SwiftLintPlugin"]),
        .plugin(
            name: "SwiftLintPlugin",
            capability: .buildTool(),
            dependencies: [.target(name: "SwiftLintBinary")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
