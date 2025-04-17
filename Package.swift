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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.3/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "e2d0926017d9925afbd12ae4283baa95d5e2b2c5e3de49db6d984aab071ac566"
        )
    ]
)
