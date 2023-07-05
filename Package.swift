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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.44/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "d33492e4173502a9f05c8a12e8f78cff353ea5b43fc4fd4b7608983f80c0a08b"
        )
    ]
)
