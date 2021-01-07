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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1/VirtuosoClientDownloadEngine.xcframework.zip",
            checksum: "be6ab8ccf652cd72cbf16bcf63867f5cdaab8024eaeae32b6fb3e06dc2d59b4d"
        )
    ]
)
