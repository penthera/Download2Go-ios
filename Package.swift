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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "b32fcad7d156f358404d377b689cce2e6bb71e65b9851a263eab8e742329aad3"
        )
    ]
)
