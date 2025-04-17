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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "048f6aae5484d9b8f14fae6a1583c5d11bc16319f55d299782d5ec1bca4deb99"
        )
    ]
)
