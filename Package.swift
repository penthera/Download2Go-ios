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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.41.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "48ea3de6a2749c92f6b1e8dab61cb6caa83028260aff7cb87cb89c483d7e15fc"
        )
    ]
)
