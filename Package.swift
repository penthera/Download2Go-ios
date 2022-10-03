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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.29/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "58fafc87a84ba868cb432af7b4d1b79282c52f59cdb47997593ac77bf46d51b4"
        )
    ]
)
