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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "a5c9ada7dfa445e29396381111642c2af886bfefe8500dfe7f27d235b3698c94"
        )
    ]
)
