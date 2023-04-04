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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.36/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "43425d1df4479c1c684f566f880b148205e6d947b4eecab5f107f7ddfe8fbea7"
        )
    ]
)
