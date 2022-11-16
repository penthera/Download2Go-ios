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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.33/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "8c8cf99921f6663f51d4584d3ba1b83c58f3e05c9bae30e1603f3f26ffc22a9e"
        )
    ]
)
