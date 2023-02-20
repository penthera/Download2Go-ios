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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.34/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "9d6e98705be6e29de4b168c152684d7c6dc12e8b3aba0ccf9df9d7dff9ba691a"
        )
    ]
)
