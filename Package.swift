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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.21/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "3f70f176ebf4706cd34bfb5f2291b9c372c3a8f762811278b2f170af2a1a1f66"
        )
    ]
)
