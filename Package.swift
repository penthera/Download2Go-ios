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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.0.3/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "983e8eee0aa367cc1b94fb4d4d981566e8f7f013030f6830d77285b3dd7277a3"
        )
    ]
)
