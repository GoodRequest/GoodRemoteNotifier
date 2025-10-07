// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoodRemoteNotifier",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GoodRemoteNotifier",
            targets: ["GoodRemoteNotifier"]
        )
    ],
    targets: [
        .target(
            name: "GoodRemoteNotifier",
            dependencies: [],
            path: "./Sources/GoodRemoteNotifier",
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
