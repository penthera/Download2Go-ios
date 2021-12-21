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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.4/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "6230722e5275dca959ca308213b8e2fdfb98aff3e1757ed167a508aa4e0d3e53"
        )
    ]
)
