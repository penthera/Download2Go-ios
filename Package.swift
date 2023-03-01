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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.35/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "810b9dcd0b35bb4e9f9f9f991cde9d7034956b07b65af37540f3bb63dbe97c73"
        )
    ]
)
