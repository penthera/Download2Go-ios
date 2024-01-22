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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.3.0/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "37b393d715369d5e0b3b38e4f66822b781ca5eaf57e2ddbaecf4ad97ccda9454"
        )
    ]
)
