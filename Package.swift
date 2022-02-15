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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.0.1.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "db088d5c9e52d284ba779e18d5dfbe714fb123e56e80aca52df46265c574fd8d"
        )
    ]
)
