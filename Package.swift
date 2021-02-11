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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1.1/VirtuosoClientDownloadEngine.xcframework.zip",
            checksum: "6836bc3c7b2dc9e0cfaf7023703442aa8499cc7d568b96d688cf6b518970b570"
        )
    ]
)
