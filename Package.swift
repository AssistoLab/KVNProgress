// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KVNProgress",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "KVNProgress",
            targets: ["KVNProgress"]),
    ],
    targets: [
        .target(
            name: "KVNProgress",
            dependencies: [
                "KVNProgressCategories",
            ],
            path: "KVNProgress/Classes",
            resources: [.process("../Resources")],
            publicHeadersPath: "."
        ),
        .target(
            name: "KVNProgressCategories",
            path: "KVNProgress/Categories",
            publicHeadersPath: "."
        ),
    ],
    swiftLanguageVersions: [.v5]
)
