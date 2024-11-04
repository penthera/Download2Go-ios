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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.0/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "c1db0b8f828957cdb4453c4e69361cab1aad60f62b90403974264addbb4635d4"
        )
    ]
)
