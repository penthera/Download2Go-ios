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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.39/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "eb7daa916a10cc5d4662d206425bb101e70260ce6698232c7684c0a71a4e40c6"
        )
    ]
)
