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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.9/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "3afaa3be302d0101bf8becde84d2c5ef3f733ac67ca81f9290c181f6d1e86342"
        )
    ]
)
