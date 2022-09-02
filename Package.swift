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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.25/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "ad47c1b608b0177468966e4ab96b1e14168c711a53bc1d6f0acddf5383ebdebb"
        )
    ]
)
