// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "topic-workflow",
    products: [
        .executable(name: "topic-workflow", targets: ["topic-workflow"]),
        .library(name: "TopicWorkflowKit", targets: ["TopicWorkflowKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "6.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", .upToNextMinor(from: "0.16.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMinor(from: "2.0.0")),
        .package(url: "https://github.com/twof/VaporMailgunService.git",  .upToNextMinor(from: "1.8.1"))
    ],
    targets: [
        .target(
            name: "TopicWorkflowKit",
            dependencies: ["FileKit", "SwiftyJSON", "Commandant", "Yams", "Mailgun"]),
        .target(
            name: "topic-workflow",
            dependencies: ["TopicWorkflowKit"])
    ]
)
