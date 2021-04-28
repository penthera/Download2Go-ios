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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1.4/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "fe67902b0a0078e2d7da35e9add5504f2c2d69ca24a1b0d5fb5aa819e868d0d1"
        )
    ]
)
