// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoodRemoteNotifier",
    platforms: [
        .iOS(.v13),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GoodRemoteNotifier",
            targets: ["GoodRemoteNotifier"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.9.0")),
        .package(url: "https://github.com/GoodRequest/GoodLogger.git", .upToNextMajor(from: "1.2.3"))
    ],
    targets: [
        .target(
            name: "GoodRemoteNotifier",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "GoodLogger", package: "GoodLogger")
            ],
            path: "./Sources/GoodRemoteNotifier",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

    ]
)
