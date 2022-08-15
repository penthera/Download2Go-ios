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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.15/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "57712b33aa427583385e1af6c755c85d227c29ffb3b97b5c47fe0769d60e3410"
        )
    ]
)
