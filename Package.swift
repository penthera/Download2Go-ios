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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.42/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "b99a4f8f6229f38c8b240ba864eb9e4c1acff3097974fa34cefb12ffc9c0225f"
        )
    ]
)
