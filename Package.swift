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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.41/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "f7c900eb6d3cd859080f5f0732dbe1e475cede3e76eee2ef26da8543b837d201"
        )
    ]
)
