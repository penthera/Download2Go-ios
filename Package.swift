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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.3/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "c7d200702fea652fc333ba4a5f2578197e1bdfff6458800831c3c1f2bc3f2c3c"
        )
    ]
)
