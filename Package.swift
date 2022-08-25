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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.20/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "d97fe99d8764c7b5d3ed281f5908f8abd9dac79ae395cdc8099f16716b4d1a88"
        )
    ]
)
