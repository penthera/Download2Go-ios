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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.5/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "3505746683324da6a18325cd87d8ad02c429c78e2ce0d6a3893487e77865aba3"
        )
    ]
)
