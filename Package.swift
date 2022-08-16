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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.17/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "a1df51d6012bdd408898c0dd3db803b636a5eb4e076292d7539024500ff17f07"
        )
    ]
)
