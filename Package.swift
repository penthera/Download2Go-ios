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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.8/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "e45b80d2e8290df0d9c2fd502fc7c99d1e1e3e743c430581770267c4b7d5989f"
        )
    ]
)
