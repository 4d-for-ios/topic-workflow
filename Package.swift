// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "topic-workflow",
    products: [
        .executable(name: "flatten", targets: ["flatten"]),
        .library(
            name: "topic-workflow",
            targets: ["topic-workflow"])
    ],
    dependencies: [
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "6.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "topic-workflow",
            dependencies: ["FileKit", "SwiftyJSON"]),
        .target(
            name: "flatten",
            dependencies: ["topic-workflow", "FileKit"])
    ]
)
