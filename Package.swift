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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.14/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "6be42b9539d50ff7f8c14cfe3ec339bc572acd34de6c581a2da34b671b42db9f"
        )
    ]
)
