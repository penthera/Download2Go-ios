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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.16/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "4f7e3436220a91583242c8412e2e4999b7ba6ff16dd789f17ae16b39a228ed3f"
        )
    ]
)
