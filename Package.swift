// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VirtuosoClientDownloadEngine",
    products: [
        .library(name: "VirtuosoClientDownloadEngine", targets: ["VirtuosoClientDownloadEngine"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "VirtuosoClientDownloadEngine",
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1/VirtuosoClientDownloadEngine.xcframework.zip",
            checksum: "6ebbc49ae7ba8feb980890811a87dba6e02835d19c8d67f697125b0baef82841"
        )
    ]
)
