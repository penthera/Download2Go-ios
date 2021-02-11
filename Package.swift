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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1.1/VirtuosoClientDownloadEngine.xcframework.zip",
            checksum: "d74888da2d70d4eebd09c04c58bf1a21c3dcc9900d3ee2209b8e8e9dcbfea751"
        )
    ]
)
