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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.46/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "1427c58d6ac7b65619c2b1bc7d766f376aad7ed1e229d80d69dc8fd4f6f02300"
        )
    ]
)
