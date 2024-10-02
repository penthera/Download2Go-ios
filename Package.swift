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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.3.3/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "e403f5d61f66c3dfca4f1471e12fa15c5a420a55fda34a7aafd2859bbaa1bacb"
        )
    ]
)
