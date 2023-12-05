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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.48/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "da2760cf27a8f037079a7837e241d21a0071d1e5b760543eb9f43044d44a4f75"
        )
    ]
)
