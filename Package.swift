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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.27/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "ada10f35c876a1fb47e0ad8864a5ee4a7a3c05955ac8d21f57e1898be780e25e"
        )
    ]
)
